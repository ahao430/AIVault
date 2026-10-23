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

  group('Agent TUI 聊天解析（splitAgentTuiChat）', () {
    test('Claude Code v2.x 实测格式：❯ 用户 / ⏺ 回复 / 输入框噪音过滤', () {
      // 取自 macOS tmux 真实 capture-pane（Claude Code v2.1.304）
      const pane = '''
 ▐▛███▛█   Claude Code v2.1.304
▝▜██████▀  DeepSeek V4.1 Flash

▎ Using DeepSeek V4.1 Flash · /model

❯ hi

⏺ Hi! What can I help you with today?

✻ Worked for 6s · done 17:49

────────────────────────────────────────────────────────
❯ 
────────────────────────────────────────────────────────
  ⏵⏵ auto mode on (shift+tab to cycle) · ← 2 agents
''';
      final blocks = splitAgentTuiChat(pane)!;
      expect(blocks.first.isUser, isFalse, reason: '横幅为 Agent 块');
      expect(blocks.first.text, contains('Claude Code v2.1.304'));
      expect(blocks.first.text, isNot(contains('───')), reason: '分隔线被过滤');

      expect(blocks[1].isUser, isTrue);
      expect(blocks[1].text, 'hi');

      expect(blocks[2].isUser, isFalse);
      expect(blocks[2].text, contains('Hi! What can I help'));
      expect(blocks[2].text, contains('Worked for 6s'), reason: '状态行保留');
      expect(blocks[2].text, isNot(contains('auto mode')), reason: '提示噪音被过滤');
      expect(blocks[2].text, isNot(contains('❯')), reason: '空输入框被跳过');
      expect(blocks.last, blocks[2]);
    });

    test('旧版 > 标记 + 多行输入续行 + ⎿ 工具结果', () {
      const pane = '''
> first message
  continuation
⏺ reply line1
  ⎿ tool result
  more output
''';
      final blocks = splitAgentTuiChat(pane)!;
      final userBlocks = blocks.where((b) => b.isUser).toList();
      expect(userBlocks, hasLength(1));
      expect(userBlocks.single.text, contains('first message'));
      expect(userBlocks.single.text, contains('continuation'));
      final agent = blocks.last;
      expect(agent.isUser, isFalse);
      expect(agent.text, contains('reply line1'));
      expect(agent.text, contains('tool result'));
      expect(agent.text, contains('more output'));
      expect(agent.text, isNot(contains('⎿')), reason: '标记被剥掉');
    });

    test('Codex › 标记', () {
      const pane = '''
OpenAI Codex

› 写个快排

• 思考中…

func quickSort(arr []int) {
''';
      final blocks = splitAgentTuiChat(pane)!;
      expect(blocks[0].isUser, isFalse);
      expect(blocks[0].text, contains('OpenAI Codex'));
      expect(blocks[1].isUser, isTrue);
      expect(blocks[1].text, '写个快排');
      expect(blocks[2].isUser, isFalse);
      expect(blocks[2].text, contains('quickSort'));
    });

    test('盒子边框剥除（│ text │）', () {
      const pane = '''
╭────────────────────╮
│ ✳ Welcome!         │
╰────────────────────╯
❯ ping
⏿pong
''';
      final blocks = splitAgentTuiChat(pane)!;
      expect(blocks.first.text, contains('Welcome!'));
      expect(blocks.first.text, isNot(contains('│')));
    });

    test('无用户标记 → 返回 null（调用方退回旧逻辑）', () {
      expect(splitAgentTuiChat('plain output\nno markers here'), isNull);
      expect(splitAgentTuiChat(''), isNull);
      // 空输入框不算用户标记
      expect(splitAgentTuiChat('───\n❯\n───'), isNull);
    });
  });
}
