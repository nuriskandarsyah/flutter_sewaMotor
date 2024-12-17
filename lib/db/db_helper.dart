import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'package:flutter_sewa_motor/sewa_motor.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sewa_motor.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE sewa_motor (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_penyewa TEXT NOT NULL,
            nama_motor TEXT NOT NULL,
            durasi INTEGER NOT NULL,
            total_bayar REAL NOT NULL
          )
        ''');
      },
    );
  }

  Future<List<Map<String, dynamic>>> getSewaMotor() async {
    final db = await database;
    return await db.query('sewa_motor');
  }

  Future<int> addSewaMotor(SewaMotor sewaMotor) async {
    final db = await database;
    return await db.insert(
      'sewa_motor',
      sewaMotor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateSewaMotor(SewaMotor sewaMotor) async {
    final db = await database;
    return await db.update(
      'sewa_motor',
      sewaMotor.toMap(),
      where: 'id = ?',
      whereArgs: [sewaMotor.id],
    );
  }

  Future<int> deleteSewaMotor(int id) async {
    final db = await database;
    return await db.delete(
      'sewa_motor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
