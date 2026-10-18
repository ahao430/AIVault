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
