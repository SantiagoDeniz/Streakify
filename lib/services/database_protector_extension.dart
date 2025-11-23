import 'package:sqflite/sqflite.dart';
import '../models/protector.dart';
import '../models/streak_recovery.dart';

/// Extensión de DatabaseHelper para operaciones de protectores
extension ProtectorOperations on Database {
  // CRUD Operations - Protectors

  /// Insertar un nuevo protector
  Future<int> insertProtector(Protector protector) async {
    return await insert(
      'protectors',
      protector.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtener todos los protectores de una actividad
  Future<List<Protector>> getProtectorsByActivity(String activityId) async {
    final List<Map<String, dynamic>> maps = await query(
      'protectors',
      where: 'activityId = ? OR activityId IS NULL',
      whereArgs: [activityId],
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Protector.fromMap(maps[i]));
  }

  /// Obtener protectores disponibles (no usados)
  Future<List<Protector>> getAvailableProtectors() async {
    final List<Map<String, dynamic>> maps = await query(
      'protectors',
      where: 'usedAt IS NULL AND isActive = 0',
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => Protector.fromMap(maps[i]));
  }

  /// Obtener protectores activos
  Future<List<Protector>> getActiveProtectors() async {
    final List<Map<String, dynamic>> maps = await query(
      'protectors',
      where: 'isActive = 1',
      orderBy: 'expiresAt ASC',
    );
    return List.generate(maps.length, (i) => Protector.fromMap(maps[i]));
  }

  /// Actualizar un protector
  Future<int> updateProtector(Protector protector) async {
    return await update(
      'protectors',
      protector.toMap(),
      where: 'id = ?',
      whereArgs: [protector.id],
    );
  }

  /// Eliminar un protector
  Future<int> deleteProtector(String id) async {
    return await delete(
      'protectors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // CRUD Operations - Streak Recoveries

  /// Insertar una recuperación de racha
  Future<int> insertStreakRecovery(StreakRecovery recovery) async {
    return await insert(
      'streak_recoveries',
      recovery.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtener recuperaciones de una actividad
  Future<List<StreakRecovery>> getStreakRecoveriesByActivity(
      String activityId) async {
    final List<Map<String, dynamic>> maps = await query(
      'streak_recoveries',
      where: 'activityId = ?',
      whereArgs: [activityId],
      orderBy: 'recoveredAt DESC',
    );
    return List.generate(maps.length, (i) => StreakRecovery.fromMap(maps[i]));
  }

  /// Obtener todas las recuperaciones
  Future<List<StreakRecovery>> getAllStreakRecoveries() async {
    final List<Map<String, dynamic>> maps = await query(
      'streak_recoveries',
      orderBy: 'recoveredAt DESC',
    );
    return List.generate(maps.length, (i) => StreakRecovery.fromMap(maps[i]));
  }
}
