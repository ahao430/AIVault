/// 显示格式化工具
library;

/// 重置倒计时：「4小时58分钟后重置」/「2h 31m」
String formatRemaining(Duration d) {
  if (d.isNegative) return '即将重置';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0) return '$h小时$m分钟后重置';
  if (m > 0) return '$m分钟后重置';
  return '${d.inSeconds}秒后重置';
}

/// 余额：¥128.50 / $12.34
String formatBalance(double amount, String currency) {
  final symbol = currency == 'CNY'
      ? '¥'
      : currency == 'USD'
          ? r'$'
          : '$currency ';
  return '$symbol${amount.toStringAsFixed(2)}';
}

/// 相对时间：3 分钟前 / 昨天 23:11
String formatRelative(DateTime time, DateTime now) {
  final diff = now.difference(time);
  if (diff.inMinutes < 1) return '刚刚';
  if (diff.inMinutes < 60) return '${diff.inMinutes} 分钟前';
  if (diff.inHours < 24) return '${diff.inHours} 小时前';
  if (diff.inDays == 1) return '昨天';
  if (diff.inDays < 30) return '${diff.inDays} 天前';
  return '${time.year}-${_two(time.month)}-${_two(time.day)}';
}

String _two(int n) => n.toString().padLeft(2, '0');

/// 字节量：512 B / 1.25 MB / 2.0 GB（[perSecond] 时附加 /s）
String formatBytes(num bytes, {bool perSecond = false}) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  var value = bytes.toDouble();
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  // 1000 GB 与相邻量级（1.03 TB）观感统一：达到 1000 就进位
  if (value.round() >= 1000 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final decimals = value >= 100 || unit == 0 ? 0 : (value >= 10 ? 1 : 2);
  var text = value.toStringAsFixed(decimals);
  if (text.contains('.')) {
    text = text.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return '$text ${units[unit]}${perSecond ? '/s' : ''}';
}

/// 运行时长：36 天 / 5 小时 12 分 / 46 秒
String formatUptime(int seconds) {
  if (seconds < 60) return '$seconds 秒';
  final d = seconds ~/ 86400;
  final h = (seconds % 86400) ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  if (d > 0) return '$d 天${h > 0 ? ' $h 小时' : ''}';
  if (h > 0) return '$h 小时${m > 0 ? ' $m 分' : ''}';
  return '$m 分';
}
