import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'dart:ui';
import '../models/activity.dart';
import '../models/completion_history.dart';
import '../services/activity_service.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';
import '../services/backup_service.dart';
import '../services/database_helper.dart';
import '../services/personalization_service.dart';
import '../services/theme_service.dart';
import '../widgets/home_widget_service.dart';
import '../widgets/category_selector.dart';
import '../widgets/tag_input.dart';
import '../widgets/recurrence_selector.dart';
import '../widgets/streak_config_widget.dart';
import '../widgets/template_selector.dart';
import '../widgets/shimmer_widgets.dart';
import '../widgets/animated_widgets.dart';
import '../widgets/activity_visualizations.dart';
import '../models/activity_template.dart';
import '../utils/activity_icons.dart';
import '../themes/app_themes.dart';
import 'statistics_screen.dart';
import 'achievements_screen.dart';
import 'backup_screen.dart';
import 'calendar_screen.dart';
import 'timeline_screen.dart';
import 'activity_focus_screen.dart';
import 'achievement_gallery_screen.dart';
import 'dashboard_screen.dart';
import 'gamification_screen.dart';
import 'notification_settings_screen.dart';
import 'accessibility_settings_screen.dart';
import 'personalization_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'social_screen.dart';
import '../services/gamification_service.dart';
import '../utils/responsive_helper.dart';
import '../widgets/activity_card_tablet.dart';
import '../widgets/confetti_widget.dart';

class HomeScreen extends StatefulWidget {
  final Function(AppThemeMode)? onThemeChanged;
  final PersonalizationService? personalizationService;
  final ThemeService? themeService;

