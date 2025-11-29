import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../utils/activity_icons.dart';

class ActivityCardTablet extends StatelessWidget {
  final Activity activity;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onUseProtector;

  const ActivityCardTablet({
    super.key,
    required this.activity,
    required this.onComplete,
    required this.onEdit,
    required this.onToggleActive,
    required this.onUseProtector,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = activity.lastCompleted != null
        ? DateTime(activity.lastCompleted!.year, activity.lastCompleted!.month,
            activity.lastCompleted!.day)
        : null;

    final bool completedToday = lastCompleted == today;
    final bool isAtRisk = lastCompleted != null &&
        !completedToday &&
        today.difference(lastCompleted).inDays >= 1;

    Color? borderColor;
    if (!activity.active) {
      borderColor = Colors.grey;
    } else if (completedToday) {
      borderColor = Colors.green;
    } else if (isAtRisk) {
      borderColor = Colors.orange;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor ?? Colors.transparent,
          width: borderColor != null ? 2 : 0,
        ),
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: activity.customColor != null
                          ? ActivityColors.getColor(activity.customColor)
                              .withOpacity(0.2)
                          : (completedToday
                              ? Colors.green.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      activity.customIcon != null
                          ? ActivityIcons.getIcon(activity.customIcon)
                          : (completedToday
                              ? Icons.check_circle
                              : Icons.local_fire_department),
                      color: activity.customColor != null
                          ? ActivityColors.getColor(activity.customColor)
                          : (completedToday ? Colors.green : Colors.blue),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activity.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 20),
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'toggle') onToggleActive();
                      if (value == 'protector') onUseProtector();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Editar'),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Text(activity.active ? 'Pausar' : 'Activar'),
                      ),
                      if (!activity.protectorUsed)
                        const PopupMenuItem(
                          value: 'protector',
                          child: Text('Usar Protector'),
                        ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Racha',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              size: 14, color: Colors.orange),
                          Text(
                            '${activity.streak}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (!completedToday && activity.active)
                    ElevatedButton(
                      onPressed: onComplete,
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(12),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: const Icon(Icons.check, color: Colors.white),
                    )
                  else if (completedToday)
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 32),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
