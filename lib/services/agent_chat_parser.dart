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

/// 输入回显的弱化前缀 artifact（Claude Code 部分版本：`❯ ·hi`）
final _tuiEchoDotRe = RegExp(r'^·\s?');

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
      var rest = user.group(1)!.trim();
      rest = rest.replaceFirst(_tuiEchoDotRe, '').trim();
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

/// ─── 编号选项（触屏直选）───────────────────────────────────────────────────

class AgentOption {
  const AgentOption({required this.number, required this.label});

  final int number;
  final String label;
}

/// 单行内的编号项：`1. Yes`（inline 多项以 ≥2 空格分隔；编号 1-3 位，
/// Claude Code 的模型选择器分页后从任意编号开始，如 `36.`）
final _numberedItemRe =
    RegExp(r'([0-9]{1,3})\.\s+(\S.*?)\s*(?=\s{2,}[0-9]{1,3}\.|\s*$)');

/// 选项对话框的语境标记（二选一即认定）：
/// 1. 选中光标直接前缀编号项：`❯ 1. Yes` / `↑ 36.`（inline / 计划确认 /
///    分页列表样式）
/// 2. 上方 ≤3 行是权限 / 确认类标题（Claude is asking for permission、
///    Claude wants to use …、Select model 等）。
/// 用于排除「Agent 回复里的编号步骤列表」「欢迎页使用技巧」这两种
/// 长得像选项的普通编号列表。
final _optionCursorRe = RegExp(r'^\s*[❯›↑]\s*[0-9]{1,3}\.');
final _optionHeaderRe = RegExp(
    r'asking for permission|wants to|permission to|approve|select (?:an option|model)|确认|选择',
    caseSensitive: false);

/// 从 pane 尾部提取最近一组编号选项（Claude Code 的权限 / 计划确认
/// 对话框：`❯ 1. Yes`、`│ 1. Yes │`、单行 `1. Yes  2. No` 及其换行
/// 续排）。要求 ≥2 项、以 1 开头、邻近 3 行内有对话框语境标记
/// （❯ / asking for permission 等，用于排除欢迎页的编号技巧列表）。
List<AgentOption> extractNumberedOptions(String paneText,
    {int tailLines = 30}) {
  final lines = paneText.split('\n');
  final tail =
      lines.length <= tailLines ? lines : lines.sublist(lines.length - tailLines);
  final stripped = [for (final l in tail) _stripBoxEdge(l.trimRight())];

  // 第一段：收集连续编号行组成的选项组（start, end, items）
  final runs = <(int, int, List<AgentOption>)>[];
  var start = -1;
  var end = -1;
  var items = <AgentOption>[];
  for (var i = 0; i < stripped.length; i++) {
    final lineItems = <AgentOption>[
      for (final m in _numberedItemRe.allMatches(stripped[i]))
        if (m.group(2)!.trim().isNotEmpty)
          AgentOption(
              number: int.parse(m.group(1)!),
              // 压缩模型选择器等多列布局留下的长空白
              label: m
                  .group(2)!
                  .trim()
                  .replaceAll(RegExp(r'\s{2,}'), ' ')),
    ];
    if (lineItems.isEmpty) {
      if (items.isNotEmpty) {
        runs.add((start, end, items));
        items = <AgentOption>[];
      }
      continue;
    }
    if (items.isEmpty) start = i;
    items = [...items, ...lineItems];
    end = i;
  }
  if (items.isNotEmpty) runs.add((start, end, items));

  // 第二段：从后往前找合法组，并校验语境（光标前缀或权限标题）。
  // 编号须严格递增且 ≥2 项（允许分页列表从任意编号开始，如 36/37/38）。
  for (final (s, e, runItems) in runs.reversed) {
    if (runItems.length < 2) continue;
    var ascending = true;
    for (var i = 1; i < runItems.length; i++) {
      if (runItems[i].number <= runItems[i - 1].number) ascending = false;
    }
    if (!ascending) continue;
    final hasCursor = stripped
        .sublist(s, e + 1)
        .any((l) => _optionCursorRe.hasMatch(l));
    if (hasCursor) return runItems;
    final from = (s - 3).clamp(0, stripped.length);
    final header = stripped.sublist(from, s).join('\n');
    if (_optionHeaderRe.hasMatch(header)) return runItems;
  }
  return const [];
}

/// ─── Agent 状态（模型 / 上下文 / 缓存）─────────────────────────────────────

class AgentStatusInfo {
  const AgentStatusInfo({this.model, this.contextLeftPct, this.cacheHitPct});

  final String? model;

  /// 剩余上下文百分比（0-100），TUI 未展示时为 null
  final double? contextLeftPct;

  /// 缓存命中率百分比（0-100），TUI 未展示时为 null
  final double? cacheHitPct;

  bool get isEmpty =>
      model == null && contextLeftPct == null && cacheHitPct == null;
}

/// 尽力从 pane 快照提取 Agent 状态：Claude Code 横幅的 `Using <model> ·`、
/// `Context left until auto-compact: N%`、`N% of prompt tokens ... cache`。
/// 这些展示随版本 / 状态时有时无，取最后一次出现的值。
AgentStatusInfo parseAgentStatusInfo(String paneText) {
  String? model;
  final usingMatches =
      RegExp(r'Using\s+(.+?)\s*·').allMatches(paneText).toList();
  if (usingMatches.isNotEmpty) {
    model = usingMatches.last.group(1)!.trim();
  } else {
    final m = RegExp(
            r'\bmodel[:\s]+([A-Za-z0-9][\w.+\-/ ]{1,32}?)\s*(?:·|\||\n|$)',
            caseSensitive: false)
        .allMatches(paneText)
        .toList();
    if (m.isNotEmpty) model = m.last.group(1)!.trim();
  }

  double? ctx;
  for (final re in [
    RegExp(r'context (?:left|remaining)[^0-9\n]{0,40}?([\d.]+)\s*%',
        caseSensitive: false),
    RegExp(r'([\d.]+)\s*%\s*context left', caseSensitive: false),
  ]) {
    final ms = re.allMatches(paneText).toList();
    if (ms.isNotEmpty) {
      ctx = double.tryParse(ms.last.group(1)!);
      if (ctx != null) break;
    }
  }

  double? cache;
  final cacheMs = RegExp(r'([\d.]+)\s*%[^%\n]{0,60}?cache', caseSensitive: false)
      .allMatches(paneText)
      .toList();
  if (cacheMs.isNotEmpty) cache = double.tryParse(cacheMs.last.group(1)!);

  return AgentStatusInfo(
      model: model, contextLeftPct: ctx, cacheHitPct: cache);
}
