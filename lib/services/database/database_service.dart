import 'package:koan/models/common/koan.dart';
import 'package:koan/models/streak.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

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
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final databasepath = await getDatabasesPath();

    final path = join(databasepath, 'koan.db');

    print("db path: $path");
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

    await db.execute('''
            CREATE TABLE streaks(
              id INTEGER PRIMARY KEY,
              count INTEGER
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

  Future<List<Koan>> getAllKoans() async {
    final db = await _databaseService.database;
    List<Map<String, dynamic>> maps = await db.query('koans');

    List<Koan> koans = List.generate(maps.length, (i) {
      return Koan(
        id: maps[i]['id'],
        title: maps[i]['title'],
        koan: maps[i]['koan'],
        status: maps[i]['status'],
        date: maps[i]['date'], //
      );
    });

    return koans;
  }

  Future<List<int>> getAllServerIds() async {
    final db = await _databaseService.database;
    List<Map<String, dynamic>> maps =
        await db.query('koans', columns: ['server_id']);

    // Extract the server_id values from the result maps
    List<int> serverIds = maps.map((map) => map['server_id'] as int).toList();

    return serverIds;
  }

  Future<void> insertKoanAndUpdate(Koan koan) async {
    final db = await _databaseService.database;
    final batch = db.batch();

    // Insert the new Koan
    await db.transaction((txn) async {
      final insertedKoanId = await txn.insert(
        'koans',
        koan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Update the status of other records to 0 where id is not equal to the new Koan's ID
      await txn.update(
        'koans',
        {'status': 0},
        where: 'id != ?',
        whereArgs: [insertedKoanId],
      );
    });
  }

  Future<void> insertStreak(Streak streak) async {
    final db = await _databaseService.database;
    await db.insert(
      'streaks',
      streak.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateStreak(Streak streak) async {
    final db = await _databaseService.database;

    await db.update(
      'streaks',
      streak.toMap(),
      where: 'id = ?',
      whereArgs: [streak.id],
    );
  }

  Future<Streak?> getStreak() async {
    final db = await _databaseService.database;
    List<Map<String, dynamic>> maps = await db.query('streaks');

    if (maps.isEmpty) {
      return null;
    }

    return Streak(
      id: maps[0]['id'],
      count: maps[0]['count'],
    );
  }
}
