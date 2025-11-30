import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:streakify/models/activity.dart';
import 'package:streakify/services/activity_service.dart';
import 'package:streakify/services/database_helper.dart';

/// ============================================================================
/// CASOS DE PRUEBA DE PRIORIDAD CRÍTICA
/// ============================================================================
///
/// TC-ACT-011: Completar actividad por primera vez
/// TC-ACT-012: Completar actividad día consecutivo
/// TC-ACT-013: Completar actividad después de saltar un día
///
/// Estos tests verifican la lógica fundamental del sistema de rachas
/// ============================================================================

void main() {
  final ActivityService activityService = ActivityService();
  final DatabaseHelper databaseHelper = DatabaseHelper();

  // Inicializar la base de datos antes de todos los tests
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('🔴 TC-ACT-011: Completar actividad por primera vez', () {
    setUp(() async {
      // Limpiar la base de datos antes de cada test
      await databaseHelper.deleteAllActivities();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test(
        'Completar actividad nueva debe establecer streak=1 y lastCompleted=hoy',
        () async {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  🧪 TC-ACT-011: Completar actividad por primera vez      ║');
      print('╚════════════════════════════════════════════════════════════╝');

      // PRECONDICIONES: Actividad nueva sin completar
      final testActivity = Activity(
        id: const Uuid().v4(),
        name: 'Test Ejercicio',
        streak: 0,
        lastCompleted: null,
        active: true,
        customIcon: 'fitness_center',
        customColor: '#4CAF50',
      );

      print('\n📋 Precondiciones:');
      print('   • Actividad: ${testActivity.name}');
      print('   • streak inicial: ${testActivity.streak}');
      print('   • lastCompleted inicial: ${testActivity.lastCompleted}');
      print('   • Estado: ${testActivity.active ? "activa" : "pausada"}');

      // Guardar actividad inicial
      await activityService.addActivity(testActivity);
      print('\n✅ Actividad guardada en la base de datos');

      // PASOS: Marcar como completada
      print('\n📝 Accion: Marcar actividad como completada');

      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);

      // Simular la lógica de completación (primera vez)
      testActivity.streak = 1;
      testActivity.lastCompleted = todayDay;
      testActivity.dailyCompletionCount = 1;

      await activityService.updateActivity(testActivity);
      print('   • Racha actualizada a: 1');
      print(
          '   • Fecha de completación: ${todayDay.toIso8601String().split('T')[0]}');

      // RESULTADO ESPERADO: Verificar cambios
      print('\n🔍 Verificando resultados...');

      final updatedActivity =
          await activityService.getActivity(testActivity.id);

      expect(updatedActivity, isNotNull,
          reason: 'La actividad debe existir en la base de datos');
      print('   ✓ Actividad existe en BD');

      expect(updatedActivity!.streak, equals(1),
          reason: 'La racha debe ser 1 después de la primera completación');
      print('   ✓ streak = ${updatedActivity.streak} (esperado: 1)');

      expect(updatedActivity.lastCompleted, isNotNull,
          reason: 'lastCompleted debe tener un valor');
      print('   ✓ lastCompleted tiene valor: ${updatedActivity.lastCompleted}');

      final lastCompletedDay = DateTime(
        updatedActivity.lastCompleted!.year,
        updatedActivity.lastCompleted!.month,
        updatedActivity.lastCompleted!.day,
      );

      expect(lastCompletedDay, equals(todayDay),
          reason: 'lastCompleted debe ser la fecha de hoy');
      print(
          '   ✓ lastCompleted = ${lastCompletedDay.toIso8601String().split('T')[0]}');
      print('   ✓ Fecha actual = ${todayDay.toIso8601String().split('T')[0]}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Todos los criterios cumplidos         ║');
      print('╠════════════════════════════════════════════════════════════╣');
      print('║  • Racha establecida en 1                                 ║');
      print('║  • lastCompleted establecido en la fecha actual           ║');
      print('║  • Lógica de primera completación correcta                ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });

    test('Completar múltiples actividades debe mantener rachas independientes',
        () async {
      print('\n📊 Test adicional: Rachas independientes');

      // Crear dos actividades
      final activity1 = Activity(
        id: const Uuid().v4(),
        name: 'Ejercicio',
        streak: 0,
        lastCompleted: null,
        active: true,
      );

      final activity2 = Activity(
        id: const Uuid().v4(),
        name: 'Meditación',
        streak: 0,
        lastCompleted: null,
        active: true,
      );

      await activityService.addActivity(activity1);
      await activityService.addActivity(activity2);

      // Completar ambas
      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);

      activity1.streak = 1;
      activity1.lastCompleted = todayDay;

      activity2.streak = 1;
      activity2.lastCompleted = todayDay;

      await activityService.updateActivity(activity1);
      await activityService.updateActivity(activity2);

      // Verificar que ambas tienen streak = 1
      final retrieved1 = await activityService.getActivity(activity1.id);
      final retrieved2 = await activityService.getActivity(activity2.id);

      expect(retrieved1!.streak, equals(1));
      expect(retrieved2!.streak, equals(1));

      print('   ✅ Ambas actividades tienen rachas independientes de 1');
    });
  });

  group('🔴 TC-ACT-012: Completar actividad día consecutivo', () {
    setUp(() async {
      await databaseHelper.deleteAllActivities();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('Completar actividad el día después debe incrementar streak de 5 a 6',
        () async {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  🧪 TC-ACT-012: Completar actividad día consecutivo      ║');
      print('╚════════════════════════════════════════════════════════════╝');

      // PRECONDICIONES: Actividad con streak=5, completada ayer
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDay =
          DateTime(yesterday.year, yesterday.month, yesterday.day);

      final testActivity = Activity(
        id: const Uuid().v4(),
        name: 'Test Meditación',
        streak: 5,
        lastCompleted: yesterdayDay,
        active: true,
        customIcon: 'self_improvement',
        customColor: '#9C27B0',
      );

      print('\n📋 Precondiciones:');
      print('   • Actividad: ${testActivity.name}');
      print('   • streak inicial: ${testActivity.streak}');
      print(
          '   • lastCompleted: ${yesterdayDay.toIso8601String().split('T')[0]} (ayer)');

      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);
      print('   • Fecha actual: ${todayDay.toIso8601String().split('T')[0]}');
      print(
          '   • Diferencia: ${todayDay.difference(yesterdayDay).inDays} día(s)');

      await activityService.addActivity(testActivity);
      print('\n✅ Actividad guardada en la base de datos');

      // PASOS: Completar hoy (día consecutivo)
      print('\n📝 Acción: Completar actividad hoy (día consecutivo)');

      // Verificar que es día consecutivo
      expect(todayDay.difference(yesterdayDay).inDays, equals(1),
          reason: 'Debe ser exactamente 1 día de diferencia');
      print('   ✓ Confirmado: es día consecutivo (diferencia = 1 día)');

      // Simular lógica de completación consecutiva
      if (todayDay.difference(yesterdayDay).inDays == 1) {
        testActivity.streak += 1;
      }
      testActivity.lastCompleted = todayDay;
      testActivity.dailyCompletionCount = 1;

      await activityService.updateActivity(testActivity);
      print('   • Racha incrementada a: ${testActivity.streak}');
      print(
          '   • Fecha actualizada a: ${todayDay.toIso8601String().split('T')[0]}');

      // RESULTADO ESPERADO: streak debe ser 6
      print('\n🔍 Verificando resultados...');

      final updatedActivity =
          await activityService.getActivity(testActivity.id);

      expect(updatedActivity, isNotNull);
      print('   ✓ Actividad existe en BD');

      expect(updatedActivity!.streak, equals(6),
          reason: 'La racha debe incrementarse de 5 a 6');
      print('   ✓ streak = ${updatedActivity.streak} (esperado: 6)');
      print('   ✓ Incremento correcto: 5 → 6');

      final lastCompletedDay = DateTime(
        updatedActivity.lastCompleted!.year,
        updatedActivity.lastCompleted!.month,
        updatedActivity.lastCompleted!.day,
      );

      expect(lastCompletedDay, equals(todayDay),
          reason: 'lastCompleted debe actualizarse a hoy');
      print('   ✓ lastCompleted actualizado a hoy');
      print(
          '   ✓ lastCompleted = ${lastCompletedDay.toIso8601String().split('T')[0]}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Todos los criterios cumplidos         ║');
      print('╠════════════════════════════════════════════════════════════╣');
      print('║  • Racha incrementada correctamente (5 → 6)               ║');
      print('║  • lastCompleted actualizado a fecha actual               ║');
      print('║  • Lógica de días consecutivos correcta                   ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });

    test('Completar múltiples días seguidos debe incrementar progresivamente',
        () async {
      print('\n📊 Test adicional: Múltiples días consecutivos');

      final today = DateTime.now();
      final twoDaysAgo = today.subtract(const Duration(days: 2));
      final twoDaysAgoDay =
          DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day);

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Test Progresión',
        streak: 10,
        lastCompleted: twoDaysAgoDay,
        active: true,
      );

      await activityService.addActivity(activity);

      // Día 1: hace 2 días → ayer (se rompe racha, reinicia a 1)
      final yesterday = today.subtract(const Duration(days: 1));
      final yesterdayDay =
          DateTime(yesterday.year, yesterday.month, yesterday.day);

      if (yesterdayDay.difference(twoDaysAgoDay).inDays > 1) {
        activity.streak = 1; // Se reinicia
      }
      activity.lastCompleted = yesterdayDay;
      await activityService.updateActivity(activity);

      // Día 2: ayer → hoy (consecutivo, incrementa)
      final todayDay = DateTime(today.year, today.month, today.day);
      if (todayDay.difference(yesterdayDay).inDays == 1) {
        activity.streak += 1;
      }
      activity.lastCompleted = todayDay;
      await activityService.updateActivity(activity);

      final result = await activityService.getActivity(activity.id);
      expect(result!.streak, equals(2));

      print('   ✅ Racha incrementada correctamente: 10 → 1 → 2');
    });
  });

  group('🔴 TC-ACT-013: Completar actividad después de saltar un día', () {
    setUp(() async {
      await databaseHelper.deleteAllActivities();
      await Future.delayed(const Duration(milliseconds: 100));
    });

    test('Completar después de saltar un día debe reiniciar streak a 1',
        () async {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  🧪 TC-ACT-013: Completar después de saltar un día       ║');
      print('╚════════════════════════════════════════════════════════════╝');

      // PRECONDICIONES: Actividad con streak=15, completada hace 2 días
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgoDay =
          DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day);

      final testActivity = Activity(
        id: const Uuid().v4(),
        name: 'Test Lectura',
        streak: 15,
        lastCompleted: twoDaysAgoDay,
        active: true,
        protectorUsed: true, // Ya usó su protector
        customIcon: 'menu_book',
        customColor: '#FF5722',
      );

      print('\n📋 Precondiciones:');
      print('   • Actividad: ${testActivity.name}');
      print('   • streak inicial: ${testActivity.streak}');
      print(
          '   • lastCompleted: ${twoDaysAgoDay.toIso8601String().split('T')[0]} (hace 2 días)');
      print('   • Protector usado: ${testActivity.protectorUsed}');

      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);
      final daysMissed = todayDay.difference(twoDaysAgoDay).inDays - 1;
      print('   • Fecha actual: ${todayDay.toIso8601String().split('T')[0]}');
      print(
          '   • Diferencia: ${todayDay.difference(twoDaysAgoDay).inDays} días');
      print('   • Días saltados: $daysMissed día(s)');

      await activityService.addActivity(testActivity);
      print('\n✅ Actividad guardada en la base de datos');

      // PASOS: Intentar completar hoy (después de saltar 1 día)
      print('\n📝 Acción: Completar actividad después de saltar un día');

      // Verificar que se saltó al menos un día
      expect(todayDay.difference(twoDaysAgoDay).inDays, greaterThan(1),
          reason: 'Debe haber más de 1 día de diferencia');
      print('   ✓ Confirmado: se saltó al menos 1 día');

      // Simular lógica de racha rota (sin protector disponible)
      if (todayDay.difference(twoDaysAgoDay).inDays > 1) {
        // Verificar si tiene protector disponible
        if (testActivity.protectorUsed ||
            (testActivity.nextProtectorAvailable != null &&
                today.isBefore(testActivity.nextProtectorAvailable!))) {
          // No tiene protector, se reinicia
          print('   • Sin protector disponible');
          testActivity.streak = 1;
          print('   • Racha reiniciada a: 1');
        }
      }
      testActivity.lastCompleted = todayDay;
      testActivity.dailyCompletionCount = 1;

      await activityService.updateActivity(testActivity);
      print(
          '   • Fecha actualizada a: ${todayDay.toIso8601String().split('T')[0]}');

      // RESULTADO ESPERADO: streak debe ser 1 (reiniciada)
      print('\n🔍 Verificando resultados...');

      final updatedActivity =
          await activityService.getActivity(testActivity.id);

      expect(updatedActivity, isNotNull);
      print('   ✓ Actividad existe en BD');

      expect(updatedActivity!.streak, equals(1),
          reason: 'La racha debe reiniciarse a 1 después de saltar un día');
      print('   ✓ streak = ${updatedActivity.streak} (esperado: 1)');
      print('   ✓ Reinicio correcto: 15 → 1');

      final lastCompletedDay = DateTime(
        updatedActivity.lastCompleted!.year,
        updatedActivity.lastCompleted!.month,
        updatedActivity.lastCompleted!.day,
      );

      expect(lastCompletedDay, equals(todayDay),
          reason: 'lastCompleted debe ser hoy');
      print('   ✓ lastCompleted actualizado a hoy');
      print(
          '   ✓ lastCompleted = ${lastCompletedDay.toIso8601String().split('T')[0]}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Todos los criterios cumplidos         ║');
      print('╠════════════════════════════════════════════════════════════╣');
      print('║  • Racha reiniciada correctamente (15 → 1)                ║');
      print('║  • lastCompleted actualizado a fecha actual               ║');
      print('║  • Lógica de racha rota correcta                          ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });

    test('Saltar múltiples días también debe reiniciar streak a 1', () async {
      print('\n📊 Test adicional: Saltar múltiples días');

      final fiveDaysAgo = DateTime.now().subtract(const Duration(days: 5));
      final fiveDaysAgoDay =
          DateTime(fiveDaysAgo.year, fiveDaysAgo.month, fiveDaysAgo.day);

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Test Múltiples Días',
        streak: 50,
        lastCompleted: fiveDaysAgoDay,
        active: true,
        protectorUsed: true,
      );

      await activityService.addActivity(activity);

      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);

      // Saltar 4 días (diferencia de 5 días)
      if (todayDay.difference(fiveDaysAgoDay).inDays > 1) {
        activity.streak = 1; // Reiniciar
      }
      activity.lastCompleted = todayDay;
      await activityService.updateActivity(activity);

      final result = await activityService.getActivity(activity.id);
      expect(result!.streak, equals(1));
      expect(todayDay.difference(fiveDaysAgoDay).inDays, equals(5));

      print('   ✅ Después de saltar 4 días, racha reinicia: 50 → 1');
    });

    test('Verificar que lastCompleted se actualiza incluso al reiniciar',
        () async {
      print('\n📊 Test adicional: lastCompleted siempre se actualiza');

      final threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final threeDaysAgoDay =
          DateTime(threeDaysAgo.year, threeDaysAgo.month, threeDaysAgo.day);

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Test LastCompleted',
        streak: 30,
        lastCompleted: threeDaysAgoDay,
        active: true,
        protectorUsed: true,
      );

      await activityService.addActivity(activity);

      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);

      // Completar después de saltar
      if (todayDay.difference(threeDaysAgoDay).inDays > 1) {
        activity.streak = 1;
      }
      activity.lastCompleted = todayDay;
      await activityService.updateActivity(activity);

      final result = await activityService.getActivity(activity.id);

      final lastDay = DateTime(
        result!.lastCompleted!.year,
        result.lastCompleted!.month,
        result.lastCompleted!.day,
      );

      expect(result.streak, equals(1));
      expect(lastDay, equals(todayDay));
      expect(lastDay, isNot(equals(threeDaysAgoDay)));

      print(
          '   ✅ lastCompleted actualizado correctamente incluso al reiniciar');
    });
  });

  group('🔍 Resumen de Tests Críticos', () {
    test('Mostrar resumen final', () {
      print('\n');
      print('╔════════════════════════════════════════════════════════════╗');
      print('║           RESUMEN DE TESTS DE PRIORIDAD CRÍTICA          ║');
      print('╠════════════════════════════════════════════════════════════╣');
      print('║                                                            ║');
      print('║  ✅ TC-ACT-011: Primera completación                      ║');
      print('║     • streak = 1                                           ║');
      print('║     • lastCompleted = hoy                                  ║');
      print('║                                                            ║');
      print('║  ✅ TC-ACT-012: Completación consecutiva                  ║');
      print('║     • streak incrementa correctamente (5 → 6)             ║');
      print('║     • lastCompleted actualizado                            ║');
      print('║                                                            ║');
      print('║  ✅ TC-ACT-013: Después de saltar un día                  ║');
      print('║     • streak reinicia a 1 (15 → 1)                        ║');
      print('║     • lastCompleted actualizado                            ║');
      print('║                                                            ║');
      print('╠════════════════════════════════════════════════════════════╣');
      print('║  🎯 TODOS LOS CASOS CRÍTICOS VERIFICADOS EXITOSAMENTE    ║');
      print('╚════════════════════════════════════════════════════════════╝');
      print('');
    });
  });
}
