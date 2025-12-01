import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../models/completion_history.dart';

import '../models/notification_preferences.dart';
import '../models/user_profile.dart';
import '../models/buddy.dart';
import '../models/accountability_group.dart';

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
      version: 11, // Social features
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
        recurrenceType TEXT NOT NULL DEFAULT 'daily',
        recurrenceInterval INTEGER NOT NULL DEFAULT 1,
        recurrenceDays TEXT,
        startDate TEXT,
        targetDays INTEGER,
        isArchived INTEGER NOT NULL DEFAULT 0,
        allowedFailures INTEGER NOT NULL DEFAULT 0,
        weeklyFailureCount INTEGER NOT NULL DEFAULT 0,
        freeDays TEXT,
        partialGoalRequired INTEGER,
        partialGoalTotal INTEGER,
        weeklyCompletionCount INTEGER NOT NULL DEFAULT 0,
        dailyCompletionCount INTEGER NOT NULL DEFAULT 0,
        dailyGoal INTEGER NOT NULL DEFAULT 1,
        isFrozen INTEGER NOT NULL DEFAULT 0,
        frozenUntil TEXT,
        freezeReason TEXT,
        streakPoints INTEGER NOT NULL DEFAULT 0,
        monthlyProtectorUses INTEGER NOT NULL DEFAULT 0,
        lastProtectorReset TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories(id)
      )
    ''');

    // Tabla de historial de completaciones
    await db.execute('''
      CREATE TABLE completion_history (
        id TEXT PRIMARY KEY,
        activityId TEXT NOT NULL,
        completedAt TEXT NOT NULL,
        notes TEXT,
        protectorUsed INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (activityId) REFERENCES activities(id) ON DELETE CASCADE
      )
    ''');

    // Tabla de protectores
    await db.execute('''
      CREATE TABLE protectors (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        source TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        usedAt TEXT,
        activityId TEXT,
        isActive INTEGER NOT NULL DEFAULT 0,
        expiresAt TEXT,
        FOREIGN KEY (activityId) REFERENCES activities(id) ON DELETE SET NULL
      )
    ''');

    // Tabla de historial de uso de protectores
    await db.execute('''
      CREATE TABLE protector_history (
        id TEXT PRIMARY KEY,
        protectorId TEXT NOT NULL,
        activityId TEXT NOT NULL,
        usedAt TEXT NOT NULL,
        protectorType TEXT NOT NULL,
        daysProtected INTEGER NOT NULL,
        FOREIGN KEY (protectorId) REFERENCES protectors(id) ON DELETE CASCADE,
        FOREIGN KEY (activityId) REFERENCES activities(id) ON DELETE CASCADE
      )
    ''');

    // Tabla de recuperaciones de racha
    await db.execute('''
      CREATE TABLE streak_recoveries (
        id TEXT PRIMARY KEY,
        activityId TEXT NOT NULL,
        originalStreak INTEGER NOT NULL,
        recoveredStreak INTEGER NOT NULL,
        penaltyDays INTEGER NOT NULL,
        penaltyPercentage REAL NOT NULL,
        lostAt TEXT NOT NULL,
        recoveredAt TEXT NOT NULL,
        pointsCost INTEGER NOT NULL,
        FOREIGN KEY (activityId) REFERENCES activities(id) ON DELETE CASCADE
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
    await db.execute(
        'CREATE INDEX idx_completion_activity ON completion_history(activityId)');
    await db.execute(
        'CREATE INDEX idx_completion_date ON completion_history(completedAt DESC)');
    await db.execute(
        'CREATE INDEX idx_protectors_activity ON protectors(activityId)');
    await db
        .execute('CREATE INDEX idx_protectors_active ON protectors(isActive)');
    await db.execute(
        'CREATE INDEX idx_protector_history_activity ON protector_history(activityId)');
    await db.execute(
        'CREATE INDEX idx_streak_recoveries_activity ON streak_recoveries(activityId)');

    // Tabla de preferencias de notificaciones
    await db.execute('''
      CREATE TABLE notification_preferences (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        contextualNotificationsEnabled INTEGER NOT NULL DEFAULT 1,
        riskAlertsEnabled INTEGER NOT NULL DEFAULT 1,
        riskAlertHoursBefore INTEGER NOT NULL DEFAULT 2,
        dailySummaryEnabled INTEGER NOT NULL DEFAULT 1,
        morningSummaryHour INTEGER NOT NULL DEFAULT 8,
        morningSummaryMinute INTEGER NOT NULL DEFAULT 0,
        eveningSummaryHour INTEGER NOT NULL DEFAULT 20,
        eveningSummaryMinute INTEGER NOT NULL DEFAULT 0,
        motivationalQuotesEnabled INTEGER NOT NULL DEFAULT 1,
        achievementNotificationsEnabled INTEGER NOT NULL DEFAULT 1,
        progressiveRemindersEnabled INTEGER NOT NULL DEFAULT 1,
        firstReminderHour INTEGER NOT NULL DEFAULT 12,
        secondReminderHour INTEGER NOT NULL DEFAULT 18,
        finalReminderHour INTEGER NOT NULL DEFAULT 22,
        doNotDisturbEnabled INTEGER NOT NULL DEFAULT 0,
        doNotDisturbStartHour INTEGER NOT NULL DEFAULT 22,
        doNotDisturbStartMinute INTEGER NOT NULL DEFAULT 0,
        doNotDisturbEndHour INTEGER NOT NULL DEFAULT 7,
        doNotDisturbEndMinute INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Insertar preferencias por defecto
    await db.insert('notification_preferences', {
      'id': 1,
      'contextualNotificationsEnabled': 1,
      'riskAlertsEnabled': 1,
      'riskAlertHoursBefore': 2,
      'dailySummaryEnabled': 1,
      'morningSummaryHour': 8,
      'morningSummaryMinute': 0,
      'eveningSummaryHour': 20,
      'eveningSummaryMinute': 0,
      'motivationalQuotesEnabled': 1,
      'achievementNotificationsEnabled': 1,
      'progressiveRemindersEnabled': 1,
      'firstReminderHour': 12,
      'secondReminderHour': 18,
      'finalReminderHour': 22,
      'doNotDisturbEnabled': 0,
      'doNotDisturbStartHour': 22,
      'doNotDisturbStartMinute': 0,
      'doNotDisturbEndHour': 7,
      'doNotDisturbEndMinute': 0,
    });

    // Tabla de perfil de usuario
    await db.execute('''
      CREATE TABLE user_profile (
        id TEXT PRIMARY KEY,
        username TEXT,
        displayName TEXT,
        avatarUrl TEXT,
        bio TEXT,
        isPublic INTEGER DEFAULT 1,
        totalStreaks INTEGER DEFAULT 0,
        currentStreak INTEGER DEFAULT 0,
        totalXp INTEGER DEFAULT 0,
        badges TEXT,
        joinedDate TEXT
      )
    ''');

    // Tabla de buddies
    await db.execute('''
      CREATE TABLE buddies (
        id TEXT PRIMARY KEY,
        userId TEXT,
        name TEXT,
        avatarUrl TEXT,
        currentStreak INTEGER DEFAULT 0,
        status TEXT,
        lastInteraction TEXT
      )
    ''');

    // Tabla de grupos de accountability
    await db.execute('''
      CREATE TABLE accountability_groups (
        id TEXT PRIMARY KEY,
        name TEXT,
        description TEXT,
        iconUrl TEXT,
        memberCount INTEGER DEFAULT 1,
        totalGroupStreak INTEGER DEFAULT 0,
        createdDate TEXT
      )
    ''');

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

    if (oldVersion < 5) {
      // Crear tabla de historial de completaciones
      await db.execute('''
        CREATE TABLE completion_history (
          id TEXT PRIMARY KEY,
          activityId TEXT NOT NULL,
          completedAt TEXT NOT NULL,
          notes TEXT,
          protectorUsed INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (activityId) REFERENCES activities(id) ON DELETE CASCADE
        )
      ''');

      // Crear índices para el historial
      await db.execute(
          'CREATE INDEX idx_completion_activity ON completion_history(activityId)');
      await db.execute(
          'CREATE INDEX idx_completion_date ON completion_history(completedAt DESC)');
    }

    if (oldVersion < 6) {
      // Agregar columnas de recurrencia
      await db.execute(
          'ALTER TABLE activities ADD COLUMN recurrenceType TEXT NOT NULL DEFAULT \'daily\'');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN recurrenceInterval INTEGER NOT NULL DEFAULT 1');
      await db.execute('ALTER TABLE activities ADD COLUMN recurrenceDays TEXT');
      await db.execute('ALTER TABLE activities ADD COLUMN startDate TEXT');
    }

    if (oldVersion < 7) {
      // Agregar columnas para metas, archivado y rachas flexibles
      await db.execute('ALTER TABLE activities ADD COLUMN targetDays INTEGER');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN isArchived INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN allowedFailures INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN weeklyFailureCount INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE activities ADD COLUMN freeDays TEXT');
    }

    if (oldVersion < 8) {
      // Agregar columnas para rachas parciales, múltiples completaciones y freeze
      await db.execute(
          'ALTER TABLE activities ADD COLUMN partialGoalRequired INTEGER');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN partialGoalTotal INTEGER');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN weeklyCompletionCount INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN dailyCompletionCount INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN dailyGoal INTEGER NOT NULL DEFAULT 1');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN isFrozen INTEGER NOT NULL DEFAULT 0');
      await db.execute('ALTER TABLE activities ADD COLUMN frozenUntil TEXT');
      await db.execute('ALTER TABLE activities ADD COLUMN freezeReason TEXT');
    }

    if (oldVersion < 9) {
      // Agregar columnas para sistema avanzado de protectores
      await db.execute(
          'ALTER TABLE activities ADD COLUMN streakPoints INTEGER NOT NULL DEFAULT 0');
      await db.execute(
          'ALTER TABLE activities ADD COLUMN monthlyProtectorUses INTEGER NOT NULL DEFAULT 0');
      await db
          .execute('ALTER TABLE activities ADD COLUMN lastProtectorReset TEXT');

      // Crear tabla de protectores
      await db.execute('''
        CREATE TABLE protectors (
          id TEXT PRIMARY KEY,
          type TEXT NOT NULL,
          source TEXT NOT NULL,
          createdAt TEXT NOT NULL,
          usedAt TEXT,
          activityId TEXT,
          isActive INTEGER NOT NULL DEFAULT 0,
          expiresAt TEXT,
          FOREIGN KEY (activityId) REFERENCES activities(id) ON DELETE SET NULL
        )
      ''');

      // Crear tabla de historial de protectores
      await db.execute('''
        CREATE TABLE protector_history (
          id TEXT PRIMARY KEY,
          protectorId TEXT NOT NULL,
          activityId TEXT NOT NULL,
          usedAt TEXT NOT NULL,
          protectorType TEXT NOT NULL,
          daysProtected INTEGER NOT NULL,
          FOREIGN KEY (protectorId) REFERENCES protectors(id) ON DELETE CASCADE,
          FOREIGN KEY (activityId) REFERENCES activities(id) ON DELETE CASCADE
        )
      ''');

      // Crear tabla de recuperaciones de racha
      await db.execute('''
        CREATE TABLE streak_recoveries (
          id TEXT PRIMARY KEY,
          activityId TEXT NOT NULL,
          originalStreak INTEGER NOT NULL,
          recoveredStreak INTEGER NOT NULL,
          penaltyDays INTEGER NOT NULL,
          penaltyPercentage REAL NOT NULL,
          lostAt TEXT NOT NULL,
          recoveredAt TEXT NOT NULL,
          pointsCost INTEGER NOT NULL,
          FOREIGN KEY (activityId) REFERENCES activities(id) ON DELETE CASCADE
        )
      ''');

      // Crear índices
      await db.execute(
          'CREATE INDEX idx_protectors_activity ON protectors(activityId)');
      await db.execute(
          'CREATE INDEX idx_protectors_active ON protectors(isActive)');
      await db.execute(
          'CREATE INDEX idx_protector_history_activity ON protector_history(activityId)');
      await db.execute(
          'CREATE INDEX idx_streak_recoveries_activity ON streak_recoveries(activityId)');
    }

    if (oldVersion < 10) {
      // Crear tabla de preferencias de notificaciones
      await db.execute('''
        CREATE TABLE notification_preferences (
          id INTEGER PRIMARY KEY CHECK (id = 1),
          contextualNotificationsEnabled INTEGER NOT NULL DEFAULT 1,
          riskAlertsEnabled INTEGER NOT NULL DEFAULT 1,
          riskAlertHoursBefore INTEGER NOT NULL DEFAULT 2,
          dailySummaryEnabled INTEGER NOT NULL DEFAULT 1,
          morningSummaryHour INTEGER NOT NULL DEFAULT 8,
          morningSummaryMinute INTEGER NOT NULL DEFAULT 0,
          eveningSummaryHour INTEGER NOT NULL DEFAULT 20,
          eveningSummaryMinute INTEGER NOT NULL DEFAULT 0,
          motivationalQuotesEnabled INTEGER NOT NULL DEFAULT 1,
          achievementNotificationsEnabled INTEGER NOT NULL DEFAULT 1,
          progressiveRemindersEnabled INTEGER NOT NULL DEFAULT 1,
          firstReminderHour INTEGER NOT NULL DEFAULT 12,
          secondReminderHour INTEGER NOT NULL DEFAULT 18,
          finalReminderHour INTEGER NOT NULL DEFAULT 22,
          doNotDisturbEnabled INTEGER NOT NULL DEFAULT 0,
          doNotDisturbStartHour INTEGER NOT NULL DEFAULT 22,
          doNotDisturbStartMinute INTEGER NOT NULL DEFAULT 0,
          doNotDisturbEndHour INTEGER NOT NULL DEFAULT 7,
          doNotDisturbEndMinute INTEGER NOT NULL DEFAULT 0
        )
      ''');

      // Insertar preferencias por defecto
      await db.insert('notification_preferences', {
        'id': 1,
        'contextualNotificationsEnabled': 1,
        'riskAlertsEnabled': 1,
        'riskAlertHoursBefore': 2,
        'dailySummaryEnabled': 1,
        'morningSummaryHour': 8,
        'morningSummaryMinute': 0,
        'eveningSummaryHour': 20,
        'eveningSummaryMinute': 0,
        'motivationalQuotesEnabled': 1,
        'achievementNotificationsEnabled': 1,
        'progressiveRemindersEnabled': 1,
        'firstReminderHour': 12,
        'secondReminderHour': 18,
        'finalReminderHour': 22,
        'doNotDisturbEnabled': 0,
        'doNotDisturbStartHour': 22,
        'doNotDisturbStartMinute': 0,
        'doNotDisturbEndHour': 7,
        'doNotDisturbEndMinute': 0,
      });
    }

    if (oldVersion < 11) {
      // Crear tablas para features sociales
      await db.execute('''
        CREATE TABLE user_profile (
          id TEXT PRIMARY KEY,
          username TEXT,
          displayName TEXT,
          avatarUrl TEXT,
          bio TEXT,
          isPublic INTEGER DEFAULT 1,
          totalStreaks INTEGER DEFAULT 0,
          currentStreak INTEGER DEFAULT 0,
          totalXp INTEGER DEFAULT 0,
          badges TEXT,
          joinedDate TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE buddies (
          id TEXT PRIMARY KEY,
          userId TEXT,
          name TEXT,
          avatarUrl TEXT,
          currentStreak INTEGER DEFAULT 0,
          status TEXT,
          lastInteraction TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE accountability_groups (
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          iconUrl TEXT,
          memberCount INTEGER DEFAULT 1,
          totalGroupStreak INTEGER DEFAULT 0,
          createdDate TEXT
        )
      ''');
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

  /// Obtener actividades con paginación
  Future<List<Activity>> getActivitiesWithPagination(
      int limit, int offset) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      orderBy: 'updatedAt DESC',
      limit: limit,
      offset: offset,
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

  /// Obtener solo actividades inactivas
  Future<List<Activity>> getInactiveActivities() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'activities',
      where: 'active = ?',
      whereArgs: [0],
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

  /// Obtener todas las categorías
  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'categories',
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) => Category.fromMap(maps[i]));
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

  // CRUD Operations - Completion History

  /// Insertar una completación en el historial
  Future<int> insertCompletion(CompletionHistory completion) async {
    final db = await database;
    return await db.insert(
      'completion_history',
      completion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualizar nota de una completación
  Future<int> updateCompletionNote(String completionId, String note) async {
    final db = await database;
    return await db.update(
      'completion_history',
      {'notes': note},
      where: 'id = ?',
      whereArgs: [completionId],
    );
  }

  /// Obtener completaciones en un rango de fechas
  Future<List<CompletionHistory>> getCompletionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'completion_history',
      where: 'completedAt >= ? AND completedAt <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'completedAt DESC',
    );
    return List.generate(
        maps.length, (i) => CompletionHistory.fromMap(maps[i]));
  }

  /// Obtener completaciones en un rango de fechas (alias para compatibilidad)
  Future<List<CompletionHistory>> getCompletionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    return getCompletionsByDateRange(start, end);
  }

  /// Eliminar completación
  Future<int> deleteCompletion(String id) async {
    final db = await database;
    return await db.delete(
      'completion_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Eliminar todas las completaciones de una actividad
  Future<int> deleteCompletionsByActivity(String activityId) async {
    final db = await database;
    return await db.delete(
      'completion_history',
      where: 'activityId = ?',
      whereArgs: [activityId],
    );
  }

  /// Obtener historial de completaciones de una actividad
  Future<List<CompletionHistory>> getCompletionHistory(
      String activityId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'completion_history',
      where: 'activityId = ?',
      whereArgs: [activityId],
      orderBy: 'completedAt DESC',
    );
    return List.generate(
        maps.length, (i) => CompletionHistory.fromMap(maps[i]));
  }

  /// Obtener todas las completaciones
  Future<List<CompletionHistory>> getAllCompletions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'completion_history',
      orderBy: 'completedAt DESC',
    );
    return List.generate(
        maps.length, (i) => CompletionHistory.fromMap(maps[i]));
  }

  // CRUD Operations - Notification Preferences

  /// Obtener preferencias de notificaciones
  Future<NotificationPreferences> getNotificationPreferences() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notification_preferences',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (maps.isEmpty) {
      // Si no existen, crear preferencias por defecto
      final prefs = NotificationPreferences();
      await saveNotificationPreferences(prefs);
      return prefs;
    }

    return NotificationPreferences.fromMap(maps.first);
  }

  /// Guardar preferencias de notificaciones
  Future<int> saveNotificationPreferences(NotificationPreferences prefs) async {
    final db = await database;
    final map = prefs.toMap();
    map['id'] = 1; // Siempre usar ID 1 (solo hay un registro)

    return await db.insert(
      'notification_preferences',
      map,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Actualizar preferencias de notificaciones
  Future<int> updateNotificationPreferences(
      NotificationPreferences prefs) async {
    final db = await database;
    final map = prefs.toMap();

    return await db.update(
      'notification_preferences',
      map,
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // --- SOCIAL FEATURES ---

  // User Profile
  Future<UserProfile?> getUserProfile() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_profile',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return UserProfile.fromMap(maps.first);
  }

  Future<int> insertOrUpdateUserProfile(UserProfile profile) async {
    final db = await database;
    return await db.insert(
      'user_profile',
      profile.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Buddies
  Future<List<Buddy>> getBuddies() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('buddies');
    return List.generate(maps.length, (i) => Buddy.fromMap(maps[i]));
  }

  Future<int> insertBuddy(Buddy buddy) async {
    final db = await database;
    return await db.insert(
      'buddies',
      buddy.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateBuddy(Buddy buddy) async {
    final db = await database;
    return await db.update(
      'buddies',
      buddy.toMap(),
      where: 'id = ?',
      whereArgs: [buddy.id],
    );
  }

  Future<int> deleteBuddy(String id) async {
    final db = await database;
    return await db.delete(
      'buddies',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Accountability Groups
  Future<List<AccountabilityGroup>> getAccountabilityGroups() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('accountability_groups');
    return List.generate(
        maps.length, (i) => AccountabilityGroup.fromMap(maps[i]));
  }

  Future<int> insertAccountabilityGroup(AccountabilityGroup group) async {
    final db = await database;
    return await db.insert(
      'accountability_groups',
      group.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateAccountabilityGroup(AccountabilityGroup group) async {
    final db = await database;
    return await db.update(
      'accountability_groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<int> deleteAccountabilityGroup(String id) async {
    final db = await database;
    return await db.delete(
      'accountability_groups',
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

  // ============================================
  // FUNCIONES DE DESARROLLO - SOLO PARA TESTING
  // ============================================

  /// Inyectar datos de prueba para TC-ACT-012 y TC-ACT-013
  /// ADVERTENCIA: Esto modifica directamente la base de datos
  Future<void> injectTestData() async {
    final db = await database;

    print('🧪 [TEST] Inyectando datos de prueba...');

    // Buscar la actividad "Test Ejercicio"
    final activities = await db.query(
      'activities',
      where: 'name = ?',
      whereArgs: ['Test Ejercicio'],
      limit: 1,
    );

    if (activities.isEmpty) {
      print('❌ [TEST] No se encontró la actividad "Test Ejercicio"');
      return;
    }

    final activityId = activities.first['id'] as String;
    final now = DateTime.now();

    // TC-ACT-012: Actividad completada ayer con racha = 5
    final yesterday = now.subtract(const Duration(days: 1));

    print('📝 [TEST] Configurando TC-ACT-012: racha=5, completada ayer');
    await db.update(
      'activities',
      {
        'streak': 5,
        'lastCompleted': yesterday.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [activityId],
    );

    // Insertar historial de completaciones para los últimos 5 días
    for (int i = 0; i < 5; i++) {
      final completionDate = yesterday.subtract(Duration(days: i));
      await db.insert(
        'completion_history',
        {
          'id': 'test_completion_${i}_${DateTime.now().millisecondsSinceEpoch}',
          'activityId': activityId,
          'completedAt': completionDate.toIso8601String(),
          'notes': 'Datos de prueba TC-ACT-012',
          'protectorUsed': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    print('✅ [TEST] Datos inyectados exitosamente');
    print('   - Actividad: Test Ejercicio');
    print('   - Racha actual: 5');
    print('   - Última completación: ${yesterday.toString().substring(0, 10)}');
    print('   - Historial: 5 completaciones consecutivas');
    print('');
    print('🎯 [TEST] Ahora puedes ejecutar TC-ACT-012:');
    print('   1. Completa "Test Ejercicio" HOY');
    print('   2. Verifica que la racha incrementa de 5 a 6');
  }

  /// Preparar datos para TC-ACT-013 (completar después de saltar un día)
  Future<void> injectTestDataTC013() async {
    final db = await database;

    print('🧪 [TEST] Inyectando datos para TC-ACT-013...');

    // Buscar o crear actividad "Test Salto"
    var activities = await db.query(
      'activities',
      where: 'name = ?',
      whereArgs: ['Test Salto'],
      limit: 1,
    );

    String activityId;
    if (activities.isEmpty) {
      // Crear nueva actividad
      activityId = 'test_salto_${DateTime.now().millisecondsSinceEpoch}';
      await db.insert(
        'activities',
        {
          'id': activityId,
          'name': 'Test Salto',
          'streak': 3,
          'active': 1,
          'protectorUsed': 0,
          'notificationsEnabled': 0,
          'notificationHour': 20,
          'notificationMinute': 0,
          'displayOrder': 999,
          'recurrenceType': 'daily',
          'recurrenceInterval': 1,
          'allowedFailures': 0,
          'weeklyFailureCount': 0,
          'weeklyCompletionCount': 0,
          'dailyCompletionCount': 0,
          'dailyGoal': 1,
          'isFrozen': 0,
          'streakPoints': 0,
          'monthlyProtectorUses': 0,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('📝 [TEST] Actividad "Test Salto" creada');
    } else {
      activityId = activities.first['id'] as String;
    }

    final now = DateTime.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));

    print('📝 [TEST] Configurando TC-ACT-013: racha=3, completada hace 3 días');
    await db.update(
      'activities',
      {
        'streak': 3,
        'lastCompleted': threeDaysAgo.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [activityId],
    );

    // Insertar historial (completada hace 3 días)
    await db.insert(
      'completion_history',
      {
        'id': 'test_salto_completion_${DateTime.now().millisecondsSinceEpoch}',
        'activityId': activityId,
        'completedAt': threeDaysAgo.toIso8601String(),
        'notes': 'Datos de prueba TC-ACT-013 - 3 días atrás',
        'protectorUsed': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print('✅ [TEST] Datos inyectados exitosamente');
    print('   - Actividad: Test Salto');
    print('   - Racha actual: 3');
    print(
        '   - Última completación: ${threeDaysAgo.toString().substring(0, 10)}');
    print('   - Días sin completar: 2 días (ayer y anteayer)');
    print('');
    print('🎯 [TEST] Ahora puedes ejecutar TC-ACT-013:');
    print('   1. Completa "Test Salto" HOY');
    print(
        '   2. NO debería aparecer opción de protector (más de 1 día saltado)');
    print('   3. Verifica que la racha se REINICIA a 1 directamente');
  }
}
