import 'package:aivault/services/ssh_service.dart' show verifyHostKey;
import 'package:aivault/services/tmux.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('tmux list-sessions 解析', () {
    test('标准两行输出（含 attached）', () {
      const output = 'newapi: 1 windows (created Tue Oct 18 08:00:00 2026) (attached)\n'
          'goal-app: 2 windows (created Mon Oct 17 22:11:33 2026)\n';
      final sessions = parseTmuxSessions(output);
      expect(sessions, hasLength(2));
      expect(sessions[0].name, 'newapi');
      expect(sessions[0].windows, 1);
      expect(sessions[0].attached, isTrue);
      expect(sessions[0].created, DateTime(2026, 10, 18, 8, 0, 0));
      expect(sessions[1].name, 'goal-app');
      expect(sessions[1].windows, 2);
      expect(sessions[1].attached, isFalse);
    });

    test('错误输出不产生会话', () {
      const output = 'no server running on /tmp/tmux-501/default\n';
      expect(parseTmuxSessions(output), isEmpty);
    });

    test('会话名带冒号也能解析', () {
      const output = 'my:session: 3 windows (created Wed Oct  1 09:00:00 2026)\n';
      final sessions = parseTmuxSessions(output);
      expect(sessions.single.name, 'my:session');
      expect(sessions.single.windows, 3);
      expect(sessions.single.created!.day, 1);
    });

    test('空输出 / 空行', () {
      expect(parseTmuxSessions(''), isEmpty);
      expect(parseTmuxSessions('\n\n'), isEmpty);
    });
  });

  group('Agent 识别（Plan #33 简化版）', () {
    test('按会话名识别', () {
      expect(detectAgent('claude-newapi', ''), AgentKind.claudeCode);
      expect(detectAgent('codex', ''), AgentKind.codex);
      expect(detectAgent('opencode', ''), AgentKind.opencode);
    });

    test('按 pane 内容识别', () {
      expect(detectAgent('work', 'Welcome to Claude Code!'),
          AgentKind.claudeCode);
      expect(detectAgent('work', 'codex cli v1.2'), AgentKind.codex);
    });

    test('未知', () {
      expect(detectAgent('bash', 'hello world'), AgentKind.unknown);
    });
  });

  group('host key TOFU 比对（Plan #39）', () {
    test('首次（无记录）→ null 表示应接受并记录', () {
      expect(verifyHostKey(null, 'SHA256:abc'), isNull);
      expect(verifyHostKey('', 'SHA256:abc'), isNull);
    });

    test('匹配 → true', () {
      expect(verifyHostKey('SHA256:abc', 'SHA256:abc'), isTrue);
    });

    test('变化 → false（拒绝，防中间人）', () {
      expect(verifyHostKey('SHA256:abc', 'SHA256:xyz'), isFalse);
    });
  });
}
