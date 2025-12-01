import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Script para insertar datos de prueba para TC-ACT-012
/// Crea una actividad con streak=5 completada ayer
void main() async {
  print('=== Script de Datos de Prueba: TC-ACT-012 ===\n');

  try {
    // Ruta de la base de datos en el dispositivo
    // Necesitamos ejecutar este script en el contexto de la app
    final dbPath = join(await getDatabasesPath(), 'streakify.db');
    print('📂 Ruta de DB: $dbPath');

    final db = await openDatabase(dbPath);

    // Datos de prueba
    final activityId = const Uuid().v4();
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayDay =
        DateTime(yesterday.year, yesterday.month, yesterday.day);

    print('\n📝 Creando actividad de prueba:');
    print('   ID: $activityId');
    print('   Nombre: TC-012 Meditación');
    print('   Streak: 5');
    print('   Last Completed: ${yesterdayDay.toIso8601String().split('T')[0]}');

    // Insertar actividad
    await db.insert('activities', {
      'id': activityId,
      'name': 'TC-012 Meditación',
      'streak': 5,
      'lastCompleted': yesterdayDay.toIso8601String(),
      'active': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'customIcon': 'self_improvement',
      'customColor': '#9C27B0',
      'recurrenceType': 'daily',
      'dailyGoal': 1,
      'protectorUsed': 0,
    });

    print('✅ Actividad insertada exitosamente\n');

    // Verificar inserción
    final result = await db.query(
      'activities',
      where: 'id = ?',
      whereArgs: [activityId],
    );

    if (result.isNotEmpty) {
      print('✓ Verificación exitosa:');
      print('   Nombre: ${result.first['name']}');
      print('   Streak: ${result.first['streak']}');
      print('   Last Completed: ${result.first['lastCompleted']}');
    }

    await db.close();
    print('\n🎉 Script completado exitosamente');
    exit(0);
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}
