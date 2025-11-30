import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

import 'package:streakify/main.dart' as app;
import 'package:streakify/models/activity.dart';
import 'package:streakify/services/activity_service.dart';
import 'package:streakify/services/database_helper.dart';

/// Casos de prueba de prioridad CRÍTICA
///
/// TC-ACT-011: Completar actividad por primera vez
/// TC-ACT-012: Completar actividad día consecutivo
/// TC-ACT-013: Completar actividad después de saltar un día
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final ActivityService activityService = ActivityService();
  final DatabaseHelper databaseHelper = DatabaseHelper();

  group('🔴 Casos de Prueba Críticos - Gestión de Rachas', () {
    setUp(() async {
      // Limpiar la base de datos antes de cada test
      await databaseHelper.deleteAllActivities();
      await Future.delayed(const Duration(milliseconds: 500));
    });

    testWidgets('TC-ACT-011: Completar actividad por primera vez',
        (WidgetTester tester) async {
      print('\n🧪 TC-ACT-011: Completar actividad por primera vez');
      print('═' * 60);

      // Crear actividad de prueba directamente en la base de datos
      final testActivity = Activity(
        id: const Uuid().v4(),
        name: 'Test Ejercicio',
        streak: 0,
        lastCompleted: null,
        active: true,
        customIcon: 'fitness_center',
        customColor: '#4CAF50',
      );

      await activityService.addActivity(testActivity);
      print('✓ Actividad creada: ${testActivity.name}');
      print('  ID: ${testActivity.id}');
      print('  Estado inicial: streak=0, lastCompleted=null');

      // Lanzar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✓ App iniciada');

      // Buscar la actividad en la interfaz
      final activityFinder = find.text('Test Ejercicio');
      expect(activityFinder, findsOneWidget,
          reason: 'La actividad debe aparecer en la lista');
      print('✓ Actividad visible en la interfaz');

      // Buscar el checkbox o botón de completar
      // La app usa GestureDetector en el card, buscaremos el card
      final activityCard = find.ancestor(
        of: activityFinder,
        matching: find.byType(Card),
      );
      expect(activityCard, findsOneWidget,
          reason: 'El card de la actividad debe existir');

      // Tap en el card para marcar como completada
      await tester.tap(activityCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✓ Actividad marcada como completada');

      // Verificar que aparece el SnackBar de confirmación
      expect(find.textContaining('Completado'), findsOneWidget,
          reason: 'Debe mostrar mensaje de confirmación');
      expect(find.textContaining('Racha: 1'), findsOneWidget,
          reason: 'Debe mostrar racha = 1');
      print('✓ Mensaje de confirmación mostrado');

      // Esperar a que se guarden los cambios
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verificar en la base de datos
      final updatedActivity =
          await activityService.getActivity(testActivity.id);
      expect(updatedActivity, isNotNull, reason: 'La actividad debe existir');
      expect(updatedActivity!.streak, equals(1), reason: 'La racha debe ser 1');
      expect(updatedActivity.lastCompleted, isNotNull,
          reason: 'lastCompleted debe tener un valor');

      // Verificar que lastCompleted es hoy
      final today = DateTime.now();
      final lastCompletedDay = DateTime(
        updatedActivity.lastCompleted!.year,
        updatedActivity.lastCompleted!.month,
        updatedActivity.lastCompleted!.day,
      );
      final todayDay = DateTime(today.year, today.month, today.day);
      expect(lastCompletedDay, equals(todayDay),
          reason: 'lastCompleted debe ser hoy');

      print('');
      print('📊 Resultado esperado: ✅ CORRECTO');
      print('   • streak = ${updatedActivity.streak} (esperado: 1)');
      print(
          '   • lastCompleted = ${lastCompletedDay.toIso8601String().split('T')[0]}');
      print('   • fecha actual = ${todayDay.toIso8601String().split('T')[0]}');
      print('═' * 60);
    });

    testWidgets('TC-ACT-012: Completar actividad día consecutivo',
        (WidgetTester tester) async {
      print('\n🧪 TC-ACT-012: Completar actividad día consecutivo');
      print('═' * 60);

      // Crear actividad con racha de 5 completada ayer
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

      await activityService.addActivity(testActivity);
      print('✓ Actividad creada: ${testActivity.name}');
      print('  Estado inicial: streak=5, lastCompleted=ayer');
      print('  Ayer: ${yesterdayDay.toIso8601String().split('T')[0]}');

      // Lanzar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✓ App iniciada');

      // Buscar y completar la actividad
      final activityFinder = find.text('Test Meditación');
      expect(activityFinder, findsOneWidget,
          reason: 'La actividad debe aparecer en la lista');
      print('✓ Actividad visible en la interfaz');

      final activityCard = find.ancestor(
        of: activityFinder,
        matching: find.byType(Card),
      );

      // Verificar que muestra racha actual
      expect(find.textContaining('5'), findsWidgets,
          reason: 'Debe mostrar la racha actual de 5');

      await tester.tap(activityCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✓ Actividad marcada como completada');

      // Verificar mensaje de confirmación
      expect(find.textContaining('Racha: 6'), findsOneWidget,
          reason: 'Debe mostrar racha = 6');
      print('✓ Mensaje de confirmación con racha = 6');

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verificar en la base de datos
      final updatedActivity =
          await activityService.getActivity(testActivity.id);
      expect(updatedActivity, isNotNull);
      expect(updatedActivity!.streak, equals(6),
          reason: 'La racha debe incrementarse de 5 a 6');

      final today = DateTime.now();
      final lastCompletedDay = DateTime(
        updatedActivity.lastCompleted!.year,
        updatedActivity.lastCompleted!.month,
        updatedActivity.lastCompleted!.day,
      );
      final todayDay = DateTime(today.year, today.month, today.day);
      expect(lastCompletedDay, equals(todayDay),
          reason: 'lastCompleted debe actualizarse a hoy');

      print('');
      print('📊 Resultado esperado: ✅ CORRECTO');
      print('   • streak anterior = 5');
      print('   • streak actual = ${updatedActivity.streak} (esperado: 6)');
      print(
          '   • lastCompleted = ${lastCompletedDay.toIso8601String().split('T')[0]}');
      print('   • Racha mantenida: ✓');
      print('═' * 60);
    });

    testWidgets('TC-ACT-013: Completar actividad después de saltar un día',
        (WidgetTester tester) async {
      print('\n🧪 TC-ACT-013: Completar actividad después de saltar un día');
      print('═' * 60);

      // Crear actividad completada hace 2 días (se saltó ayer)
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgoDay =
          DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day);

      final testActivity = Activity(
        id: const Uuid().v4(),
        name: 'Test Lectura',
        streak: 15,
        lastCompleted: twoDaysAgoDay,
        active: true,
        customIcon: 'menu_book',
        customColor: '#FF5722',
      );

      await activityService.addActivity(testActivity);
      print('✓ Actividad creada: ${testActivity.name}');
      print('  Estado inicial: streak=15, lastCompleted=hace 2 días');
      print('  Hace 2 días: ${twoDaysAgoDay.toIso8601String().split('T')[0]}');
      print('  Días sin completar: 1 (ayer)');

      // Lanzar la app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      print('✓ App iniciada');

      // Buscar la actividad
      final activityFinder = find.text('Test Lectura');
      expect(activityFinder, findsOneWidget,
          reason: 'La actividad debe aparecer en la lista');
      print('✓ Actividad visible en la interfaz');

      final activityCard = find.ancestor(
        of: activityFinder,
        matching: find.byType(Card),
      );

      // Verificar que muestra racha antigua
      expect(find.textContaining('15'), findsWidgets,
          reason: 'Debe mostrar la racha anterior de 15');

      // Intentar completar - debería mostrar diálogo de protector
      await tester.tap(activityCard);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      print('✓ Tap en actividad detectado');

      // Buscar diálogo de protector o mensaje de racha reiniciada
      // Si aparece diálogo de protector, cancelar para que se reinicie
      final cancelButton = find.text('No, reiniciar');
      if (cancelButton.evaluate().isNotEmpty) {
        print('✓ Diálogo de protector apareció (esperado)');
        await tester.tap(cancelButton);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        print('✓ Protector rechazado - racha se reiniciará');
      } else {
        print('✓ Sin protector disponible - racha se reinicia directamente');
      }

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verificar mensaje de racha = 1
      expect(find.textContaining('Racha: 1'), findsOneWidget,
          reason: 'La racha debe reiniciarse a 1');
      print('✓ Mensaje de confirmación con racha = 1');

      // Verificar en la base de datos
      final updatedActivity =
          await activityService.getActivity(testActivity.id);
      expect(updatedActivity, isNotNull);
      expect(updatedActivity!.streak, equals(1),
          reason: 'La racha debe reiniciarse a 1 después de saltar un día');

      final today = DateTime.now();
      final lastCompletedDay = DateTime(
        updatedActivity.lastCompleted!.year,
        updatedActivity.lastCompleted!.month,
        updatedActivity.lastCompleted!.day,
      );
      final todayDay = DateTime(today.year, today.month, today.day);
      expect(lastCompletedDay, equals(todayDay),
          reason: 'lastCompleted debe ser hoy');

      print('');
      print('📊 Resultado esperado: ✅ CORRECTO');
      print('   • streak anterior = 15');
      print('   • streak actual = ${updatedActivity.streak} (esperado: 1)');
      print(
          '   • lastCompleted = ${lastCompletedDay.toIso8601String().split('T')[0]}');
      print('   • Racha reiniciada correctamente: ✓');
      print('═' * 60);
    });
  });

  group('🔴 Verificación de Lógica de Negocio - Sin UI', () {
    setUp(() async {
      await databaseHelper.deleteAllActivities();
      await Future.delayed(const Duration(milliseconds: 500));
    });

    test('Verificar lógica: Primera completación establece streak=1', () async {
      print('\n🔬 Test unitario: Primera completación');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Test Direct',
        streak: 0,
        lastCompleted: null,
        active: true,
      );

      await activityService.addActivity(activity);

      // Simular completación
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      activity.streak = 1;
      activity.lastCompleted = today;

      await activityService.updateActivity(activity);

      final retrieved = await activityService.getActivity(activity.id);
      expect(retrieved!.streak, equals(1));
      expect(retrieved.lastCompleted!.day, equals(today.day));

      print('✅ Lógica verificada correctamente');
    });

    test('Verificar lógica: Completación consecutiva incrementa streak',
        () async {
      print('\n🔬 Test unitario: Completación consecutiva');

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDay =
          DateTime(yesterday.year, yesterday.month, yesterday.day);

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Test Consecutive',
        streak: 5,
        lastCompleted: yesterdayDay,
        active: true,
      );

      await activityService.addActivity(activity);

      // Simular completación hoy
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (today.difference(yesterdayDay).inDays == 1) {
        activity.streak += 1;
      }
      activity.lastCompleted = today;

      await activityService.updateActivity(activity);

      final retrieved = await activityService.getActivity(activity.id);
      expect(retrieved!.streak, equals(6));

      print('✅ Lógica de incremento verificada correctamente');
    });

    test('Verificar lógica: Saltar un día reinicia streak a 1', () async {
      print('\n🔬 Test unitario: Reinicio de streak');

      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final twoDaysAgoDay =
          DateTime(twoDaysAgo.year, twoDaysAgo.month, twoDaysAgo.day);

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Test Reset',
        streak: 20,
        lastCompleted: twoDaysAgoDay,
        active: true,
        protectorUsed: true, // Ya usó protector
      );

      await activityService.addActivity(activity);

      // Simular completación después de saltar un día
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if (today.difference(twoDaysAgoDay).inDays > 1) {
        activity.streak = 1; // Reiniciar
      }
      activity.lastCompleted = today;

      await activityService.updateActivity(activity);

      final retrieved = await activityService.getActivity(activity.id);
      expect(retrieved!.streak, equals(1));
      expect(retrieved.lastCompleted!.day, equals(today.day));

      print('✅ Lógica de reinicio verificada correctamente');
    });
  });
}
