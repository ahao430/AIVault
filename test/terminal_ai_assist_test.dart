import 'package:aivault/ui/ssh/terminal_ai_assist.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('stripAnsi', () {
    test('剥离 CSI / OSC / 控制字符，保留文本', () {
      const raw = '\x1b[32mOK\x1b[0m\r\n\x1b]0;title\x07error\x1b[?25l';
      final text = stripAnsi(raw);
      expect(text, contains('OK'));
      expect(text, contains('error'));
      expect(text, isNot(contains('\x1b')));
      expect(text, isNot(contains('[32m')));
      expect(text, isNot(contains(']0;')));
    });

    test('保留换行与制表，CRLF 归一为 LF', () {
      final text = stripAnsi('a\r\nb\tc\x00d');
      expect(text, 'a\nb\tcd');
    });
  });

  group('extractCommandBlocks', () {
    test('提取 bash 代码块', () {
      const reply = '先看磁盘占用：\n```bash\ndu -sh /var/* | sort -h\n```\n'
          '一般 /var/log 最大。';
      expect(extractCommandBlocks(reply), ['du -sh /var/* | sort -h']);
    });

    test('无语言标注的代码块也算命令', () {
      const reply = '```\nls -la\n```';
      expect(extractCommandBlocks(reply), ['ls -la']);
    });

    test('多个代码块按序提取', () {
      const reply = '```bash\nuptime\n```\n然后 ```console\ntop -n 1\n```';
      expect(extractCommandBlocks(reply), ['uptime', 'top -n 1']);
    });

    test('python / json 说明性代码块不当作命令', () {
      const reply = '```json\n{"a": 1}\n```\n```python\nprint(1)\n```';
      expect(extractCommandBlocks(reply), isEmpty);
    });

    test('没有代码块返回空', () {
      expect(extractCommandBlocks('直接 reboot 就行'), isEmpty);
    });
  });
}
