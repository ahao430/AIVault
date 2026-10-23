import 'package:drift/drift.dart' hide Column;
import 'package:uuid/uuid.dart';

import '../db/database.dart';

/// 工作台书签仓库：常用网址 CRUD。
class BookmarkRepository {
  BookmarkRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Stream<List<Bookmark>> watchBookmarks() {
    return (_db.bookmarks.select()
          ..orderBy([
            (b) => OrderingTerm.asc(b.sortOrder),
            (b) => OrderingTerm.asc(b.createdAt),
          ]))
        .watch();
  }

  Future<List<Bookmark>> allBookmarks() => _db.bookmarks.select().get();

  /// 网址规范化：缺 scheme 补 https://；非法返回 null
  static String? normalizeUrl(String raw) {
    var url = raw.trim();
    if (url.isEmpty) return null;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) return null;
    return url;
  }

  Future<void> addBookmark({
    required String name,
    required String url,
  }) async {
    final now = DateTime.now();
    // 新书签排到最后：取当前最大 sortOrder + 1
    final maxSort = await (_db.bookmarks.select()
          ..orderBy([(b) => OrderingTerm.desc(b.sortOrder)])
          ..limit(1))
        .getSingleOrNull();
    await _db.bookmarks.insertOne(BookmarksCompanion.insert(
      id: _uuid.v4(),
      name: name.trim(),
      url: url.trim(),
      sortOrder: Value((maxSort?.sortOrder ?? 0) + 1),
      createdAt: now,
    ));
  }

  Future<void> updateBookmark({
    required String id,
    required String name,
    required String url,
  }) async {
    await (_db.bookmarks.update()..where((b) => b.id.equals(id))).write(
        BookmarksCompanion(name: Value(name.trim()), url: Value(url.trim())));
  }

  Future<void> deleteBookmark(String id) async {
    await (_db.bookmarks.delete()..where((b) => b.id.equals(id))).go();
  }

  /// 拖拽排序
  Future<void> reorder(List<String> ids) async {
    await _db.batch((b) {
      for (var i = 0; i < ids.length; i++) {
        b.update(
          _db.bookmarks,
          BookmarksCompanion(sortOrder: Value(i + 1)),
          where: ($BookmarksTable tbl) => tbl.id.equals(ids[i]),
        );
      }
    });
  }
}
