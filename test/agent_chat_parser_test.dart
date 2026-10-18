import 'package:aivault/services/agent_chat_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Agent 聊天视图分割（Plan #34）', () {
    test('两次输入分割为 用户/Agent 交替块', () {
      const pane = '''
✻ Welcome to Claude Code!

> claude --resume
⏺ 已完成以下修改：
  - src/xxx.ts

> 继续处理测试问题
⏺ 正在执行测试……

  ✓ 2 passed

> 提交代码
⏺ 已创建 commit abc123''';
      final blocks = splitPaneIntoChat(pane,
          ['继续处理测试问题', '提交代码']);

      expect(blocks.first.isUser, isFalse, reason: '头部为 Agent 块');
      expect(blocks.first.text, contains('Welcome to Claude Code'));
      expect(blocks.first.text, contains('已完成以下修改'));

      final userBlocks = blocks.where((b) => b.isUser).toList();
      expect(userBlocks, hasLength(2));
      expect(userBlocks[0].text, '继续处理测试问题');
      expect(userBlocks[1].text, '提交代码');

      // 第二个输入之后的响应
      final tail = blocks.last;
      expect(tail.isUser, isFalse);
      expect(tail.text, contains('abc123'));
    });

    test('无输入历史：整体作为 Agent 块', () {
      const pane = '⏺ 一些输出\n\n细节';
      final blocks = splitPaneIntoChat(pane, []);
      expect(blocks, hasLength(1));
      expect(blocks.single.isUser, isFalse);
    });

    test('输入未在 pane 中找到（已被滚动）也安全', () {
      const pane = '⏺ 输出';
      final blocks = splitPaneIntoChat(pane, ['不存在的输入']);
      expect(blocks, hasLength(1));
      expect(blocks.single.text, contains('输出'));
    });

    test('重复输入按顺序匹配不同锚点', () {
      const pane = '''
> 再来一次
ok 1
> 再来一次
ok 2''';
      final blocks = splitPaneIntoChat(pane, ['再来一次', '再来一次']);
      final userBlocks = blocks.where((b) => b.isUser).toList();
      expect(userBlocks, hasLength(2));
      final responses = blocks.where((b) => !b.isUser).toList();
      expect(responses.last.text, 'ok 2');
    });

    test('tidy：折叠连续空行 + 去首尾空白', () {
      expect(tidyAgentOutput('  a  \n\n\n\n b \n\n\n'),
          '  a\n\n b');
      expect(tidyAgentOutput('\n\n\n'), '');
    });
  });
}
