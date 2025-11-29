import 'package:flutter/material.dart';
import '../models/activity.dart';
import '../utils/activity_icons.dart';
import '../screens/activity_focus_screen.dart';
import 'animated_widgets.dart';

class ActivityCard extends StatelessWidget {
  final Activity activity;
  final VoidCallback onComplete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;
  final VoidCallback onUseProtector;
  final bool isCompactView;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.onComplete,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
    required this.onUseProtector,
    this.isCompactView = false,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = activity.lastCompleted != null
        ? DateTime(activity.lastCompleted!.year, activity.lastCompleted!.month,
            activity.lastCompleted!.day)
        : null;

    // Determinar estado de la actividad
    bool isCompletedToday = false;
    if (lastCompleted != null) {
      isCompletedToday = today.year == lastCompleted.year &&
          today.month == lastCompleted.month &&
          today.day == lastCompleted.day;

      // Check for multiple completions
      if (isCompletedToday &&
          activity.allowsMultipleCompletions() &&
          !activity.hasCompletedDailyGoal()) {
        isCompletedToday = false; // Still needs more completions
      }
    }

    if (isCompactView) {
      // Build semantic label for screen readers
      String semanticLabel = '${activity.name}. ';
      if (isCompletedToday) {
        semanticLabel += 'Completada hoy. ';
      } else {
        semanticLabel += 'Pendiente. ';
      }
      semanticLabel +=
          'Racha actual: ${activity.streak} ${activity.streak == 1 ? "día" : "días"}. ';

      if (activity.allowsMultipleCompletions()) {
        semanticLabel +=
            'Progreso: ${activity.dailyCompletionCount} de ${activity.dailyGoal} completaciones. ';
      }

      if (!activity.active) {
        semanticLabel += 'Actividad pausada. ';
      }

      return Semantics(
        label: semanticLabel,
        hint: 'Toca para ver detalles. Desliza para editar o eliminar.',
        button: false,
        child: Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Semantics(
              label: 'Icono de ${activity.name}',
              excludeSemantics: true,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ActivityColors.getColor(activity.customColor)
                      .withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  ActivityIcons.getIcon(activity.customIcon),
                  color: ActivityColors.getColor(activity.customColor),
                  size: 20,
                ),
              ),
            ),
            title: ExcludeSemantics(
              child: Text(
                activity.name,
                style: TextStyle(
                  decoration:
                      isCompletedToday ? TextDecoration.lineThrough : null,
                  color: isCompletedToday ? Colors.grey : null,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            subtitle: ExcludeSemantics(
              child: Text('Racha: ${activity.streak} días'),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (activity.allowsMultipleCompletions())
                  ExcludeSemantics(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Text(
                        '${activity.dailyCompletionCount}/${activity.dailyGoal}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Semantics(
                  label: isCompletedToday
                      ? 'Marcar como no completada'
                      : 'Completar actividad',
                  button: true,
                  enabled: true,
                  child: IconButton(
                    icon: Icon(
                      isCompletedToday
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: isCompletedToday ? Colors.green : Colors.grey,
                    ),
                    onPressed: onComplete,
                  ),
                ),
              ],
            ),
            onTap: () {
              // Expand logic if needed, or navigate
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityFocusScreen(
                    activity: activity,
                    onComplete: onComplete,
                    onEdit: onEdit,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }
    final bool completedToday = lastCompleted == today;
    final bool isAtRisk = lastCompleted != null &&
        !completedToday &&
        today.difference(lastCompleted).inDays >= 1;

    // Color del borde según estado
    Color? borderColor;
    if (!activity.active) {
      borderColor = Colors.grey;
    } else if (completedToday) {
      borderColor = Colors.green;
    } else if (isAtRisk) {
      borderColor = Colors.orange;
    }

    // Build semantic label for full card view
    String fullSemanticLabel = '${activity.name}. ';
    if (completedToday) {
      fullSemanticLabel += 'Completada hoy. ';
    } else if (isAtRisk) {
      fullSemanticLabel += 'En riesgo de perder racha. ';
    } else {
      fullSemanticLabel += 'Pendiente. ';
    }
    fullSemanticLabel +=
        'Racha actual: ${activity.streak} ${activity.streak == 1 ? "día" : "días"}. ';

    if (!activity.active) {
      fullSemanticLabel += 'Actividad pausada. ';
    }

    return Semantics(
      label: fullSemanticLabel,
      hint:
          'Toca para ver detalles. Desliza a la derecha para editar, o a la izquierda para eliminar.',
      button: false,
      child: Dismissible(
        key: Key(activity.id),
        background: _buildSwipeBackground(
          alignment: Alignment.centerLeft,
          color: Colors.blue,
          icon: Icons.edit,
          text: 'Editar',
        ),
        secondaryBackground: _buildSwipeBackground(
          alignment: Alignment.centerRight,
          color: Colors.red,
          icon: Icons.delete,
          text: 'Eliminar',
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            // Deslizar hacia la izquierda - Eliminar
            return await _showConfirmDialog(
              context,
              title: 'Eliminar actividad',
              content: '¿Estás seguro de eliminar "${activity.name}"?',
              confirmText: 'Eliminar',
              confirmColor: Colors.red,
              onConfirm: onDelete,
            );
          } else if (direction == DismissDirection.startToEnd) {
            // Deslizar hacia la derecha - Editar
            await _showConfirmDialog(
              context,
              title: 'Editar actividad',
              content: '¿Deseas editar "${activity.name}"?',
              confirmText: 'Editar',
              confirmColor: Colors.blue,
              onConfirm: onEdit,
            );
            return false; // No dismissar la tarjeta al editar
          }
          return false;
        },
        child: Opacity(
          opacity: activity.active ? 1.0 : 0.5,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityFocusScreen(
                    activity: activity,
                    onComplete: onComplete,
                    onEdit: onEdit,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: completedToday
                    ? (Theme.of(context).brightness == Brightness.dark
                        ? Colors.green[900]?.withOpacity(0.3)
                        : Colors.green[50])
                    : (Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[900]
                        : Colors.white),
                borderRadius: BorderRadius.circular(12),
                boxShadow: Theme.of(context).brightness == Brightness.dark
                    ? []
                    : [
                        BoxShadow(
                            color: completedToday
                                ? Colors.green.withOpacity(0.3)
                                : Colors.black26,
                            blurRadius: 4,
                            offset: const Offset(0, 2))
                      ],
                border: Border.all(
                  color: borderColor ?? Colors.transparent,
                  width: borderColor != null ? 2 : 0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Icono personalizado o de estado
                      ExcludeSemantics(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: activity.customColor != null
                                ? ActivityColors.getColor(activity.customColor)
                                    .withOpacity(0.2)
                                : (completedToday
                                    ? Colors.green.withOpacity(0.2)
                                    : (isAtRisk
                                        ? Colors.orange.withOpacity(0.2)
                                        : Colors.blue.withOpacity(0.2))),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            activity.customIcon != null
                                ? ActivityIcons.getIcon(activity.customIcon)
                                : (completedToday
                                    ? Icons.check_circle
                                    : (isAtRisk
                                        ? Icons.warning_amber
                                        : Icons.local_fire_department)),
                            color: activity.customColor != null
                                ? ActivityColors.getColor(activity.customColor)
                                : (completedToday
                                    ? Colors.green
                                    : (isAtRisk ? Colors.orange : Colors.blue)),
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre de la actividad
                            ExcludeSemantics(
                              child: Text(
                                activity.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                  decoration: activity.active
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Racha actual
                            ExcludeSemantics(
                              child: Row(
                                children: [
                                  const Icon(Icons.local_fire_department,
                                      size: 16, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  BouncingCounter(
                                    value: activity.streak,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.orange[300]
                                          : Colors.orange[700],
                                    ),
                                  ),
                                  Text(
                                    ' ${activity.streak == 1 ? "día" : "días"} de racha',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.orange[300]
                                          : Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: color,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
                onPressed: () {
                  onConfirm();
                  Navigator.pop(context, true);
                },
                child: Text(confirmText),
              ),
            ],
          ),
        ) ??
        false;
  }
}
