import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/job.dart';
import '../models/inspection_item.dart';
import '../models/attachment.dart';
import 'performance_monitor.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static const int _databaseVersion = 2;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('rampcheck.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        aircraft_registration TEXT,
        status TEXT NOT NULL DEFAULT 'open',
        priority TEXT NOT NULL DEFAULT 'medium',
        assigned_technician_id INTEGER,
        created_by INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        completed_at TEXT,
        needs_sync INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE inspection_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        is_completed INTEGER DEFAULT 0,
        notes TEXT,
        completed_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        needs_sync INTEGER DEFAULT 0,
        FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        job_id INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        created_at TEXT NOT NULL,
        needs_sync INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE attachments (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          job_id INTEGER NOT NULL,
          file_name TEXT NOT NULL,
          file_path TEXT NOT NULL,
          file_type TEXT NOT NULL,
          created_at TEXT NOT NULL,
          needs_sync INTEGER NOT NULL DEFAULT 1,
          FOREIGN KEY (job_id) REFERENCES jobs (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // Jobs CRUD
  Future<int> createJob(Job job) async {
    return PerformanceMonitor.measure('DB: createJob', () async {
      final db = await database;
      return await db.insert('jobs', job.toMap());
    });
  }

  Future<List<Job>> getAllJobs() async {
    return PerformanceMonitor.measure('DB: getAllJobs', () async {
      final db = await database;
      final maps = await db.query('jobs', orderBy: 'created_at DESC');
      return maps.map((map) => Job.fromMap(map)).toList();
    });
  }

  Future<Job?> getJob(int id) async {
    return PerformanceMonitor.measure('DB: getJob', () async {
      final db = await database;
      final maps = await db.query('jobs', where: 'id = ?', whereArgs: [id]);
      if (maps.isEmpty) return null;
      return Job.fromMap(maps.first);
    });
  }

  Future<int> updateJob(Job job) async {
    return PerformanceMonitor.measure('DB: updateJob', () async {
      final db = await database;
      return await db.update(
        'jobs',
        job.toMap(),
        where: 'id = ?',
        whereArgs: [job.id],
      );
    });
  }

  Future<int> deleteJob(int id) async {
    final db = await database;
    return await db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }

  // Inspection Items CRUD
  Future<int> createInspectionItem(InspectionItem item) async {
    final db = await database;
    return await db.insert('inspection_items', item.toMap());
  }

  Future<List<InspectionItem>> getInspectionItemsForJob(int jobId) async {
    return PerformanceMonitor.measure('DB: getInspectionItemsForJob', () async {
      final db = await database;
      final maps = await db.query(
        'inspection_items',
        where: 'job_id = ?',
        whereArgs: [jobId],
        orderBy: 'created_at ASC',
      );
      return maps.map((map) => InspectionItem.fromMap(map)).toList();
    });
  }

  Future<int> updateInspectionItem(InspectionItem item) async {
    final db = await database;
    return await db.update(
      'inspection_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteInspectionItem(int id) async {
    final db = await database;
    return await db.delete(
      'inspection_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Attachments CRUD
  Future<int> createAttachment(Attachment attachment) async {
    final db = await database;
    return await db.insert('attachments', attachment.toMap());
  }

  Future<List<Attachment>> getAttachmentsForJob(int jobId) async {
    final db = await database;
    final maps = await db.query(
      'attachments',
      where: 'job_id = ?',
      whereArgs: [jobId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => Attachment.fromMap(map)).toList();
  }

  Future<int> deleteAttachment(int id) async {
    final db = await database;
    return await db.delete('attachments', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Attachment>> getAttachmentsNeedingSync() async {
    final db = await database;
    final maps = await db.query(
      'attachments',
      where: 'needs_sync = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Attachment.fromMap(map)).toList();
  }

  // Sync
  Future<List<Job>> getJobsNeedingSync() async {
    final db = await database;
    final maps = await db.query(
      'jobs',
      where: 'needs_sync = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Job.fromMap(map)).toList();
  }

  Future<List<InspectionItem>> getInspectionItemsNeedingSync() async {
    final db = await database;
    final maps = await db.query(
      'inspection_items',
      where: 'needs_sync = ?',
      whereArgs: [1],
    );
    return maps.map((map) => InspectionItem.fromMap(map)).toList();
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
