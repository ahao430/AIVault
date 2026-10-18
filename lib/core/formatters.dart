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
