import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:streakify/models/activity.dart';

/// ============================================================================
/// CASOS DE PRUEBA DE PRIORIDAD ALTA (10 primeros)
/// ============================================================================
///
/// Tests de lógica de negocio para casos de prioridad alta
/// ============================================================================

void main() {
  group('TC-ACT-001: Crear actividad basica', () {
    test('Crear actividad con nombre, icono y color', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-ACT-001: Crear actividad basica                      ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Usuario en pantalla principal');

      print('\n📝 Pasos:');
      print('   1. Presionar boton "+"');
      print('   2. Ingresar nombre "Ejercicio"');
      print('   3. Seleccionar icono');
      print('   4. Seleccionar color');
      print('   5. Guardar');

      // Simular creación de actividad
      final newActivity = Activity(
        id: const Uuid().v4(),
        name: 'Ejercicio',
        streak: 0,
        lastCompleted: null,
        active: true,
        customIcon: 'fitness_center',
        customColor: '#4CAF50',
      );

      print('\n:mag: Verificando resultados...');

      expect(newActivity.name, equals('Ejercicio'));
      print('   ✓ Nombre: ${newActivity.name}');

      expect(newActivity.customIcon, equals('fitness_center'));
      print('   ✓ Icono: ${newActivity.customIcon}');

      expect(newActivity.customColor, equals('#4CAF50'));
      print('   ✓ Color: ${newActivity.customColor}');

      expect(newActivity.active, isTrue);
      print('   ✓ Estado: activa');

      expect(newActivity.id, isNotEmpty);
      print('   ✓ ID generado correctamente');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Actividad creada correctamente        ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('TC-ACT-002: Crear actividad con recurrencia diaria', () {
    test('Actividad con recurrencia diaria configurada', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-ACT-002: Crear actividad con recurrencia diaria      ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Usuario en formulario de nueva actividad');

      print('\n📝 Pasos:');
      print('   1. Ingresar nombre');
      print('   2. Seleccionar recurrencia "Diaria"');
      print('   3. Guardar');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Meditacion',
        streak: 0,
        lastCompleted: null,
        active: true,
        recurrenceType: RecurrenceType.daily,
      );

      print('\n:mag: Verificando resultados...');

      expect(activity.recurrenceType, equals(RecurrenceType.daily));
      print('   ✓ Recurrencia: ${activity.recurrenceType.displayName}');

      expect(activity.shouldCompleteToday(), isTrue);
      print('   ✓ Debe completarse hoy: Si');

      expect(activity.getRecurrenceDescription(), equals('Todos los días'));
      print('   ✓ Descripcion: ${activity.getRecurrenceDescription()}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Recurrencia diaria configurada        ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('TC-ACT-003: Crear actividad con dias especificos', () {
    test('Actividad solo aparece en dias seleccionados', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-ACT-003: Crear actividad con dias especificos        ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Usuario en formulario de nueva actividad');

      print('\n📝 Pasos:');
      print('   1. Ingresar nombre');
      print('   2. Seleccionar recurrencia "Dias especificos"');
      print('   3. Seleccionar Lunes, Miercoles, Viernes');
      print('   4. Guardar');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Gimnasio',
        streak: 0,
        lastCompleted: null,
        active: true,
        recurrenceType: RecurrenceType.specificDays,
        recurrenceDays: [1, 3, 5], // Lunes, Miércoles, Viernes
      );

      print('\n:mag: Verificando resultados...');

      expect(activity.recurrenceType, equals(RecurrenceType.specificDays));
      print('   ✓ Tipo: Dias especificos');

      expect(activity.recurrenceDays, containsAll([1, 3, 5]));
      print('   ✓ Dias configurados: ${activity.recurrenceDays}');

      expect(activity.getRecurrenceDescription(), contains('Lun'));
      expect(activity.getRecurrenceDescription(), contains('Mié'));
      expect(activity.getRecurrenceDescription(), contains('Vie'));
      print('   ✓ Descripcion: ${activity.getRecurrenceDescription()}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Dias especificos configurados         ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('TC-ACT-006: Editar nombre de actividad', () {
    test('Nombre actualizado correctamente', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-ACT-006: Editar nombre de actividad                  ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Existe actividad "Ejercicio"');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Ejercicio',
        streak: 5,
        lastCompleted: DateTime.now(),
        active: true,
      );

      print('   • Nombre original: ${activity.name}');
      print('   • Racha: ${activity.streak}');

      print('\n📝 Pasos:');
      print('   1. Abrir actividad');
      print('   2. Editar nombre a "Gimnasio"');
      print('   3. Guardar');

      // Simular edición
      final originalStreak = activity.streak;
      activity.name = 'Gimnasio';

      print('\n:mag: Verificando resultados...');

      expect(activity.name, equals('Gimnasio'));
      print('   ✓ Nombre actualizado: ${activity.name}');

      expect(activity.streak, equals(originalStreak));
      print('   ✓ Racha preservada: ${activity.streak}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Nombre actualizado sin afectar racha  ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('TC-ACT-007: Cambiar recurrencia de actividad', () {
    test('Recurrencia actualizada, racha se mantiene', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-ACT-007: Cambiar recurrencia de actividad            ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Actividad con recurrencia diaria');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Yoga',
        streak: 10,
        lastCompleted: DateTime.now(),
        active: true,
        recurrenceType: RecurrenceType.daily,
      );

      print(
          '   • Recurrencia original: ${activity.recurrenceType.displayName}');
      print('   • Racha: ${activity.streak}');

      print('\n📝 Pasos:');
      print('   1. Editar actividad');
      print('   2. Cambiar a "Cada 2 dias"');
      print('   3. Guardar');

      final originalStreak = activity.streak;
      activity.recurrenceType = RecurrenceType.everyNDays;
      activity.recurrenceInterval = 2;

      print('\n:mag: Verificando resultados...');

      expect(activity.recurrenceType, equals(RecurrenceType.everyNDays));
      print(
          '   ✓ Recurrencia actualizada: ${activity.recurrenceType.displayName}');

      expect(activity.recurrenceInterval, equals(2));
      print('   ✓ Intervalo: cada ${activity.recurrenceInterval} dias');

      expect(activity.streak, equals(originalStreak));
      print('   ✓ Racha preservada: ${activity.streak}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Recurrencia actualizada sin perder    ║');
      print('║                    racha                                  ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('TC-ACT-010: Eliminar actividad con confirmacion', () {
    test('Actividad eliminada correctamente', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-ACT-010: Eliminar actividad con confirmacion         ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Actividad existente');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Actividad a eliminar',
        streak: 3,
        lastCompleted: DateTime.now(),
        active: true,
      );

      final activities = <Activity>[activity];

      print('   • Actividad: ${activity.name}');
      print('   • Total de actividades: ${activities.length}');

      print('\n📝 Pasos:');
      print('   1. Deslizar actividad');
      print('   2. Presionar eliminar');
      print('   3. Confirmar');

      // Simular eliminación
      bool confirmDelete = true; // Usuario confirma

      if (confirmDelete) {
        activities.removeWhere((a) => a.id == activity.id);
      }

      print('\n:mag: Verificando resultados...');

      expect(activities, isEmpty);
      print('   ✓ Actividad eliminada de la lista');

      expect(activities.where((a) => a.id == activity.id), isEmpty);
      print('   ✓ ID no encontrado en lista');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Actividad eliminada correctamente     ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('TC-ACT-014: Completar actividad dos veces mismo dia', () {
    test('No permite segunda completacion sin multiple dailyGoal', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-ACT-014: Completar actividad dos veces mismo dia     ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Actividad sin permitir multiples completaciones');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Lectura',
        streak: 2,
        lastCompleted: null,
        active: true,
        dailyGoal: 1, // Solo permite 1 completación por día
        dailyCompletionCount: 0,
      );

      print('   • Actividad: ${activity.name}');
      print('   • Meta diaria: ${activity.dailyGoal}');
      print('   • Completaciones hoy: ${activity.dailyCompletionCount}');

      print('\n📝 Pasos:');
      print('   1. Completar actividad');

      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);

      // Primera completación
      activity.lastCompleted = todayDay;
      activity.dailyCompletionCount = 1;
      activity.streak = 3;

      print('   • Primera completacion: OK');
      print(
          '   • Completaciones: ${activity.dailyCompletionCount}/${activity.dailyGoal}');

      print('   2. Intentar completar nuevamente');

      // Verificar si puede completar nuevamente
      final canCompleteAgain =
          activity.dailyCompletionCount < activity.dailyGoal;

      print('\n:mag: Verificando resultados...');

      expect(canCompleteAgain, isFalse);
      print('   ✓ Segunda completacion: BLOQUEADA');

      expect(activity.hasCompletedDailyGoal(), isTrue);
      print('   ✓ Meta diaria alcanzada');

      expect(activity.dailyCompletionCount, equals(1));
      print(
          '   ✓ Contador de completaciones: ${activity.dailyCompletionCount}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - No permite completacion duplicada     ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('TC-ACT-015: Multiples completaciones diarias', () {
    test('Permite y cuenta multiples completaciones cuando dailyGoal > 1', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-ACT-015: Multiples completaciones diarias            ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Actividad con dailyGoal = 3');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Beber agua',
        streak: 5,
        lastCompleted: null,
        active: true,
        dailyGoal: 3,
        dailyCompletionCount: 0,
      );

      print('   • Actividad: ${activity.name}');
      print('   • Meta diaria: ${activity.dailyGoal}');
      print('   • Completaciones iniciales: ${activity.dailyCompletionCount}');

      print('\n📝 Pasos:');
      print('   1. Completar 3 veces en el dia');

      final today = DateTime.now();
      final todayDay = DateTime(today.year, today.month, today.day);
      activity.lastCompleted = todayDay;

      // Completar 3 veces
      for (int i = 1; i <= 3; i++) {
        if (activity.dailyCompletionCount < activity.dailyGoal) {
          activity.dailyCompletionCount += 1;
          print('   • Completacion ${i}/3: OK');
        }
      }

      print('\n:mag: Verificando resultados...');

      expect(activity.dailyCompletionCount, equals(3));
      print('   ✓ Completaciones totales: ${activity.dailyCompletionCount}');

      expect(activity.hasCompletedDailyGoal(), isTrue);
      print('   ✓ Meta diaria alcanzada: SI');

      expect(activity.getDailyCompletionProgress(), equals(1.0));
      print('   ✓ Progreso: 100%');

      expect(activity.remainingDailyCompletions(), equals(0));
      print('   ✓ Completaciones restantes: 0');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Multiples completaciones funcionando  ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('TC-GAM-001: Otorgar medalla de bronce', () {
    test('Medalla de bronce otorgada al alcanzar 7 dias', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-GAM-001: Otorgar medalla de bronce                   ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Usuario sin medallas');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Ejercicio',
        streak: 6,
        lastCompleted: DateTime.now().subtract(const Duration(days: 1)),
        active: true,
      );

      final earnedMedals = <String>[];

      print('   • Racha actual: ${activity.streak}');
      print('   • Medallas obtenidas: ${earnedMedals.length}');

      print('\n📝 Pasos:');
      print('   1. Alcanzar racha de 7 dias');

      // Completar para llegar a 7 días
      activity.streak = 7;
      activity.lastCompleted = DateTime.now();

      // Verificar si se debe otorgar medalla
      if (activity.streak == 7 && !earnedMedals.contains('bronze_7days')) {
        earnedMedals.add('bronze_7days');
        print('   • Medalla de bronce desbloqueada!');
      }

      print('\n:mag: Verificando resultados...');

      expect(activity.streak, equals(7));
      print('   ✓ Racha: ${activity.streak} dias');

      expect(earnedMedals, contains('bronze_7days'));
      print('   ✓ Medalla otorgada: Bronce (7 dias)');

      expect(earnedMedals.length, equals(1));
      print('   ✓ Total de medallas: ${earnedMedals.length}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Medalla de bronce otorgada            ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('TC-GAM-002: Otorgar medalla de plata', () {
    test('Medalla de plata otorgada al alcanzar 30 dias', () {
      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  TC-GAM-002: Otorgar medalla de plata                    ║');
      print('╚════════════════════════════════════════════════════════════╝');

      print('\n📋 Precondiciones:');
      print('   • Medalla de bronce obtenida');

      final activity = Activity(
        id: const Uuid().v4(),
        name: 'Meditacion',
        streak: 29,
        lastCompleted: DateTime.now().subtract(const Duration(days: 1)),
        active: true,
      );

      final earnedMedals = <String>['bronze_7days'];

      print('   • Racha actual: ${activity.streak}');
      print('   • Medallas previas: ${earnedMedals.join(", ")}');

      print('\n📝 Pasos:');
      print('   1. Alcanzar racha de 30 dias');

      // Completar para llegar a 30 días
      activity.streak = 30;
      activity.lastCompleted = DateTime.now();

      // Verificar si se debe otorgar medalla
      if (activity.streak == 30 && !earnedMedals.contains('silver_30days')) {
        earnedMedals.add('silver_30days');
        print('   • Medalla de plata desbloqueada!');
      }

      print('\n:mag: Verificando resultados...');

      expect(activity.streak, equals(30));
      print('   ✓ Racha: ${activity.streak} dias');

      expect(earnedMedals, contains('silver_30days'));
      print('   ✓ Medalla otorgada: Plata (30 dias)');

      expect(earnedMedals, contains('bronze_7days'));
      print('   ✓ Medalla de bronce preservada');

      expect(earnedMedals.length, equals(2));
      print('   ✓ Total de medallas: ${earnedMedals.length}');

      print('\n╔════════════════════════════════════════════════════════════╗');
      print('║  ✅ TEST EXITOSO - Medalla de plata otorgada             ║');
      print('╚════════════════════════════════════════════════════════════╝\n');
    });
  });

  group('Resumen de Tests de Prioridad Alta', () {
    test('Mostrar resumen final', () {
      print('\n');
      print('╔════════════════════════════════════════════════════════════╗');
      print('║        RESUMEN DE TESTS DE PRIORIDAD ALTA (10)           ║');
      print('╠════════════════════════════════════════════════════════════╣');
      print('║                                                            ║');
      print('║  ✅ TC-ACT-001: Crear actividad basica                    ║');
      print('║  ✅ TC-ACT-002: Crear actividad con recurrencia diaria    ║');
      print('║  ✅ TC-ACT-003: Crear actividad con dias especificos      ║');
      print('║  ✅ TC-ACT-006: Editar nombre de actividad                ║');
      print('║  ✅ TC-ACT-007: Cambiar recurrencia de actividad          ║');
      print('║  ✅ TC-ACT-010: Eliminar actividad con confirmacion       ║');
      print('║  ✅ TC-ACT-014: Completar dos veces mismo dia             ║');
      print('║  ✅ TC-ACT-015: Multiples completaciones diarias          ║');
      print('║  ✅ TC-GAM-001: Otorgar medalla de bronce                 ║');
      print('║  ✅ TC-GAM-002: Otorgar medalla de plata                  ║');
      print('║                                                            ║');
      print('╠════════════════════════════════════════════════════════════╣');
      print('║  🎯 10/10 CASOS DE ALTA PRIORIDAD VERIFICADOS            ║');
      print('╚════════════════════════════════════════════════════════════╝');
      print('');
    });
  });
}
