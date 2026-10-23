/// Agent 聊天视图解析（Plan #34：手机端聊天式 UI，终端为底层）。
///
/// 思路：会话内通过本 App 发送过的输入会被终端回显在 pane 中，
/// 以这些已知输入文本为分割点，把 capture-pane 的历史切分为
/// 「用户消息 → Agent 响应」对话块。解析不了的内容整体作为
/// Agent 块展示，复杂 TUI 可一键切换终端视图兜底（Plan #35）。
library;

class AgentChatBlock {
  const AgentChatBlock({required this.isUser, required this.text});

  final bool isUser;
  final String text;
}

/// 把 pane 输出按 [inputs]（按发送顺序）分割为对话块。
List<AgentChatBlock> splitPaneIntoChat(String paneText, List<String> inputs) {
  final lines = paneText.split('\n');
  final blocks = <AgentChatBlock>[];
  final knownInputs = [
    for (final i in inputs)
      if (i.trim().isNotEmpty) i.trim(),
  ];

  // 定位每个输入在 pane 中的行号（顺序向后查找）
  final anchors = <int>[];
  var searchFrom = 0;
  for (final needle in knownInputs) {
    var found = -1;
    for (var i = searchFrom; i < lines.length; i++) {
      if (lines[i].contains(needle)) {
        found = i;
        break;
      }
    }
    if (found >= 0) {
      anchors.add(found);
      searchFrom = found + 1;
    }
  }

  if (anchors.isEmpty) {
    final text = tidyAgentOutput(paneText);
    if (text.isEmpty) return const [];
    return [AgentChatBlock(isUser: false, text: text)];
  }

  // 锚点之前的头部（Agent 启动信息 / 会话开头）作为 Agent 块
  final head = tidyAgentOutput(lines.sublist(0, anchors.first).join('\n'));
  if (head.isNotEmpty) {
    blocks.add(AgentChatBlock(isUser: false, text: head));
  }

  for (var k = 0; k < anchors.length; k++) {
    final start = anchors[k];
    final end = k + 1 < anchors.length ? anchors[k + 1] : lines.length;
    final segment = lines.sublist(start, end);

    blocks.add(AgentChatBlock(isUser: true, text: knownInputs[k]));

    final response = tidyAgentOutput(segment.sublist(1).join('\n'));
    if (response.isNotEmpty) {
      blocks.add(AgentChatBlock(isUser: false, text: response));
    }
  }

  return blocks;
}

/// 压缩 Agent 输出中的 TUI 噪音：连续空白行折叠、行尾空白去除、
/// 首尾空行去除。
String tidyAgentOutput(String raw) {
  final out = <String>[];
  var blankRun = 0;
  for (final l in raw.split('\n')) {
    final trimmed = l.trimRight();
    if (trimmed.trim().isEmpty) {
      blankRun++;
      if (blankRun > 1) continue;
    } else {
      blankRun = 0;
    }
    out.add(trimmed);
  }
  while (out.isNotEmpty && out.last.trim().isEmpty) {
    out.removeLast();
  }
  while (out.isNotEmpty && out.first.trim().isEmpty) {
    out.removeAt(0);
  }
  return out.join('\n');
}

/// ─── Agent TUI 聊天解析（Claude Code / Codex / Pi）───────────────────────
///
/// 这些 Agent 的 TUI 在 pane 快照里有稳定的行首标记（实测 Claude Code
/// v2.1.304）：用户输入 `❯ `（旧版 `> `、Codex `› `、Pi/通用 `> `），
/// 回复与工具结果 `⏺ ` / `⎿ `。按标记把 pane 切成「用户 ↔ Agent」
/// 对话块；识别不到任何用户输入标记时返回 null，调用方退回
/// [splitPaneIntoChat] 的输入历史分割逻辑。

/// 用户输入行标记（只认行首，避免误伤回复里缩进的 `>` 引用 / diff）
final _tuiUserMarkerRe = RegExp(r'^(?:❯|›|>) ?(.*)$');

/// Agent 侧标记：Claude Code 回复 `⏺` 与工具结果 `⎿`
final _tuiAgentMarkerRe = RegExp(r'^\s{0,3}(?:⏺|⎿) ?(.*)$');

/// 纯边框/分隔线行（输入框上下沿的横线、盒子边框等）
final _tuiBorderOnlyRe = RegExp(
    r'^[\s╭╮╰╯┌┐└┘├┤┬┴┼─━═│┃╌╍╎╏┄┅┆┇┈┉┊┋]+$');

/// 底部输入区的提示噪音（auto mode / 快捷键提示）
final _tuiNoiseRe = RegExp(r'⏵⏵|shift\+tab|^\s*\? for shortcuts');

List<AgentChatBlock>? splitAgentTuiChat(String paneText) {
  final blocks = <AgentChatBlock>[];
  final buf = <String>[];
  var isUser = false;
  var foundUser = false;

  void flush() {
    if (buf.isEmpty) return;
    final text = tidyAgentOutput(_dedent(buf).join('\n'));
    buf.clear();
    if (text.isEmpty) return;
    // 相邻同侧块合并，避免一段回复的多个 ⏺/⎿ 段碎成一串气泡
    if (blocks.isNotEmpty && blocks.last.isUser == isUser) {
      blocks[blocks.length - 1] =
          AgentChatBlock(isUser: isUser, text: '${blocks.last.text}\n\n$text');
    } else {
      blocks.add(AgentChatBlock(isUser: isUser, text: text));
    }
  }

  for (final raw in paneText.split('\n')) {
    final line = _stripBoxEdge(raw.trimRight());
    if (_tuiBorderOnlyRe.hasMatch(line)) continue;
    if (_tuiNoiseRe.hasMatch(line)) continue;

    final user = _tuiUserMarkerRe.firstMatch(line);
    if (user != null) {
      final rest = user.group(1)!.trim();
      // 空输入框（当前无草稿）：不切换状态，后续行仍归上一个块
      if (rest.isEmpty) continue;
      flush();
      isUser = true;
      foundUser = true;
      buf.add(rest);
      continue;
    }
    final agent = _tuiAgentMarkerRe.firstMatch(line);
    if (agent != null) {
      if (isUser) flush();
      isUser = false;
      final rest = agent.group(1)!.trim();
      if (rest.isNotEmpty) buf.add(rest);
      continue;
    }
    // Codex / Pi 的回复没有专用标记：用户消息通常单行 + 空行结束，
    // 空行之后的内容归 Agent 侧。
    if (isUser && line.trim().isEmpty) {
      flush();
      isUser = false;
      continue;
    }
    buf.add(line);
  }
  flush();

  if (!foundUser) return null;
  return blocks;
}

/// 去掉行首尾的盒子竖边（`│ text │` → `text`），其余空白不动。
String _stripBoxEdge(String line) {
  var s = line.replaceFirst(RegExp(r'^\s*│\s?'), '');
  return s.replaceFirst(RegExp(r'\s?│\s*$'), '');
}

/// 去掉块内非空行的公共缩进（Claude Code 回复续行缩进 2 格）。
List<String> _dedent(List<String> lines) {
  var min = 1 << 30;
  for (final l in lines) {
    if (l.trim().isEmpty) continue;
    final indent = l.length - l.trimLeft().length;
    if (indent < min) min = indent;
  }
  if (min <= 0 || min == 1 << 30) return lines;
  return [for (final l in lines) l.length < min ? l : l.substring(min)];
}
