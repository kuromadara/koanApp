import 'package:koan/models/common/koan.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _databaseService = DatabaseService._internal();
  factory DatabaseService() => _databaseService;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasepath = await getDatabasesPath();

    final path = join(databasepath, 'koan.db');

    return await openDatabase(
      path,
      onCreate: _onCreate,
      version: 1,
      onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
            CREATE TABLE koans (
            id INTEGER PRIMARY KEY,
            server_id INTEGER,
            title TEXT,
            koan LONGTEXT,
            status BOOLEAN DEFAULT 1,
            date DATE
        );
      ''');
  }

  Future<void> insertKoan(Koan koan) async {
    final db = await _databaseService.database;
    await db.insert(
      'koans',
      koan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Koan?> getActiveKoan() async {
    final db = await _databaseService.database;
    List<Map<String, dynamic>> maps = await db.query(
      'koans',
      where: 'status = ?',
      whereArgs: [1], // 1 represents the status you want to filter by
    );

    // If there are no active koans, return null
    if (maps.isEmpty) {
      return null;
    }

    // Convert the first Map<String, dynamic> to a Koan
    return Koan(
      id: maps[0]['id'],
      title: maps[0]['title'],
      koan: maps[0]['koan'],
      status: maps[0]['status'], // Convert 1 to true
      date: maps[0]['date'], // Assuming 'date' is a DateTime field
    );
  }

  Future<void> insertKoanAndUpdate(Koan koan) async {
    final db = await _databaseService.database;
    final batch = db.batch();

    // Insert the new Koan with status 1
    batch.insert(
      'koans',
      koan.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Update the status of all other Koans to 0
    batch.update(
      'koans',
      {'status': 0},
      where: 'id != ?',
      whereArgs: [koan.id],
    );

    await batch.commit(noResult: true);
  }
}
