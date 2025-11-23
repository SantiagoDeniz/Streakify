import 'package:uuid/uuid.dart';
import '../models/protector.dart';
import '../models/activity.dart';
import 'database_helper.dart';
import 'database_protector_extension.dart';

/// Servicio para gestionar protectores de racha
class ProtectorService {
  final DatabaseHelper _db = DatabaseHelper();
  static const int monthlyProtectorLimit = 5; // Límite mensual de protectores

  /// Otorgar un protector a una actividad (o al inventario global)
  Future<Protector> grantProtector({
    required ProtectorType type,
    required ProtectorSource source,
    String? activityId,
  }) async {
    final protector = Protector(
      id: const Uuid().v4(),
      type: type,
      source: source,
      createdAt: DateTime.now(),
      activityId: activityId,
    );

    final db = await _db.database;
    await db.insertProtector(protector);
    return protector;
  }

  /// Usar un protector en una actividad
  Future<bool> useProtector({
    required String protectorId,
    required String activityId,
  }) async {
    final db = await _db.database;

    // Obtener el protector
    final protectors = await db.query(
      'protectors',
      where: 'id = ?',
      whereArgs: [protectorId],
      limit: 1,
    );

    if (protectors.isEmpty) return false;

    final protector = Protector.fromMap(protectors.first);

    // Verificar que esté disponible
    if (!protector.isAvailable) return false;

    // Verificar límite mensual
    final activity = await _db.getActivity(activityId);
    if (activity == null) return false;

    if (!await canUseProtector(activityId)) {
      return false;
    }

    // Activar el protector
    final now = DateTime.now();
    final expiresAt = now.add(Duration(days: protector.type.durationDays));

    final updatedProtector = protector.copyWith(
      usedAt: now,
      activityId: activityId,
      isActive: true,
      expiresAt: expiresAt,
    );

    await db.updateProtector(updatedProtector);

    // Incrementar contador mensual
    activity.monthlyProtectorUses++;
    if (activity.lastProtectorReset == null ||
        !_isSameMonth(activity.lastProtectorReset!, now)) {
      activity.lastProtectorReset = now;
      activity.monthlyProtectorUses = 1;
    }

    await _db.updateActivity(activity);

    // Registrar en historial
    await db.insert('protector_history', {
      'id': const Uuid().v4(),
      'protectorId': protectorId,
      'activityId': activityId,
      'usedAt': now.toIso8601String(),
      'protectorType': protector.type.toJson(),
      'daysProtected': protector.type.durationDays,
    });

    return true;
  }

  /// Verificar si se puede usar un protector (límite mensual)
  Future<bool> canUseProtector(String activityId) async {
    final activity = await _db.getActivity(activityId);
    if (activity == null) return false;

    // Resetear contador si es un nuevo mes
    final now = DateTime.now();
    if (activity.lastProtectorReset == null ||
        !_isSameMonth(activity.lastProtectorReset!, now)) {
      activity.monthlyProtectorUses = 0;
      activity.lastProtectorReset = now;
      await _db.updateActivity(activity);
      return true;
    }

    return activity.monthlyProtectorUses < monthlyProtectorLimit;
  }

  /// Obtener protectores disponibles para una actividad
  Future<List<Protector>> getAvailableProtectors({String? activityId}) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps;

    if (activityId != null) {
      // Protectores específicos de la actividad o globales
      maps = await db.query(
        'protectors',
        where: '(activityId = ? OR activityId IS NULL) AND usedAt IS NULL AND isActive = 0',
        whereArgs: [activityId],
        orderBy: 'createdAt DESC',
      );
    } else {
      // Solo protectores globales
      maps = await db.query(
        'protectors',
        where: 'activityId IS NULL AND usedAt IS NULL AND isActive = 0',
        orderBy: 'createdAt DESC',
      );
    }

    return List.generate(maps.length, (i) => Protector.fromMap(maps[i]));
  }

  /// Obtener protectores activos
  Future<List<Protector>> getActiveProtectors({String? activityId}) async {
    final db = await _db.database;
    final List<Map<String, dynamic>> maps;

    if (activityId != null) {
      maps = await db.query(
        'protectors',
        where: 'activityId = ? AND isActive = 1',
        whereArgs: [activityId],
        orderBy: 'expiresAt ASC',
      );
    } else {
      maps = await db.query(
        'protectors',
        where: 'isActive = 1',
        orderBy: 'expiresAt ASC',
      );
    }

    return List.generate(maps.length, (i) => Protector.fromMap(maps[i]));
  }

  /// Obtener historial de uso de protectores
  Future<List<Map<String, dynamic>>> getProtectorHistory({String? activityId}) async {
    final db = await _db.database;

    if (activityId != null) {
      return await db.query(
        'protector_history',
        where: 'activityId = ?',
        whereArgs: [activityId],
        orderBy: 'usedAt DESC',
      );
    } else {
      return await db.query(
        'protector_history',
        orderBy: 'usedAt DESC',
      );
    }
  }

  /// Resetear contadores mensuales (llamar al inicio de cada mes)
  Future<void> resetMonthlyLimits() async {
    final activities = await _db.getAllActivities();
    final now = DateTime.now();

    for (var activity in activities) {
      if (activity.lastProtectorReset == null ||
          !_isSameMonth(activity.lastProtectorReset!, now)) {
        activity.monthlyProtectorUses = 0;
        activity.lastProtectorReset = now;
        await _db.updateActivity(activity);
      }
    }
  }

  /// Desactivar protectores expirados
  Future<void> deactivateExpiredProtectors() async {
    final db = await _db.database;
    final now = DateTime.now();

    final activeProtectors = await db.query(
      'protectors',
      where: 'isActive = 1',
    );

    for (var map in activeProtectors) {
      final protector = Protector.fromMap(map);
      if (protector.expiresAt != null && now.isAfter(protector.expiresAt!)) {
        final updated = protector.copyWith(isActive: false);
        await db.updateProtector(updated);
      }
    }
  }

  /// Verificar si dos fechas están en el mismo mes
  bool _isSameMonth(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month;
  }

  /// Obtener protectores restantes este mes
  Future<int> getRemainingProtectorsThisMonth(String activityId) async {
    final activity = await _db.getActivity(activityId);
    if (activity == null) return monthlyProtectorLimit;

    final now = DateTime.now();
    if (activity.lastProtectorReset == null ||
        !_isSameMonth(activity.lastProtectorReset!, now)) {
      return monthlyProtectorLimit;
    }

    return (monthlyProtectorLimit - activity.monthlyProtectorUses).clamp(0, monthlyProtectorLimit);
  }
}
