import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/detection_model.dart';

class SqliteService {
  SqliteService._();
  static final SqliteService instance = SqliteService._();

  static Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'object_finder.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE detections (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            label           TEXT    NOT NULL,
            label_traduit   TEXT    NOT NULL,
            confidence      REAL    NOT NULL,
            distance_meters REAL    NOT NULL,
            danger_level    TEXT    NOT NULL,
            voice_message   TEXT    NOT NULL,
            timestamp       TEXT    NOT NULL,
            synced          INTEGER NOT NULL DEFAULT 0
        )
      ''');
      },
    );
  }

  // ─── Scanner appelle ça après chaque détection
  Future<void> insertDetection(DetectionModel detection) async {
    final database = await db;
    await database.insert(
      'detections',
      detection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ─── History appelle ça pour afficher la liste
  Future<List<DetectionModel>> getAllDetections() async {
    final database = await db;
    final rows = await database.query('detections', orderBy: 'timestamp DESC');
    return rows.map(DetectionModel.fromMap).toList();
  }

  // ─── Sync backend
  Future<List<DetectionModel>> getUnsyncedDetections() async {
    final database = await db;
    final rows = await database.query(
      'detections',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return rows.map(DetectionModel.fromMap).toList();
  }

  Future<void> markAsSynced(int id) async {
    final database = await db;
    await database.update(
      'detections',
      {'synced': 1},
      where:     'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> clearAll() async {
    final database = await db;
    await database.delete('detections');
  }
}
