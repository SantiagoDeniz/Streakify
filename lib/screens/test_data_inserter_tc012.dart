import 'package:flutter/material.dart';
import 'package:streakify/models/activity.dart';
import 'package:streakify/services/activity_service.dart';
import 'package:uuid/uuid.dart';

/// Widget temporal para pruebas - Inserta datos de prueba para TC-ACT-012
class TestDataInserterTC012 extends StatelessWidget {
  const TestDataInserterTC012({Key? key}) : super(key: key);

  Future<void> _insertTestData(BuildContext context) async {
    try {
      final activityService = ActivityService();

      // Crear actividad con streak=5 completada ayer
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final yesterdayDay =
          DateTime(yesterday.year, yesterday.month, yesterday.day);

      final testActivity = Activity(
        id: const Uuid().v4(),
        name: 'TC-012 Meditación',
        streak: 5,
        lastCompleted: yesterdayDay,
        active: true,
        customIcon: 'self_improvement',
        customColor: '#9C27B0',
        recurrenceType: RecurrenceType.daily,
        dailyGoal: 1,
        protectorUsed: false,
      );

      await activityService.addActivity(testActivity);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Datos de prueba insertados\n'
              'Nombre: ${testActivity.name}\n'
              'Streak: ${testActivity.streak}\n'
              'Última completación: ${yesterdayDay.toString().split(' ')[0]}',
            ),
            duration: const Duration(seconds: 5),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insertar Datos de Prueba'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.science,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                'TC-ACT-012',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Insertar datos de prueba para\n"Completar actividad día consecutivo"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Datos a insertar:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('• Nombre: TC-012 Meditación'),
                      Text('• Streak: 5'),
                      Text('• Última completación: Ayer'),
                      Text('• Tipo: Diaria'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => _insertTestData(context),
                icon: const Icon(Icons.add_circle),
                label: const Text('Insertar Datos de Prueba'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Volver'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
