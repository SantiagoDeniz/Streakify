import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../utils/activity_icons.dart';

class TimelineScreen extends StatelessWidget {
  final List<Activity> activities;

  const TimelineScreen({
    super.key,
    required this.activities,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Separar actividades en completadas y pendientes
    final completed = activities.where((a) {
      if (!a.active) return false;
      final lastCompleted = a.lastCompleted != null
          ? DateTime(
              a.lastCompleted!.year,
              a.lastCompleted!.month,
              a.lastCompleted!.day,
            )
          : null;
      return lastCompleted == today;
    }).toList();

    final pending = activities.where((a) {
      if (!a.active) return false;
      final lastCompleted = a.lastCompleted != null
          ? DateTime(
              a.lastCompleted!.year,
              a.lastCompleted!.month,
              a.lastCompleted!.day,
            )
          : null;
      return lastCompleted != today;
    }).toList();

    // Ordenar por hora de última completación (las más recientes primero)
    completed.sort((a, b) {
      if (a.lastCompleted == null) return 1;
      if (b.lastCompleted == null) return -1;
      return b.lastCompleted!.compareTo(a.lastCompleted!);
    });

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Timeline del Día'),
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'es').format(now),
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Progreso del día
          _buildDayProgress(
              completed.length, activities.where((a) => a.active).length),
          const SizedBox(height: 24),

          // Línea de tiempo de completadas
          if (completed.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Completadas (${completed.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...completed.map((activity) => _buildTimelineItem(
                  context,
                  activity,
                  isCompleted: true,
                )),
            const SizedBox(height: 24),
          ],

          // Línea de tiempo de pendientes
          if (pending.isNotEmpty) ...[
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.pending, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'Pendientes (${pending.length})',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...pending.map((activity) => _buildTimelineItem(
                  context,
                  activity,
                  isCompleted: false,
                )),
          ],

          if (completed.isEmpty && pending.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_available,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay actividades activas',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDayProgress(int completed, int total) {
    final percentage = total > 0 ? (completed / total * 100).round() : 0;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Progreso del Día',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: percentage == 100 ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: total > 0 ? completed / total : 0,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage == 100 ? Colors.green : Colors.blue,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$completed de $total actividades completadas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Activity activity, {
    required bool isCompleted,
  }) {
    final timeText = isCompleted && activity.lastCompleted != null
        ? DateFormat('HH:mm').format(activity.lastCompleted!)
        : '—:—';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Línea de tiempo
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? Colors.green : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Icon(
                  isCompleted ? Icons.check : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey[300],
              ),
            ],
          ),
          const SizedBox(width: 16),

          // Contenido
          Expanded(
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (activity.customIcon != null)
                          Icon(
                            ActivityIcons.getIcon(activity.customIcon),
                            color: activity.customColor != null
                                ? ActivityColors.getColor(activity.customColor)
                                : Colors.blue,
                            size: 20,
                          ),
                        if (activity.customIcon != null)
                          const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            activity.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          timeText,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isCompleted ? Colors.green : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 16,
                          color: Colors.orange[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${activity.streak} días de racha',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    if (activity.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: activity.tags
                            .take(3)
                            .map((tag) => Chip(
                                  label: Text(
                                    '#$tag',
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
