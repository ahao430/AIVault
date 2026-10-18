import 'dart:convert';

import 'package:file_selector/file_selector.dart';

/// JSON 备份：导出（默认脱敏，可选含密钥）/ 导入（按 id 合并）。
class BackupService {
  static const _typeGroup = XTypeGroup(label: 'JSON', extensions: ['json']);

  /// 选择保存位置并写入导出数据；返回保存路径，取消返回 null。
  Future<String?> exportToFile(Map<String, dynamic> data) async {
    final location = await getSaveLocation(
      suggestedName:
          'aivault-export-${DateTime.now().toIso8601String().split('T').first}.json',
      acceptedTypeGroups: const [_typeGroup],
    );
    if (location == null) return null;
    final content = const JsonEncoder.withIndent('  ').convert(data);
    final file = XFile.fromData(
      utf8.encode(content),
      mimeType: 'application/json',
    );
    await file.saveTo(location.path);
    return location.path;
  }

  /// 打开文件选择器读取 JSON；取消或解析失败返回 null。
  Future<Map<String, dynamic>?> pickAndRead() async {
    final file = await openFile(acceptedTypeGroups: const [_typeGroup]);
    if (file == null) return null;
    try {
      final content = await file.readAsString();
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }
}
