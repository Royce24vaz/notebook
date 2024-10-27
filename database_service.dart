import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'notes.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE topics(id INTEGER PRIMARY KEY, title TEXT)',
        );
        await db.execute(
          'CREATE TABLE notes(id INTEGER PRIMARY KEY, topic_id INTEGER, content TEXT)',
        );
      },
    );
  }

  Future<void> addTopic(String title) async {
    final db = await database;
    await db.insert('topics', {'title': title});
  }

  Future<List<Map<String, dynamic>>> getTopics() async {
    final db = await database;
    return await db.query('topics');
  }

  Future<void> deleteTopic(int topicId) async {
    final db = await database;
    await db.delete('topics', where: 'id = ?', whereArgs: [topicId]);
    await db.delete('notes', where: 'topic_id = ?', whereArgs: [topicId]);
  }

  Future<void> renameTopic(int topicId, String newTitle) async {
    final db = await database;
    await db.update(
      'topics',
      {'title': newTitle},
      where: 'id = ?',
      whereArgs: [topicId],
    );
  }

  Future<void> addNote(int topicId, String content) async {
    final db = await database;
    await db.insert('notes', {
      'topic_id': topicId,
      'content': content,
    });
  }

  Future<List<Map<String, dynamic>>> getNotes(int topicId) async {
    final db = await database;
    return await db.query('notes', where: 'topic_id = ?', whereArgs: [topicId]);
  }

  Future<void> deleteNote(int noteId) async {
    final db = await database;
    await db.delete('notes', where: 'id = ?', whereArgs: [noteId]);
  }
}
