import 'package:flutter/material.dart';
import '../models/activity.dart';

class StatisticsScreen extends StatelessWidget {
  final List<Activity> activities;

  const StatisticsScreen({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final activeActivities = activities.where((a) => a.active).toList();
    final totalActivities = activities.length;
    final activeCount = activeActivities.length;

    // Calcular estadísticas
    int maxStreak = 0;
    int totalDays = 0;
    Activity? bestActivity;

    for (var activity in activities) {
      totalDays += activity.streak;
      if (activity.streak > maxStreak) {
        maxStreak = activity.streak;
        bestActivity = activity;
      }
    }

    final completedToday = activeActivities.where((a) {
      if (a.lastCompleted == null) return false;
      final today = DateTime.now();
      final completed = a.lastCompleted!;
      return completed.year == today.year &&
          completed.month == today.month &&
          completed.day == today.day;
    }).length;

    final completionRate = activeCount > 0
        ? (completedToday / activeCount * 100).toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatCard(
            context,
            icon: Icons.emoji_events,
            iconColor: Colors.amber,
            title: 'Racha más larga',
            value: '$maxStreak días',
            subtitle:
                bestActivity != null ? bestActivity.name : 'Sin actividades',
          ),
          _buildStatCard(
            context,
            icon: Icons.calendar_today,
            iconColor: Colors.blue,
            title: 'Total de días completados',
            value: '$totalDays días',
            subtitle: 'En todas las actividades',
          ),
          _buildStatCard(
            context,
            icon: Icons.check_circle,
            iconColor: Colors.green,
            title: 'Completadas hoy',
            value: '$completedToday de $activeCount',
            subtitle: '$completionRate% de cumplimiento',
          ),
          _buildStatCard(
            context,
            icon: Icons.list,
            iconColor: Colors.purple,
            title: 'Total de actividades',
            value: '$totalActivities',
            subtitle:
                '$activeCount activas, ${totalActivities - activeCount} pausadas',
          ),
          const SizedBox(height: 20),
          const Text(
            'Ranking de actividades',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...(activities.where((a) => a.streak > 0).toList()
                ..sort((a, b) => b.streak.compareTo(a.streak)))
              .take(10)
              .map((activity) => _buildRankingItem(context, activity)),
          if (activities.where((a) => a.streak > 0).isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Aún no hay rachas registradas.\n¡Empieza a completar actividades!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(BuildContext context, Activity activity) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange.withOpacity(0.2),
        child: const Icon(Icons.local_fire_department, color: Colors.orange),
      ),
      title: Text(activity.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              color: Colors.orange, size: 20),
          const SizedBox(width: 4),
          Text(
            '${activity.streak}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
