/// tmux 输出解析（纯函数，可单测）。
///
/// list-sessions 默认输出：
/// `name: N windows (created Tue Oct 18 08:00:00 2026) (attached)`
library;

class TmuxSession {
  const TmuxSession({
    required this.name,
    required this.windows,
    required this.created,
    required this.attached,
  });

  final String name;
  final int windows;
  final DateTime? created;
  final bool attached;
}

/// 解析 `tmux list-sessions` 输出。
List<TmuxSession> parseTmuxSessions(String output) {
  final sessions = <TmuxSession>[];
  // 行格式：`name: N windows (created ...) (attached)`，name 可含冒号，
  // 因此用贪婪匹配锚定「: N windows」边界而非第一个冒号。
  final lineRe = RegExp(r'^(.+):\s+(\d+) windows \((.+)\)$');
  for (final rawLine in output.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final m = lineRe.firstMatch(line);
    if (m == null) continue; // 错误信息（如 no server running on ...）
    final name = m.group(1)!.trim();
    final windows = int.tryParse(m.group(2)!) ?? 1;
    final rest = m.group(3)!;

    // rest 形如 `created Tue Oct 18 08:00:00 2026` 或
    // `created Tue Oct 18 08:00:00 2026) (attached`（外层括号被行正则消费其一）
    final createdMatch = RegExp(r'created (.+?)(\)|$)').firstMatch(rest);
    final attached = rest.contains('attached');

    DateTime? created;
    if (createdMatch != null) {
      created = DateTime.tryParse(createdMatch.group(1)!) ??
          _parseAsctime(createdMatch.group(1)!);
    }

    sessions.add(TmuxSession(
      name: name,
      windows: windows,
      created: created,
      attached: attached,
    ));
  }
  return sessions;
}

/// tmux 输出的日期格式：`Tue Oct 18 08:00:00 2026`
DateTime? _parseAsctime(String s) {
  final m = RegExp(
      r'([A-Za-z]{3})\s+(\d{1,2})\s+(\d{2}:\d{2}:\d{2})\s+(\d{4})')
      .firstMatch(s);
  if (m == null) return null;
  const months = {
    'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
    'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
  };
  final month = months[m.group(1)];
  if (month == null) return null;
  final time = m.group(3)!.split(':');
  return DateTime(
    int.parse(m.group(4)!),
    month,
    int.parse(m.group(2)!),
    int.parse(time[0]),
    int.parse(time[1]),
    int.parse(time[2]),
  );
}

/// 从 pane 输出中识别正在运行的 Agent（Plan #33 的简化版：
/// 按 tmux session 名与 pane 内容关键词判断）。
enum AgentKind { claudeCode, codex, opencode, pi, unknown }

const _agentKeywords = {
  AgentKind.claudeCode: ['claude', 'claude code'],
  AgentKind.codex: ['codex'],
  AgentKind.opencode: ['opencode'],
  AgentKind.pi: ['pi '],
};

AgentKind detectAgent(String sessionName, String paneContent) {
  final haystack =
      '$sessionName\n${paneContent.toLowerCase().takeLast(2000)}';
  for (final entry in _agentKeywords.entries) {
    for (final kw in entry.value) {
      if (haystack.contains(kw)) return entry.key;
    }
  }
  return AgentKind.unknown;
}

extension _TakeLast on String {
  String takeLast(int n) =>
      length <= n ? this : substring(length - n);
}

extension AgentKindLabel on AgentKind {
  String get label {
    switch (this) {
      case AgentKind.claudeCode:
        return 'Claude Code';
      case AgentKind.codex:
        return 'Codex';
      case AgentKind.opencode:
        return 'OpenCode';
      case AgentKind.pi:
        return 'Pi';
      case AgentKind.unknown:
        return '未知';
    }
  }
}
