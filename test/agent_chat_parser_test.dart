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

  group('编号选项提取（extractNumberedOptions）', () {
    test('Claude 权限对话框（盒子样式，光标 ❯ 在选项上）', () {
      const pane = '''

╭─❯ Claude is asking for permission ────────────────╮
│ ❯ 1. Yes                                          │
│   2. Yes, and don't ask again this session        │
│   3. No, and tell Claude what to do differently   │
╰───────────────────────────────────────────────────╯
  ? for shortcuts
''';
      final options = extractNumberedOptions(pane);
      expect(options, hasLength(3));
      expect(options[0].number, 1);
      expect(options[0].label, contains('Yes'));
      expect(options[1].number, 2);
      expect(options[2].label, contains('differently'));
    });

    test('计划确认（inline 光标前缀 + 换行续排）', () {
      const pane = '''
❯ 1. Yes, and auto-accept edits
  2. Yes, and manually approve edits
  3. No, keep planning

──────────────────────────────────────
❯ 
──────────────────────────────────────''';
      final options = extractNumberedOptions(pane);
      expect(options, hasLength(3));
      expect(options[2].label, 'No, keep planning');
    });

    test('盒子样式（无光标，靠标题语境）', () {
      const pane = '''
│ Claude wants to use Bash          │
│ 1. Allow once                     │
│ 2. Allow always for this session  │
╰───────────────────────────────────╯''';
      final options = extractNumberedOptions(pane);
      expect(options, hasLength(2));
      expect(options[1].label, contains('always'));
    });

    test('欢迎页使用技巧（编号列表但非对话框）不误报', () {
      const pane = '''
✳ Welcome to Claude Code!

  Tips for getting started:

  1. Ask questions, edit files, or run commands
  2. Plan tasks, and keep Claude on track
  3. Review Claude's changes




──────────────────────────────
❯ 
──────────────────────────────''';
      expect(extractNumberedOptions(pane), isEmpty);
    });

    test('Agent 回复里的编号步骤列表不误报', () {
      const pane = '''
❯ how to install docker?

⏺ Steps:

  1. Install dependencies
  2. Run the installer
  3. Verify the installation
''';
      expect(extractNumberedOptions(pane), isEmpty);
    });

    test('模型选择器（分页两位数编号 + ❯/↑ 光标，实测 v2.1.304）', () {
      const pane = '''
▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔
   Select model
   Switch between Claude models.

   ↑ 36.  GPT-5.5 · 易准大模型                    via magpie
     37.  GPT-5.6 Sol · 易准大模型                via magpie
   ❯ 38.  DeepSeek V4.1 Flash · 易准大模型 ✔      via magpie
      … +144 models

   ● High effort (default) ←/→ to adjust

   Enter to set as default · s to use this session only · Esc to cancel
''';
      final options = extractNumberedOptions(pane);
      expect(options, hasLength(3));
      expect(options[0].number, 36, reason: '两位编号不能错位成 6');
      expect(options[0].label, startsWith('GPT-5.5'));
      expect(options[2].number, 38);
      expect(options[2].label, contains('DeepSeek'));
    });

    test('用户消息本身是编号文本（❯ ·1. xxx）不误报', () {
      const pane = '''
❯ ·1. first choice
  2. second choice
''';
      expect(extractNumberedOptions(pane), isEmpty);
    });
  });

  group('Agent 状态解析（parseAgentStatusInfo）', () {
    test('Claude Code 横幅：模型名', () {
      const pane = '''
 ▐▛███▛█   Claude Code v2.1.304
▝▜██████▀  DeepSeek V4.1 Flash · 易准大模型 · API Usage Billing

▎ Using DeepSeek V4.1 Flash · 易准大模型 (from .claude/settings.json) · /model
''';
      final info = parseAgentStatusInfo(pane);
      expect(info.model, 'DeepSeek V4.1 Flash');
      expect(info.contextLeftPct, isNull);
      expect(info.cacheHitPct, isNull);
    });

    test('上下文剩余 + 缓存命中', () {
      const pane = '''
Context left until auto-compact: 61.2% (36.7k tokens)

94% of prompt tokens were read from cache
''';
      final info = parseAgentStatusInfo(pane);
      expect(info.contextLeftPct, 61.2);
      expect(info.cacheHitPct, 94);
    });

    test('Percent context left 句式 + 无字段时全 null', () {
      final info = parseAgentStatusInfo('⚡ 42% context left');
      expect(info.contextLeftPct, 42);
      final empty = parseAgentStatusInfo('plain pane\nno status here');
      expect(empty.isEmpty, isTrue);
    });

    test('Codex 风格 model: 前缀', () {
      final info = parseAgentStatusInfo('OpenAI Codex\nmodel: gpt-5-codex\n');
      expect(info.model, 'gpt-5-codex');
    });
  });

  group('Agent 内容分段（parseAgentSegments）', () {
    test('工具调用卡：⏺ Xxx(...) + ⎿ 结果收集为 tool 段', () {
      const text = '''
开始分析项目结构。

⏺ Read(/src/main.dart)
  ⎿ Read 45 lines

⏺ Bash(npm test)
  ⎿ 8 passed

修复完成。''';
      final segs = parseAgentSegments(text);
      expect(
          segs.where((s) => s.kind == AgentSegmentKind.tool), hasLength(2));
      final bash = segs.firstWhere(
          (s) => s.kind == AgentSegmentKind.tool && s.title!.contains('Bash'));
      expect(bash.title, '⏺ Bash(npm test)');
      expect(bash.body, contains('8 passed'));
      // 工具卡前后的自然语言保留为 text 段
      expect(segs.first.kind, AgentSegmentKind.text);
      expect(segs.first.text, contains('分析项目结构'));
      expect(segs.last.kind, AgentSegmentKind.text);
      expect(segs.last.text, contains('修复完成'));
    });

    test('``` 围栏代码块提取（含语言标注）', () {
      const text = '''
修改如下：

```dart
void main() {
  print('hello');
}
```

完成。''';
      final segs = parseAgentSegments(text);
      final code =
          segs.where((s) => s.kind == AgentSegmentKind.code).single;
      expect(code.lang, 'dart');
      expect(code.text, contains("print('hello');"));
      expect(code.text, isNot(contains('```')));
      expect(segs.first.kind, AgentSegmentKind.text);
    });

    test('普通回复文本（⏺ 开头但非 Identifier(...)）不误判为工具', () {
      const text = '⏺ 好的，我已经完成修改。\n\n  详细说明在这里';
      final segs = parseAgentSegments(text);
      expect(segs, hasLength(1));
      expect(segs.single.kind, AgentSegmentKind.text);
    });

    test('工具卡正文在下一个 ⏺ 前截止（不吞后续回复）', () {
      const text = '''
⏺ Edit(/lib/a.dart)
  ⎿ Updated 2 lines

⏺ 已应用全部修改，测试通过。''';
      final segs = parseAgentSegments(text);
      expect(segs, hasLength(2));
      final last = segs.last;
      expect(last.kind, AgentSegmentKind.text);
      expect(last.text, contains('测试通过'));
    });
  });
}
