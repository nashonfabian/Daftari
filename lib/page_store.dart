import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'page_entry.dart';

abstract interface class PageStore {
  Future<List<PageEntry>> getPages();
  Future<int> savePage(PageEntry page);
  Future<void> deletePage(int id);
}

class SqlitePageStore implements PageStore {
  SqlitePageStore._();

  static final SqlitePageStore instance = SqlitePageStore._();
  Database? _database;

  Future<Database> get _db async {
    if (_database != null) return _database!;
    final databasePath = await getDatabasesPath();
    _database = await openDatabase(
      path.join(databasePath, 'daftari.db'),
      version: 1,
      onCreate: (db, version) => db.execute('''
        CREATE TABLE pages (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          body TEXT NOT NULL,
          page_date TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      '''),
    );
    return _database!;
  }

  @override
  Future<List<PageEntry>> getPages() async {
    final rows = await (await _db).query(
      'pages',
      orderBy: 'page_date DESC, id DESC',
    );
    return rows.map(PageEntry.fromMap).toList();
  }

  @override
  Future<int> savePage(PageEntry page) async {
    final db = await _db;
    final values = page.toMap();
    if (page.id == null) {
      return db.insert('pages', values);
    }
    await db.update('pages', values, where: 'id = ?', whereArgs: [page.id]);
    return page.id!;
  }

  @override
  Future<void> deletePage(int id) async {
    await (await _db).delete('pages', where: 'id = ?', whereArgs: [id]);
  }
}