  const HomeScreen({
    super.key,
    this.onThemeChanged,
    this.personalizationService,
    this.themeService,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActivityService _service = ActivityService();
  final AchievementService _achievementService = AchievementService();
  final GamificationService _gamification = GamificationService();
  List<Activity> _activities = [];
  String _filterMode = 'all'; // 'all', 'active', 'paused'
  String _sortMode = 'name'; // 'name', 'streak', 'recent'
  String? _selectedCategoryFilter; // Filtro por categoría
  String? _selectedTagFilter; // Filtro por tag
  late ConfettiController _confettiController;
  bool _isLoading = true;
  bool _isCompactView = false;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _load();
    _initAchievements();
    _initNotifications();
    _checkAutoBackup();
  }

  Future<void> _initAchievements() async {
    await _achievementService.loadAchievements();
  }

  Future<void> _initNotifications() async {
    // Reprogramar todas las notificaciones de actividades al iniciar la app
    final notificationService = NotificationService();
    await notificationService.rescheduleAllActivityNotifications(_activities);
  }

  Future<void> _checkAutoBackup() async {
    // Verificar y crear backup automático si es necesario
    final backupService = BackupService();
    await backupService.checkAndCreateAutoBackup();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Helper para mostrar diálogos con animación
  Future<T?> _showAnimatedDialog<T>(Widget dialog) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => dialog,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final list = await _service.loadActivities();
    setState(() {
      _activities = list;
      _isLoading = false;
    });
    HomeWidgetService.updateWidget(_activities);
    // Reprogramar notificaciones después de cargar actividades
    _initNotifications();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCompactView = prefs.getBool('compact_view') ?? false;
    });
  }

  Future<void> _toggleViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCompactView = !_isCompactView;
    });
    await prefs.setBool('compact_view', _isCompactView);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Activity item = _activities.removeAt(oldIndex);
      _activities.insert(newIndex, item);
    });
    _save();
  }

  Future<void> _save() async => _service.saveActivities(_activities);

  void _addActivity(
    String name, {
    String? categoryId,
    List<String>? tags,
    RecurrenceType recurrenceType = RecurrenceType.daily,
    int recurrenceInterval = 1,
    List<int> recurrenceDays = const [],
    int? targetDays,
    int allowedFailures = 0,
    List<int> freeDays = const [],
    int? partialGoalRequired,
    int? partialGoalTotal,
    int dailyGoal = 1,
    String? customIcon,
    String? customColor,
  }) {
    final newAct = Activity(
      id: const Uuid().v4(),
      name: name,
      categoryId: categoryId,
      tags: tags ?? [],
      recurrenceType: recurrenceType,
      recurrenceInterval: recurrenceInterval,
      recurrenceDays: recurrenceDays.toList(),
      startDate: DateTime.now(), // Fecha de inicio es hoy
      targetDays: targetDays,
      allowedFailures: allowedFailures,
      freeDays: freeDays.toList(),
      partialGoalRequired: partialGoalRequired,
      partialGoalTotal: partialGoalTotal,
      dailyGoal: dailyGoal,
      customIcon: customIcon,
      customColor: customColor,
    );
    setState(() => _activities.add(newAct));
    _save();
    HomeWidgetService.updateWidget(_activities);
  }

  void _delete(Activity act) {
    setState(() => _activities.remove(act));
    _save();
    HomeWidgetService.updateWidget(_activities);
  }

  void _editActivity(Activity act) {
    String newName = act.name;
    String? newCategoryId = act.categoryId;
    List<String> newTags = List.from(act.tags);
    String? newCustomIcon = act.customIcon;
    String? newCustomColor = act.customColor;
    RecurrenceType newRecurrenceType = act.recurrenceType;
    int newRecurrenceInterval = act.recurrenceInterval;
    List<int> newRecurrenceDays = List.from(act.recurrenceDays);
    int? newTargetDays = act.targetDays;
    int newAllowedFailures = act.allowedFailures;
    List<int> newFreeDays = List.from(act.freeDays);
    int? newPartialGoalRequired = act.partialGoalRequired;
    int? newPartialGoalTotal = act.partialGoalTotal;
    int newDailyGoal = act.dailyGoal;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Editar actividad'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: TextEditingController(text: act.name),
                  decoration: const InputDecoration(
                    hintText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => newName = val,
                  autofocus: true,
                ),
                const SizedBox(height: 16),

                // Selector de icono
                OutlinedButton.icon(
                  onPressed: () async {
                    final selectedIcon =
                        await _showIconPickerDialog(context, newCustomIcon);
                    if (selectedIcon != null) {
                      setDialogState(() {
                        newCustomIcon = selectedIcon;
                      });
                    }
                  },
                  icon: Icon(
                    ActivityIcons.getIcon(newCustomIcon),
                    color: ActivityColors.getColor(newCustomColor),
                  ),
                  label: Text(newCustomIcon == null
                      ? 'Seleccionar icono'
                      : 'Cambiar icono'),
                ),
                const SizedBox(height: 16),

                // Selector de color
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ActivityColors.colorsList.map((colorEntry) {
                    final colorHex =
                        ActivityColors.colorToHex(colorEntry.value);
                    final isSelected = newCustomColor == colorHex;
                    return GestureDetector(
                      onTap: () {
                        setDialogState(() {
                          newCustomColor = colorHex;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorEntry.value,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.black
                                : Colors.grey.shade300,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                CategorySelector(
                  selectedCategoryId: newCategoryId,
                  onCategorySelected: (categoryId) {
                    newCategoryId = categoryId;
                  },
                ),
                const SizedBox(height: 16),
                TagInput(
                  initialTags: newTags,
                  onTagsChanged: (tags) {
                    newTags = tags;
                  },
                ),
                const SizedBox(height: 16),
                RecurrenceSelector(
                  selectedType: newRecurrenceType,
                  interval: newRecurrenceInterval,
                  selectedDays: newRecurrenceDays,
                  onRecurrenceChanged: (type, interval, days) {
                    newRecurrenceType = type;
                    newRecurrenceInterval = interval;
                    newRecurrenceDays = days;
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: TextEditingController(
                      text: newTargetDays?.toString() ?? ''),
                  decoration: const InputDecoration(
                    labelText: 'Meta de días (opcional)',
                    hintText: 'Ej: 30, 100, 365',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.flag),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    newTargetDays =
                        parsed != null && parsed > 0 ? parsed : null;
                  },
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                StreakConfigWidget(
                  allowedFailures: newAllowedFailures,
                  freeDays: newFreeDays,
                  partialGoalRequired: newPartialGoalRequired,
                  partialGoalTotal: newPartialGoalTotal,
                  dailyGoal: newDailyGoal,
                  onChanged: (failures, days, partialReq, partialTotal, daily) {
                    newAllowedFailures = failures;
                    newFreeDays = days;
                    newPartialGoalRequired = partialReq;
                    newPartialGoalTotal = partialTotal;
                    newDailyGoal = daily;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newName.trim().isNotEmpty) {
                  setState(() {
                    act.name = newName.trim();
                    act.categoryId = newCategoryId;
                    act.tags = newTags;
                    act.customIcon = newCustomIcon;
                    act.customColor = newCustomColor;
                    act.recurrenceType = newRecurrenceType;
                    act.recurrenceInterval = newRecurrenceInterval;
                    act.recurrenceDays = newRecurrenceDays;
                    act.targetDays = newTargetDays;
                    act.allowedFailures = newAllowedFailures;
                    act.freeDays = newFreeDays;
                  });
                  _save();
                  HomeWidgetService.updateWidget(_activities);
                }
                Navigator.pop(context);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityNotificationDialog(Activity act) async {
    bool notificationsEnabled = act.notificationsEnabled;
    int selectedHour = act.notificationHour;
    int selectedMinute = act.notificationMinute;
    String customMessage = act.customMessage ?? '';

    final result = await _showAnimatedDialog<bool>(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            const Expanded(child: Text('Notificaciones')),
          ],
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configurar notificación para:',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    act.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Switch de habilitar/deshabilitar
                  SwitchListTile(
                    title: const Text('Habilitar notificación'),
                    subtitle: Text(
                      notificationsEnabled
                          ? 'Recibirás recordatorios diarios'
                          : 'Sin notificaciones',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setDialogState(() {
                        notificationsEnabled = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  // Selector de hora
                  if (notificationsEnabled) ...[
                    const Text(
                      'Hora de la notificación:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(
                          '${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: const Icon(Icons.edit),
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: selectedHour,
                              minute: selectedMinute,
                            ),
                          );
                          if (picked != null) {
                            setDialogState(() {
                              selectedHour = picked.hour;
                              selectedMinute = picked.minute;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Campo de mensaje personalizado
                    const Text(
                      'Mensaje personalizado (opcional):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: TextEditingController(text: customMessage)
                        ..selection = TextSelection.fromPosition(
                          TextPosition(offset: customMessage.length),
                        ),
                      decoration: InputDecoration(
                        hintText: '¡Es hora de completar "${act.name}"!',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.message),
                        helperText:
                            'Deja vacío para usar el mensaje predeterminado',
                        helperMaxLines: 2,
                      ),
                      maxLines: 2,
                      onChanged: (val) => customMessage = val,
                    ),
                  ],
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == true) {
      // Actualizar la actividad con la nueva configuración
      setState(() {
        act.notificationsEnabled = notificationsEnabled;
        act.notificationHour = selectedHour;
        act.notificationMinute = selectedMinute;
        act.customMessage =
            customMessage.trim().isEmpty ? null : customMessage.trim();
      });

      await _save();

      // Actualizar la notificación programada
      final notificationService = NotificationService();
      await notificationService.updateActivityNotification(act);

      // Mostrar mensaje de confirmación
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              notificationsEnabled
                  ? '✅ Notificación configurada para ${selectedHour.toString().padLeft(2, '0')}:${selectedMinute.toString().padLeft(2, '0')}'
                  : '🔕 Notificación desactivada',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _toggleActive(Activity act) {
    setState(() => act.active = !act.active);
    _save();
    HomeWidgetService.updateWidget(_activities);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(act.active ? '${act.name} activada' : '${act.name} pausada'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _markCompleted(Activity act) async {
    if (!act.active) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta actividad está pausada. Actívala primero.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Skip if frozen
    if (act.isCurrentlyFrozen()) {
      final daysRemaining = act.daysRemainingFrozen();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '❄️ Actividad congelada. ${daysRemaining > 0 ? "Quedan $daysRemaining días" : "Termina hoy"}'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final today = DateTime.now();
    final last = act.lastCompleted != null
        ? DateTime(act.lastCompleted!.year, act.lastCompleted!.month,
            act.lastCompleted!.day)
        : null;
    final nowDay = DateTime(today.year, today.month, today.day);

    // Check if we can still complete today (multiple completions)
    if (last == nowDay) {
      if (act.allowsMultipleCompletions() && !act.hasCompletedDailyGoal()) {
        // Increment daily completion count
        act.dailyCompletionCount += 1;

        final completion = CompletionHistory(
          id: const Uuid().v4(),
          activityId: act.id,
          completedAt: DateTime.now(),
          protectorUsed: false,
        );
        await DatabaseHelper().insertCompletion(completion);

        _save();
        HomeWidgetService.updateWidget(_activities);
        setState(() {});

        final remaining = act.remainingDailyCompletions();
        if (remaining == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '🎯 ¡Meta diaria completada! (${act.dailyGoal}/${act.dailyGoal})'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
          _confettiController.play();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✓ Completado ${act.dailyCompletionCount}/${act.dailyGoal}. Faltan $remaining más'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: 'Agregar nota',
                onPressed: () => _showAddNoteDialog(completion.id, act.name),
              ),
            ),
          );
        }
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya completaste esta actividad hoy!'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    bool usedProtector = false;

    // Verificar si se rompió la racha (pasó más de 1 día desde la última vez)
    if (last != null && nowDay.difference(last).inDays > 1) {
      // Se rompió la racha - verificar protector
      if (!act.protectorUsed &&
          (act.nextProtectorAvailable == null ||
              DateTime.now().isAfter(act.nextProtectorAvailable!))) {
        // Tiene protector disponible - preguntar si quiere usarlo
        _showProtectorDialog(act, nowDay);
        return;
      } else {
        // No tiene protector disponible, se reinicia la racha
        act.streak = 1;
        act.lastCompleted = nowDay;
        act.weeklyCompletionCount = 0; // Reset weekly counter
      }
    } else if (last != null && nowDay.difference(last).inDays == 1) {
      // Racha continua (completó ayer)
      act.streak += 1;
      act.lastCompleted = nowDay;
    } else if (last == null) {
      // Primera vez
      act.streak = 1;
      act.lastCompleted = nowDay;
    }

    // Update daily completion count (reset to 1 for new day)
    act.dailyCompletionCount = 1;

    // Update weekly completion count for partial goals
    if (act.hasPartialGoal()) {
      // Check if we're in a new week (Monday = start of week)
      final lastWeekNumber = last != null
          ? ((last.difference(DateTime(last.year, 1, 1)).inDays) / 7).floor()
          : -1;
      final currentWeekNumber =
          ((nowDay.difference(DateTime(nowDay.year, 1, 1)).inDays) / 7).floor();

      if (lastWeekNumber != currentWeekNumber) {
        // New week started - reset counter
        act.weeklyCompletionCount = 1;
      } else {
        // Same week - increment
        act.weeklyCompletionCount += 1;
      }
    }

    // Guardar completación en el historial
    final completion = CompletionHistory(
      id: const Uuid().v4(),
      activityId: act.id,
      completedAt: DateTime.now(),
      protectorUsed: usedProtector,
    );
    await DatabaseHelper().insertCompletion(completion);

    _save();
    HomeWidgetService.updateWidget(_activities);
    setState(() {});

    // Verificar logros desbloqueados
    _checkAchievements();

    // Lanzar confetti
    _confettiController.play();

    // Mostrar celebración si alcanza hito o meta parcial
    String message = '✓ Completado! Racha: ${act.streak} días';

    if (act.hasPartialGoal() && act.hasMetPartialGoal()) {
      message =
          '🎯 ¡Meta semanal alcanzada! ${act.weeklyCompletionCount}/${act.partialGoalRequired} días';
    } else if (act.hasPartialGoal()) {
      final remaining = act.daysRemainingForPartialGoal();
      message =
          '✓ Completado! Progreso semanal: ${act.weeklyCompletionCount}/${act.partialGoalRequired} (faltan $remaining)';
    }

    if (act.streak % 7 == 0 && act.streak > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 ¡${act.streak} días de racha en ${act.name}!'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Agregar nota',
            onPressed: () => _showAddNoteDialog(completion.id, act.name),
          ),
        ),
      );
    }
  }

  Future<void> _checkAchievements() async {
    final newAchievements =
        await _achievementService.checkAndUnlockAchievements(_activities);

    if (newAchievements.isNotEmpty && mounted) {
      for (var achievement in newAchievements) {
        // Award medal for the achievement based on its required value
        final medal = await _gamification.awardStreakMedal(
          achievement.requiredValue,
          achievement.id,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(achievement.icon, color: achievement.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '🏆 ¡Logro desbloqueado!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(achievement.title),
                      if (medal != null)
                        Text(
                          '🎖️ Medalla ${medal.tier.name} (+${medal.tier.points} pts)',
                          style: const TextStyle(fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
            backgroundColor: achievement.color,
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AchievementsScreen(),
                  ),
                );
              },
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }

    // Check for consistency rewards (after any achievement check)
    final newRewards = await _gamification.checkConsistencyRewards(_activities);
    if (newRewards.isNotEmpty && mounted) {
      for (var reward in newRewards) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.stars, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '⭐ ¡Recompensa de Consistencia!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                          '${reward.daysRequired} días consecutivos (+${reward.daysRequired * 2} pts)'),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.deepPurple,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 400));
      }
    }

    // Update weekly challenge progress
    await _gamification.updateChallengeProgress(_activities);
  }

  void _showProtectorDialog(Activity act, DateTime nowDay) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🛡️ Protector de Racha'),
        content: Text('Tu racha de ${act.streak} días está en riesgo!\n\n'
            '¿Quieres usar el protector de racha para mantenerla?\n\n'
            'Si lo usas, mantendrás tu racha pero aún debes completar la actividad HOY.'),
        actions: [
          TextButton(
            onPressed: () {
              // No usar protector, reiniciar racha
              setState(() {
                act.streak = 1;
                act.lastCompleted = nowDay;
              });
              _save();
              HomeWidgetService.updateWidget(_activities);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Racha reiniciada a 1 día'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('No usar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Usar protector - mantener racha pero NO completar hoy automáticamente
              setState(() {
                act.protectorUsed = true;
                act.nextProtectorAvailable =
                    DateTime.now().add(const Duration(days: 5));
                // Actualizar lastCompleted al día anterior para que pueda completar hoy
                act.lastCompleted = nowDay.subtract(const Duration(days: 1));
                // La racha se mantiene sin cambios
              });

              // Registrar uso de protector en el historial (día faltante)
              final protectorCompletion = CompletionHistory(
                id: const Uuid().v4(),
                activityId: act.id,
                completedAt: nowDay.subtract(const Duration(days: 1)),
                protectorUsed: true,
              );
              await DatabaseHelper().insertCompletion(protectorCompletion);

              _save();
              HomeWidgetService.updateWidget(_activities);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '🛡️ Protector usado! Racha de ${act.streak} días mantenida.\nAhora completa tu actividad HOY.'),
                  duration: const Duration(seconds: 4),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Usar protector'),
          ),
        ],
      ),
    );
  }

  void _manualUseProtector(Activity act) {
    if (act.protectorUsed &&
        act.nextProtectorAvailable != null &&
        DateTime.now().isBefore(act.nextProtectorAvailable!)) {
      final daysLeft =
          act.nextProtectorAvailable!.difference(DateTime.now()).inDays;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Protector disponible en $daysLeft días'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('🛡️ Información del Protector'),
        content: const Text(
            'El protector se usa automáticamente cuando se rompe tu racha.\n\n'
            'Se recarga cada 5 días después de usarse.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  void _showAddNoteDialog(String completionId, String activityName) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Nota para $activityName'),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: '¿Cómo te fue hoy?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (noteController.text.trim().isNotEmpty) {
                // Actualizar la completación con la nota
                await DatabaseHelper().updateCompletionNote(
                  completionId,
                  noteController.text.trim(),
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📝 Nota guardada'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    String name = '';
    String? selectedCategoryId;
    List<String> selectedTags = [];
    RecurrenceType recurrenceType = RecurrenceType.daily;
    int recurrenceInterval = 1;
    List<int> recurrenceDays = [];
    int? targetDays;
    int allowedFailures = 0;
    List<int> freeDays = [];
    int? partialGoalRequired;
    int? partialGoalTotal;
    int dailyGoal = 1;
    String? customIcon;
    String? customColor;

    _showAnimatedDialog(
      AlertDialog(
        title: Row(
          children: [
            const Text('Nueva actividad'),
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showTemplateDialog((template) {
                  // Aplicar plantilla y reabrir dialog con datos prellenados
                  _showAddDialogWithTemplate(template);
                });
              },
              icon: const Icon(Icons.view_module, size: 18),
              label: const Text('Plantillas'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => name = val,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              CategorySelector(
                selectedCategoryId: selectedCategoryId,
                onCategorySelected: (categoryId) {
                  selectedCategoryId = categoryId;
                },
              ),
              const SizedBox(height: 16),
              TagInput(
                initialTags: selectedTags,
                onTagsChanged: (tags) {
                  selectedTags = tags;
                },
              ),
              const SizedBox(height: 16),
              RecurrenceSelector(
                selectedType: recurrenceType,
                interval: recurrenceInterval,
                selectedDays: recurrenceDays,
                onRecurrenceChanged: (type, interval, days) {
                  recurrenceType = type;
                  recurrenceInterval = interval;
                  recurrenceDays = days;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Meta de días (opcional)',
                  hintText: 'Ej: 30, 100, 365',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.flag),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  targetDays = parsed != null && parsed > 0 ? parsed : null;
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              StreakConfigWidget(
                allowedFailures: allowedFailures,
                freeDays: freeDays,
                partialGoalRequired: partialGoalRequired,
                partialGoalTotal: partialGoalTotal,
                dailyGoal: dailyGoal,
                onChanged: (failures, days, partialReq, partialTotal, daily) {
                  allowedFailures = failures;
                  freeDays = days;
                  partialGoalRequired = partialReq;
                  partialGoalTotal = partialTotal;
                  dailyGoal = daily;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.trim().isNotEmpty) {
                _addActivity(
                  name.trim(),
                  categoryId: selectedCategoryId,
                  tags: selectedTags,
                  recurrenceType: recurrenceType,
                  recurrenceInterval: recurrenceInterval,
                  recurrenceDays: recurrenceDays,
                  targetDays: targetDays,
                  allowedFailures: allowedFailures,
                  freeDays: freeDays,
                  partialGoalRequired: partialGoalRequired,
                  partialGoalTotal: partialGoalTotal,
                  dailyGoal: dailyGoal,
                  customIcon: customIcon,
                  customColor: customColor,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showTemplateDialog(Function(ActivityTemplate) onTemplateSelected) {
    _showAnimatedDialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TemplateSelector(
            onTemplateSelected: (template) {
              Navigator.pop(context);
              onTemplateSelected(template);
            },
          ),
        ),
      ),
    );
  }

  void _showAddDialogWithTemplate(ActivityTemplate template) {
    String name = template.name;
    String? selectedCategoryId = template.categoryId;
    List<String> selectedTags = List.from(template.suggestedTags);
    RecurrenceType recurrenceType = template.defaultRecurrence;
    int recurrenceInterval = 1;
    List<int> recurrenceDays = [];
    int? targetDays = template.defaultTargetDays;
    int allowedFailures = 0;
    List<int> freeDays = [];
    int? partialGoalRequired;
    int? partialGoalTotal;
    int dailyGoal = 1;
    String? customIcon = template.iconName;
    String? customColor = template.colorHex;

    _showAnimatedDialog(
      AlertDialog(
        title: const Text('Nueva actividad (desde plantilla)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: TextEditingController(text: name),
                decoration: const InputDecoration(
                  hintText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => name = val,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              CategorySelector(
                selectedCategoryId: selectedCategoryId,
                onCategorySelected: (categoryId) {
                  selectedCategoryId = categoryId;
                },
              ),
              const SizedBox(height: 16),
              TagInput(
                initialTags: selectedTags,
                onTagsChanged: (tags) {
                  selectedTags = tags;
                },
              ),
              const SizedBox(height: 16),
              RecurrenceSelector(
                selectedType: recurrenceType,
                interval: recurrenceInterval,
                selectedDays: recurrenceDays,
                onRecurrenceChanged: (type, interval, days) {
                  recurrenceType = type;
                  recurrenceInterval = interval;
                  recurrenceDays = days;
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller:
                    TextEditingController(text: targetDays?.toString() ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Meta de días (opcional)',
                  hintText: 'Ej: 30, 100, 365',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.flag),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  targetDays = parsed != null && parsed > 0 ? parsed : null;
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              StreakConfigWidget(
                allowedFailures: allowedFailures,
                freeDays: freeDays,
                partialGoalRequired: partialGoalRequired,
                partialGoalTotal: partialGoalTotal,
                dailyGoal: dailyGoal,
                onChanged: (failures, days, partialReq, partialTotal, daily) {
                  allowedFailures = failures;
                  freeDays = days;
                  partialGoalRequired = partialReq;
                  partialGoalTotal = partialTotal;
                  dailyGoal = daily;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.trim().isNotEmpty) {
                _addActivity(
                  name.trim(),
                  categoryId: selectedCategoryId,
                  tags: selectedTags,
                  recurrenceType: recurrenceType,
                  recurrenceInterval: recurrenceInterval,
                  recurrenceDays: recurrenceDays,
                  targetDays: targetDays,
                  allowedFailures: allowedFailures,
                  freeDays: freeDays,
                  partialGoalRequired: partialGoalRequired,
                  partialGoalTotal: partialGoalTotal,
                  dailyGoal: dailyGoal,
                  customIcon: customIcon,
                  customColor: customColor,
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    _showAnimatedDialog(
      AlertDialog(
        title: const Text('Elegir tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...AppThemeMode.values.map((mode) {
              return ListTile(
                leading: Icon(
                  AppThemes.getThemeIcon(mode),
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(AppThemes.getThemeName(mode)),
                onTap: () {
                  if (widget.onThemeChanged != null) {
                    widget.onThemeChanged!(mode);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  List<Activity> _getFilteredAndSortedActivities() {
    var filtered = _activities;

    // Excluir actividades archivadas
    filtered = filtered.where((a) => !a.isArchived).toList();

    // Aplicar filtro de recurrencia: mostrar solo actividades que deben completarse hoy
    filtered = filtered.where((a) => a.shouldCompleteToday()).toList();

    // Aplicar filtro de estado (activo/pausado)
    if (_filterMode == 'active') {
      filtered = filtered.where((a) => a.active).toList();
    } else if (_filterMode == 'paused') {
      filtered = filtered.where((a) => !a.active).toList();
    }

    // Aplicar filtro por categoría
    if (_selectedCategoryFilter != null) {
      filtered = filtered
          .where((a) => a.categoryId == _selectedCategoryFilter)
          .toList();
    }

    // Aplicar filtro por tag
    if (_selectedTagFilter != null) {
      filtered =
          filtered.where((a) => a.tags.contains(_selectedTagFilter)).toList();
    }

    // Aplicar ordenamiento
    if (_sortMode == 'streak') {
      filtered.sort((a, b) => b.streak.compareTo(a.streak));
    } else if (_sortMode == 'recent') {
      filtered.sort((a, b) {
        if (a.lastCompleted == null) return 1;
        if (b.lastCompleted == null) return -1;
        return b.lastCompleted!.compareTo(a.lastCompleted!);
      });
    } else {
      // Por defecto: nombre
      filtered
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filtrar actividades'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Todas'),
              value: 'all',
              groupValue: _filterMode,
              onChanged: (value) {
                setState(() => _filterMode = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Activas'),
              value: 'active',
              groupValue: _filterMode,
              onChanged: (value) {
                setState(() => _filterMode = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Pausadas'),
              value: 'paused',
              groupValue: _filterMode,
              onChanged: (value) {
                setState(() => _filterMode = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilterDialog() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filtrar por categoría'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CategorySelector(
                selectedCategoryId: _selectedCategoryFilter,
                onCategorySelected: (categoryId) {
                  setState(() {
                    _selectedCategoryFilter = categoryId;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
        actions: [
          if (_selectedCategoryFilter != null)
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategoryFilter = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Limpiar filtro'),
            ),
        ],
      ),
    );
  }

  void _showTagFilterDialog() async {
    final allTags = await _service.getAllTags();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Filtrar por tag'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Opción para limpiar filtro
              if (_selectedTagFilter != null)
                FilterChip(
                  label: const Text('Sin filtro'),
                  selected: false,
                  onSelected: (_) {
                    setState(() {
                      _selectedTagFilter = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              // Tags disponibles
              ...allTags.map((tag) => FilterChip(
                    label: Text(tag),
                    selected: _selectedTagFilter == tag,
                    onSelected: (_) {
                      setState(() {
                        _selectedTagFilter = tag;
                      });
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ordenar por'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Nombre'),
              value: 'name',
              groupValue: _sortMode,
              onChanged: (value) {
                setState(() => _sortMode = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Racha (mayor a menor)'),
              value: 'streak',
              groupValue: _sortMode,
              onChanged: (value) {
                setState(() => _sortMode = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Recientes'),
              value: 'recent',
              groupValue: _sortMode,
              onChanged: (value) {
                setState(() => _sortMode = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NotificationSettingsScreen(),
      ),
    );
  }

  // Muestra un diálogo para seleccionar un icono personalizado
  Future<String?> _showIconPickerDialog(
      BuildContext context, String? currentIcon) async {
    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar icono'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: ActivityIcons.iconsList.length,
            itemBuilder: (context, index) {
              final iconEntry = ActivityIcons.iconsList[index];
              final iconName = iconEntry.key;
              final iconData = iconEntry.value;
              final isSelected = currentIcon == iconName;

              return InkWell(
                onTap: () {
                  Navigator.pop(context, iconName);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.withOpacity(0.2) : null,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    iconData,
                    size: 32,
                    color: isSelected ? Colors.blue : Colors.grey.shade700,
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummary(List<Activity> activities) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final activeActivities = activities.where((a) => a.active).toList();
    final completedToday = activeActivities.where((a) {
      final lastCompleted = a.lastCompleted != null
          ? DateTime(a.lastCompleted!.year, a.lastCompleted!.month,
              a.lastCompleted!.day)
          : null;
      return lastCompleted == today;
    }).length;

    final pending = activeActivities.length - completedToday;
    final atRisk = activeActivities.where((a) {
      final lastCompleted = a.lastCompleted != null
          ? DateTime(a.lastCompleted!.year, a.lastCompleted!.month,
              a.lastCompleted!.day)
          : null;
      return lastCompleted != null &&
          lastCompleted != today &&
          today.difference(lastCompleted).inDays >= 1;
    }).length;

    final double progress =
        activeActivities.isEmpty ? 0 : completedToday / activeActivities.length;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Resumen de hoy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateTime.now().day.toString().padLeft(2, '0') +
                      '/' +
                      DateTime.now().month.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.check_circle,
                    label: 'Completadas',
                    value: completedToday.toString(),
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.pending_outlined,
                    label: 'Pendientes',
                    value: pending.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    icon: Icons.warning_amber,
                    label: 'En riesgo',
                    value: atRisk.toString(),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso del día',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 8,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredActivities = _getFilteredAndSortedActivities();

    // Indicadores de filtros/ordenamiento activos
    final filterActive = _filterMode != 'all';
    final sortActive = _sortMode != 'name';

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Streakify'),
                if (filterActive || sortActive)
                  Text(
                    '${filterActive ? "Filtrado" : ""}${filterActive && sortActive ? " • " : ""}${sortActive ? "Ordenado" : ""}',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                  ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(_isCompactView ? Icons.view_agenda : Icons.view_list),
                tooltip: _isCompactView ? 'Vista expandida' : 'Vista compacta',
                onPressed: _toggleViewMode,
              ),
            IconButton(
              icon: const Icon(Icons.people),
              tooltip: 'Comunidad',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SocialScreen()),
                );
              },
            ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'stats') {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            StatisticsScreen(activities: _activities),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else if (value == 'achievements') {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AchievementsScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else if (value == 'gallery') {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const AchievementGalleryScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, -1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else if (value == 'theme') {
                    _showThemeDialog();
                  } else if (value == 'filter') {
                    _showFilterDialog();
                  } else if (value == 'filter_category') {
                    _showCategoryFilterDialog();
                  } else if (value == 'filter_tag') {
                    _showTagFilterDialog();
                  } else if (value == 'sort') {
                    _showSortDialog();
                  } else if (value == 'notifications') {
                    _showNotificationSettings();
                  } else if (value == 'backup') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BackupScreen(),
                      ),
                    ).then((_) => _load());
                  } else if (value == 'calendar') {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const CalendarScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else if (value == 'timeline') {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TimelineScreen(activities: _activities),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(-1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else if (value == 'dashboard') {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const DashboardScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else if (value == 'gamification') {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const GamificationScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  } else if (value == 'accessibility') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AccessibilitySettingsScreen(),
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'stats',
                    child: Row(
                      children: [
                        Icon(Icons.bar_chart),
                        SizedBox(width: 8),
                        Text('Estadísticas'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'dashboard',
                    child: Row(
                      children: [
                        Icon(Icons.dashboard),
                        SizedBox(width: 8),
                        Text('Dashboard'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'gamification',
                    child: Row(
                      children: [
                        Icon(Icons.stars),
                        SizedBox(width: 8),
                        Text('Gamificación'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'achievements',
                    child: Row(
                      children: [
                        Icon(Icons.emoji_events),
                        SizedBox(width: 8),
                        Text('Logros'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'gallery',
                    child: Row(
                      children: [
                        Icon(Icons.collections),
                        SizedBox(width: 8),
                        Text('Galería'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'calendar',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month),
                        SizedBox(width: 8),
                        Text('Calendario'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'timeline',
                    child: Row(
                      children: [
                        Icon(Icons.timeline),
                        SizedBox(width: 8),
                        Text('Línea de tiempo'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(Icons.palette),
                        SizedBox(width: 8),
                        Text('Tema'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'accessibility',
                    child: Row(
                      children: [
                        Icon(Icons.accessibility_new),
                        SizedBox(width: 8),
                        Text('Accesibilidad'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'notifications',
                    child: Row(
                      children: [
                        Icon(Icons.notifications),
                        SizedBox(width: 8),
                        Text('Notificaciones'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'gallery',
                    child: Row(
                      children: [
                        Icon(Icons.photo_library),
                        SizedBox(width: 8),
                        Text('Galería de Logros'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'calendar',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month),
                        SizedBox(width: 8),
                        Text('Calendario'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'timeline',
                    child: Row(
                      children: [
                        Icon(Icons.timeline),
                        SizedBox(width: 8),
                        Text('Timeline del Día'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'filter',
                    child: Row(
                      children: [
                        Icon(Icons.filter_list),
                        SizedBox(width: 8),
                        Text('Filtrar estado'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'filter_category',
                    child: Row(
                      children: [
                        Icon(Icons.category),
                        SizedBox(width: 8),
                        Text('Filtrar por categoría'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'filter_tag',
                    child: Row(
                      children: [
                        Icon(Icons.label),
                        SizedBox(width: 8),
                        Text('Filtrar por tag'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'sort',
                    child: Row(
                      children: [
                        Icon(Icons.sort),
                        SizedBox(width: 8),
                        Text('Ordenar'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'theme',
                    child: Row(
                      children: [
                        Icon(Icons.palette),
                        SizedBox(width: 8),
                        Text('Cambiar tema'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'notifications',
                    child: Row(
                      children: [
                        Icon(Icons.notifications),
                        SizedBox(width: 8),
                        Text('Notificaciones'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'backup',
                    child: Row(
                      children: [
                        Icon(Icons.backup),
                        SizedBox(width: 8),
                        Text('Backup y Restauración'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Chips de filtros activos
              if (_selectedCategoryFilter != null || _selectedTagFilter != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_selectedCategoryFilter != null)
                        Chip(
                          avatar: const Icon(Icons.category, size: 18),
                          label: const Text('Categoría'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedCategoryFilter = null;
                            });
                          },
                        ),
                      if (_selectedTagFilter != null)
                        Chip(
                          avatar: const Icon(Icons.label, size: 18),
                          label: Text(_selectedTagFilter!),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _selectedTagFilter = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              // Lista de actividades
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: filteredActivities.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _activities.isEmpty
                                    ? Icons.inbox_outlined
                                    : Icons.filter_alt_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _activities.isEmpty
                                    ? 'No hay actividades'
                                    : 'No hay actividades con este filtro',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _activities.isEmpty
                                    ? 'Presiona el botón + para agregar tu primera actividad'
                                    : 'Intenta cambiar los filtros o agregar nuevas actividades',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              if (!_activities.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _filterMode = 'all';
                                        _sortMode = 'name';
                                      });
                                    },
                                    icon: const Icon(Icons.clear_all),
                                    label: const Text('Limpiar filtros'),
                                  ),
                                ),
                            ],
                          ),
                        )
                      : _isLoading
                          ? const Expanded(
                              child: ActivityListSkeleton(itemCount: 5),
                            )
                          : Column(
                              children: [
                                // Banner de resumen diario
                                _buildDailySummary(filteredActivities),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: StreakWidgetView(
                                    activities: filteredActivities,
                                    onComplete: _markCompleted,
                                    onUseProtector: _manualUseProtector,
                                    onDelete: _delete,
                                    onEdit: _editActivity,
                                    onToggleActive: _toggleActive,
                                    onConfigureNotifications:
                                        _showActivityNotificationDialog,
                                    isCompactView: _isCompactView,
                                    onReorder: _onReorder,
                                  ),
                                ),
                              ],
                            ),
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: _showAddDialog, child: const Icon(Icons.add)),
        ),
        // Widget de confetti
        CelebrationConfetti(
          controller: _confettiController,
          alignment: Alignment.topCenter,
        ),
      ],
    );
  }
}

class StreakWidgetView extends StatefulWidget {
  final List<Activity> activities;
  final Function(Activity) onComplete;
  final Function(Activity) onUseProtector;
  final Function(Activity) onDelete;
  final Function(Activity) onEdit;
  final Function(Activity) onToggleActive;
  final Function(Activity) onConfigureNotifications;
  final bool isCompactView;
  final Function(int, int) onReorder;

  const StreakWidgetView({
    super.key,
    required this.activities,
    required this.onComplete,
    required this.onUseProtector,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleActive,
    required this.onConfigureNotifications,
    this.isCompactView = false,
    required this.onReorder,
  });

  @override
  State<StreakWidgetView> createState() => _StreakWidgetViewState();
}

class _StreakWidgetViewState extends State<StreakWidgetView> {
  final Set<String> _expandedCards = {};

  void _toggleExpanded(String activityId) {
    setState(() {
      if (_expandedCards.contains(activityId)) {
        _expandedCards.remove(activityId);
      } else {
        _expandedCards.add(activityId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ordenar actividades por displayOrder si no hay otro ordenamiento activo
    // Nota: El ordenamiento se maneja en el padre, aquí solo mostramos la lista recibida
    final activities = widget.activities;

    if (ResponsiveHelper.isTablet(context) ||
        ResponsiveHelper.isDesktop(context)) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];
          return Hero(
            tag: 'activity_card_${activity.id}',
            child: ActivityCardTablet(
              activity: activity,
              onComplete: () => widget.onComplete(activity),
              onEdit: () => widget.onEdit(activity),
              onToggleActive: () => widget.onToggleActive(activity),
              onUseProtector: () => widget.onUseProtector(activity),
            ),
          );
        },
      );
    }

    return ReorderableListView.builder(
      itemCount: activities.length,
      onReorder: widget.onReorder,
      padding: const EdgeInsets.only(bottom: 80),
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            final double animValue = Curves.easeInOut.transform(animation.value);
            final double elevation = lerpDouble(0, 6, animValue)!;
            return Material(
              elevation: elevation,
              color: Colors.transparent,
              shadowColor: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final activity = activities[index];
        return TweenAnimationBuilder<double>(
          key: ValueKey(activity.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Hero(
            tag: 'activity_card_${activity.id}',
            child: _buildActivityCard(context, activity),
          ),
        );
      },
    );
  }

  // Calcula los últimos 7 días de completado para una actividad
  Future<List<bool>> _calculateLast7Days(Activity activity) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<bool> last7Days = [];

    // Si no tiene lastCompleted, todos son false
    if (activity.lastCompleted == null) {
      return List.filled(7, false);
    }

    final lastCompletedDate = DateTime(
      activity.lastCompleted!.year,
      activity.lastCompleted!.month,
      activity.lastCompleted!.day,
    );

    // Calcular los últimos 7 días basado en la racha
    for (int i = 6; i >= 0; i--) {
      final checkDate = today.subtract(Duration(days: i));

      // Si es hoy y fue completado hoy
      if (i == 0) {
        last7Days.add(checkDate == lastCompletedDate);
      } else {
        // Para días anteriores, marcamos como completado si está dentro de la racha
        final daysDiff = today.difference(checkDate).inDays;
        final wasCompleted =
            daysDiff <= activity.streak && lastCompletedDate == today;
        last7Days.add(wasCompleted);
      }
    }

    return last7Days;
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = activity.lastCompleted != null
        ? DateTime(activity.lastCompleted!.year, activity.lastCompleted!.month,
            activity.lastCompleted!.day)
        : null;

    // Determinar estado de la actividad
    bool isCompletedToday = false;
    if (lastCompleted != null) {
      isCompletedToday =
          today.year == lastCompleted.year &&
          today.month == lastCompleted.month &&
          today.day == lastCompleted.day;
      
      // Check for multiple completions
      if (isCompletedToday && activity.allowsMultipleCompletions() && !activity.hasCompletedDailyGoal()) {
        isCompletedToday = false; // Still needs more completions
      }
    }

    if (widget.isCompactView) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ActivityColors.getColor(activity.customColor).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              ActivityIcons.getIcon(activity.customIcon),
              color: ActivityColors.getColor(activity.customColor),
              size: 20,
            ),
          ),
          title: Text(
            activity.name,
            style: TextStyle(
              decoration: isCompletedToday ? TextDecoration.lineThrough : null,
              color: isCompletedToday ? Colors.grey : null,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text('Racha: ${activity.streak} días'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (activity.allowsMultipleCompletions())
                Padding(
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
              IconButton(
                icon: Icon(
                  isCompletedToday ? Icons.check_circle : Icons.circle_outlined,
                  color: isCompletedToday ? Colors.green : Colors.grey,
                ),
                onPressed: () => widget.onComplete(activity),
              ),
            ],
          ),
          onTap: () => _toggleExpanded(activity.id),
        ),
      );
    }
    final bool completedToday = lastCompleted == today;
    final bool isAtRisk = lastCompleted != null &&
        !completedToday &&
        today.difference(lastCompleted).inDays >= 1;
    final bool hasProtectorAvailable = !activity.protectorUsed ||
        (activity.nextProtectorAvailable != null &&
            now.isAfter(activity.nextProtectorAvailable!));

    // Textos informativos
    final protectorText = activity.protectorUsed
        ? 'Protector se renueva el ${activity.nextProtectorAvailable != null ? activity.nextProtectorAvailable!.toLocal().toString().split(' ').first : ''}'
        : 'Protector disponible';

    final lastCompletedText = lastCompleted != null
        ? 'Última vez: ${lastCompleted.day}/${lastCompleted.month}/${lastCompleted.year}'
        : 'Nunca completada';

    // Color del borde según estado
    Color? borderColor;
    if (!activity.active) {
      borderColor = Colors.grey;
    } else if (completedToday) {
      borderColor = Colors.green;
    } else if (isAtRisk) {
      borderColor = Colors.orange;
    }

    return Dismissible(
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
            context: context,
            title: 'Eliminar actividad',
            content: '¿Estás seguro de eliminar "${activity.name}"?',
            confirmText: 'Eliminar',
            confirmColor: Colors.red,
            onConfirm: () => widget.onDelete(activity),
          );
        } else if (direction == DismissDirection.startToEnd) {
          // Deslizar hacia la derecha - Editar
          await _showConfirmDialog(
            context: context,
            title: 'Editar actividad',
            content: '¿Deseas editar "${activity.name}"?',
            confirmText: 'Editar',
            confirmColor: Colors.blue,
            onConfirm: () => widget.onEdit(activity),
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
                  onComplete: () => widget.onComplete(activity),
                  onEdit: () => widget.onEdit(activity),
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
                    Container(
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nombre de la actividad
                          Text(
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
                          const SizedBox(height: 6),
                          // Racha actual
                          Row(
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
                          const SizedBox(height: 4),
                          // Indicador de múltiples completaciones diarias
                          if (activity.allowsMultipleCompletions() &&
                              completedToday)
                            Row(
                              children: [
                                Icon(
                                  activity.hasCompletedDailyGoal()
                                      ? Icons.check_circle
                                      : Icons.repeat,
                                  size: 14,
                                  color: activity.hasCompletedDailyGoal()
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${activity.dailyCompletionCount}/${activity.dailyGoal} hoy',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: activity.hasCompletedDailyGoal()
                                        ? Colors.green
                                        : Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!activity.hasCompletedDailyGoal()) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Faltan ${activity.remainingDailyCompletions()}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          if (activity.allowsMultipleCompletions() &&
                              completedToday)
                            const SizedBox(height: 4),
                          // Indicador de rachas parciales
                          if (activity.hasPartialGoal())
                            Row(
                              children: [
                                Icon(
                                  activity.hasMetPartialGoal()
                                      ? Icons.stars
                                      : Icons.calendar_today,
                                  size: 14,
                                  color: activity.hasMetPartialGoal()
                                      ? Colors.amber
                                      : Colors.purple,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Esta semana: ${activity.weeklyCompletionCount}/${activity.partialGoalRequired} días',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: activity.hasMetPartialGoal()
                                        ? Colors.amber
                                        : Colors.purple,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (!activity.hasMetPartialGoal()) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'Faltan ${activity.daysRemainingForPartialGoal()}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          if (activity.hasPartialGoal())
                            const SizedBox(height: 4),
                          // Última vez completada
                          Text(
                            lastCompletedText,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          // Estado del protector
                          Row(
                            children: [
                              Icon(
                                hasProtectorAvailable
                                    ? Icons.shield
                                    : Icons.shield_outlined,
                                size: 14,
                                color: hasProtectorAvailable
                                    ? Colors.blue
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  protectorText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: hasProtectorAvailable
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Badge de estado
                          if (completedToday)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check,
                                      color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('Completado hoy',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                ],
                              ),
                            )
                          else if (!activity.active)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Pausada',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 10)),
                            )
                          else if (activity.isCurrentlyFrozen())
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.ac_unit,
                                      color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Congelada (${activity.daysRemainingFrozen()} ${activity.daysRemainingFrozen() == 1 ? "día" : "días"})',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 10),
                                  ),
                                ],
                              ),
                            )
                          else if (isAtRisk)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.warning_amber,
                                      color: Colors.white, size: 12),
                                  SizedBox(width: 4),
                                  Text('En riesgo',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 10)),
                                ],
                              ),
                            ),
                          // Indicador de progreso hacia la meta
                          if (activity.targetDays != null) ...[
                            const SizedBox(height: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.flag,
                                        size: 12, color: Colors.purple),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Meta: ${activity.targetDays} días',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      activity.hasReachedGoal()
                                          ? '¡Completado! 🎉'
                                          : '${activity.daysRemainingToGoal()} días restantes',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: activity.hasReachedGoal()
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: activity.getGoalProgress(),
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      activity.hasReachedGoal()
                                          ? Colors.green
                                          : Colors.purple,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    // Botón de completar
                    if (!completedToday && activity.active)
                      _PulsingButton(
                        onPressed: () => widget.onComplete(activity),
                      )
                    else if (completedToday)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                    // Menú de opciones (3 puntos)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      tooltip: 'Opciones',
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            widget.onEdit(activity);
                            break;
                          case 'toggle':
                            widget.onToggleActive(activity);
                            break;
                          case 'protector':
                            widget.onUseProtector(activity);
                            break;
                          case 'notifications':
                            widget.onConfigureNotifications(activity);
                            break;
                          case 'archive':
                            // Toggle archive and trigger save through edit callback
                            activity.isArchived = !activity.isArchived;
                            widget.onEdit(activity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(activity.isArchived
                                    ? '${activity.name} archivada'
                                    : '${activity.name} restaurada'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            break;
                          case 'freeze':
                            if (activity.isCurrentlyFrozen()) {
                              // Unfreeze
                              activity.isFrozen = false;
                              activity.frozenUntil = null;
                              activity.freezeReason = null;
                              widget.onEdit(activity);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('${activity.name} descongelada'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            } else {
                              // Show freeze dialog
                              _showFreezeDialog(activity);
                            }
                            break;
                          case 'delete':
                            _confirmDelete(context, activity);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggle',
                          child: Row(
                            children: [
                              Icon(
                                  activity.active
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 20),
                              const SizedBox(width: 8),
                              Text(activity.active ? 'Pausar' : 'Activar'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'notifications',
                          child: Row(
                            children: [
                              Icon(
                                activity.notificationsEnabled
                                    ? Icons.notifications_active
                                    : Icons.notifications_off,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text('Notificaciones'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'protector',
                          enabled: hasProtectorAvailable,
                          child: Row(
                            children: [
                              Icon(
                                hasProtectorAvailable
                                    ? Icons.shield
                                    : Icons.shield_outlined,
                                size: 20,
                                color:
                                    hasProtectorAvailable ? null : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Usar Protector',
                                style: TextStyle(
                                  color: hasProtectorAvailable
                                      ? null
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'archive',
                          child: Row(
                            children: [
                              Icon(
                                activity.isArchived
                                    ? Icons.unarchive
                                    : Icons.archive,
                                size: 20,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                activity.isArchived
                                    ? 'Desarchivar'
                                    : 'Archivar',
                                style: const TextStyle(color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'freeze',
                          child: Row(
                            children: [
                              Icon(
                                activity.isCurrentlyFrozen()
                                    ? Icons.ac_unit
                                    : Icons.ac_unit_outlined,
                                size: 20,
                                color: Colors.cyan,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                activity.isCurrentlyFrozen()
                                    ? 'Descongelar'
                                    : 'Congelar racha',
                                style: const TextStyle(color: Colors.cyan),
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ), // Fin del Row principal

                // Contenido expandible
                if (_expandedCards.contains(activity.id)) ...[
                  const Divider(height: 24, thickness: 1),

                  // Tags
                  if (activity.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: activity.tags
                            .map((tag) => Chip(
                                  label: Text('#$tag'),
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ),

                  // Tiempo hasta medianoche
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: TimeUntilMidnightIndicator(),
                  ),

                  // Progreso semanal
                  FutureBuilder<List<bool>>(
                    future: _calculateLast7Days(activity),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return WeeklyProgressBar(
                          last7Days: snapshot.data!,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],

                // Botón expandir/colapsar
                InkWell(
                  onTap: () => _toggleExpanded(activity.id),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _expandedCards.contains(activity.id)
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _expandedCards.contains(activity.id)
                              ? 'Ver menos'
                              : 'Ver más',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ], // Fin children del Column
            ), // Fin del Column
          ), // Fin del Container
        ), // Fin del GestureDetector
      ), // Fin del Opacity
    ); // Fin del Dismissible
  }

  Widget _buildSwipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
    required VoidCallback onConfirm,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showFreezeDialog(Activity activity) {
    int selectedDays = 7;
    String reason = '';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.ac_unit, color: Colors.cyan),
              SizedBox(width: 8),
              Text('Congelar racha'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'La racha se congelará y no perderás progreso durante este período.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              const Text(
                'Duración:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [1, 3, 7, 14, 30].map((days) {
                  return ChoiceChip(
                    label: Text('$days ${days == 1 ? "día" : "días"}'),
                    selected: selectedDays == days,
                    onSelected: (selected) {
                      setState(() {
                        selectedDays = days;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Razón (opcional)',
                  hintText: 'Vacaciones, enfermedad, etc.',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                onChanged: (value) => reason = value,
              ),
            ],
          ),
          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                activity.isFrozen = true;
                activity.frozenUntil =
                    DateTime.now().add(Duration(days: selectedDays));
                activity.freezeReason =
                    reason.trim().isEmpty ? null : reason.trim();
                widget.onEdit(activity);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        '❄️ ${activity.name} congelada por $selectedDays ${selectedDays == 1 ? "día" : "días"}'),
                    duration: const Duration(seconds: 3),
                    backgroundColor: Colors.cyan,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
              child: const Text('Congelar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar actividad'),
        content: Text('¿Estás seguro de eliminar "${activity.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDelete(activity);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// Widget de botón pulsante animado
class _PulsingButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _PulsingButton({required this.onPressed});

  @override
  State<_PulsingButton> createState() => _PulsingButtonState();
}

class _PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: BounceButton(
        onPressed: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.all(4),
          child: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 32,
          ),
        ),
      ),
    );
  }
}
