import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity.dart';
import '../models/category.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'streakify.db');

    return await openDatabase(
      path,
      version: 4, // Incrementamos para personalización visual
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabla de categorías
    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        iconCodePoint INTEGER NOT NULL,
        colorValue INTEGER NOT NULL
      )
    ''');

    // Tabla de actividades (con categoryId, tags, notificaciones y personalización)
    await db.execute('''
      CREATE TABLE activities (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        streak INTEGER NOT NULL DEFAULT 0,
        lastCompleted TEXT,
        nextProtectorAvailable TEXT,
        active INTEGER NOT NULL DEFAULT 1,
        protectorUsed INTEGER NOT NULL DEFAULT 0,
        categoryId TEXT,
        tags TEXT,
        notificationsEnabled INTEGER NOT NULL DEFAULT 0,
        notificationHour INTEGER NOT NULL DEFAULT 20,
        notificationMinute INTEGER NOT NULL DEFAULT 0,
        customMessage TEXT,
        customIcon TEXT,
        customColor TEXT,
        displayOrder INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');

    // Crear índices para mejorar el rendimiento
    await db
        .execute('CREATE INDEX idx_activities_active ON activities(active)');
    await db.execute(
        'CREATE INDEX idx_activities_streak ON activities(streak DESC)');
    await db.execute(
        'CREATE INDEX idx_activities_updated ON activities(updatedAt DESC)');
    await db.execute(
        'CREATE INDEX idx_activities_category ON activities(categoryId)');

    // Insertar categorías predefinidas
    await _insertDefaultCategories(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Crear tabla de categorías
      await db.execute('''
        CREATE TABLE categories (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          iconCodePoint INTEGER NOT NULL,
          colorValue INTEGER NOT NULL
        )
      ''');

      // Agregar columnas nuevas a activities
      await db.execute('ALTER TABLE activities ADD COLUMN categoryId TEXT');
      await db.execute('ALTER TABLE activities ADD COLUMN tags TEXT');

      // Crear índice para categoryId
      await db.execute(
          'CREATE INDEX idx_activities_category ON activities(categoryId)');

      // Insertar categorías predefinidas
      await _insertDefaultCategories(db);
    }

    if (oldVersion < 3) {
      // Agregar columnas de notificaciones
      await db.execute(
          'ALTER TABLE activities ADD COLUMN notificationsEnabled INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN notificationHour INTEGER NOT NULL DEFAULT 20');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN notificationMinute INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE activities ADD COLUMN customMessage TEXT');
    }

    if (oldVersion < 4) {
      // Agregar columnas de personalización visual
      await db.execute('ALTER TABLE activities ADD COLUMN customIcon TEXT');
      await db.execute('ALTER TABLE activities ADD COLUMN customColor TEXT');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN displayOrder INTEGER NOT NULL DEFAULT 0');
    }
  }

  Future<void> _insertDefaultCategories(Database db) async {
    for (var category in PredefinedCategories.defaults) {
      await db.insert(
        'categories',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  // CRUD Operations - Activities

  /// Insertar una nueva actividad
  Future<int> insertActivity(Activity activity) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();

    final map = activity.toMap();
    map['createdAt'] = now;
    map['updatedAt'] = now;

    return await db.insert(
      'activities',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtener todas las actividades
  Future<List<Activity>> getAllActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      orderBy: 'updatedAt DESC',
    );

    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  /// Obtener una actividad por ID
  Future<Activity?> getActivity(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Activity.fromMap(maps.first);
  }

  /// Obtener solo actividades activas
  Future<List<Activity>> getActiveActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'active = ?',
      whereArgs: [1],
      orderBy: 'streak DESC',
    );

    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  /// Actualizar una actividad
  Future<int> updateActivity(Activity activity) async {
    final db = await database;
    final map = activity.toMap();
    map['updatedAt'] = DateTime.now().toIso8601String();

    return await db.update(
      'activities',
      map,
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  /// Eliminar una actividad
  Future<int> deleteActivity(String id) async {
    final db = await database;
    return await db.delete(
      'activities',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Eliminar todas las actividades (útil para testing)
  Future<int> deleteAllActivities() async {
    final db = await database;
    return await db.delete('activities');
  }

  /// Obtener estadísticas rápidas
  Future<Map<String, dynamic>> getStatistics() async {
    final db = await database;

    final totalCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM activities'),
        ) ??
        0;

    final activeCount = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM activities WHERE active = 1'),
        ) ??
        0;

    final maxStreak = Sqflite.firstIntValue(
          await db
              .rawQuery('SELECT MAX(streak) FROM activities WHERE active = 1'),
        ) ??
        0;

    final totalStreakDays = Sqflite.firstIntValue(
          await db.rawQuery('SELECT SUM(streak) FROM activities'),
        ) ??
        0;

    return {
      'totalActivities': totalCount,
      'activeActivities': activeCount,
      'maxStreak': maxStreak,
      'totalStreakDays': totalStreakDays,
    };
  }

  /// Buscar actividades por nombre
  /// Buscar actividades por nombre
  Future<List<Activity>> searchActivities(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'streak DESC',
    );

    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  /// Obtener actividades por categoría
  Future<List<Activity>> getActivitiesByCategory(String categoryId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'streak DESC',
    );

    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  /// Obtener actividades por tag
  Future<List<Activity>> getActivitiesByTag(String tag) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'tags LIKE ?',
      whereArgs: ['%"$tag"%'],
      orderBy: 'streak DESC',
    );

    return List.generate(maps.length, (i) => Activity.fromMap(maps[i]));
  }

  // CRUD Operations - Categories

  /// Obtener todas las categorías
  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('categories');
    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
  }

  /// Obtener una categoría por ID
  Future<Category?> getCategory(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Category.fromMap(maps.first);
  }

  /// Insertar una nueva categoría
  Future<int> insertCategory(Category category) async {
    final db = await database;
    return await db.insert(
      'categories',
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualizar una categoría
  Future<int> updateCategory(Category category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// Eliminar una categoría
  Future<int> deleteCategory(String id) async {
    final db = await database;
    // Primero, eliminar la referencia de categoryId en actividades
    await db.update(
      'activities',
      {'categoryId': null},
      where: 'categoryId = ?',
      whereArgs: [id],
    );
    // Luego eliminar la categoría
    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Cerrar la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
