import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../services/notification_service.dart';
import '../widgets/home_widget_service.dart';
import 'statistics_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode)? onThemeChanged;

  const HomeScreen({super.key, this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActivityService _service = ActivityService();
  List<Activity> _activities = [];
  String _filterMode = 'all'; // 'all', 'active', 'paused'
  String _sortMode = 'name'; // 'name', 'streak', 'recent'

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.loadActivities();
    setState(() => _activities = list);
    HomeWidgetService.updateWidget(_activities);
  }

  Future<void> _save() async => _service.saveActivities(_activities);

  void _addActivity(String name) {
    final newAct = Activity(id: const Uuid().v4(), name: name);
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
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar actividad'),
        content: TextField(
          controller: TextEditingController(text: act.name),
          decoration: const InputDecoration(hintText: 'Nombre'),
          onChanged: (val) => newName = val,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newName.trim().isNotEmpty && newName.trim() != act.name) {
                setState(() => act.name = newName.trim());
                _save();
                HomeWidgetService.updateWidget(_activities);
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
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

  void _markCompleted(Activity act) {
    if (!act.active) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Esta actividad está pausada. Actívala primero.'),
          duration: Duration(seconds: 2),
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

    if (last == nowDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya completaste esta actividad hoy!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

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

    _save();
    HomeWidgetService.updateWidget(_activities);
    setState(() {});

    // Mostrar celebración si alcanza hito
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
          content: Text('✓ Completado! Racha: ${act.streak} días'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
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
            onPressed: () {
              // Usar protector - mantener racha pero NO completar hoy automáticamente
              setState(() {
                act.protectorUsed = true;
                act.nextProtectorAvailable =
                    DateTime.now().add(const Duration(days: 5));
                // Actualizar lastCompleted al día anterior para que pueda completar hoy
                act.lastCompleted = nowDay.subtract(const Duration(days: 1));
                // La racha se mantiene sin cambios
              });
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

  void _showAddDialog() {
    String name = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva actividad'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Nombre'),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
              onPressed: () {
                if (name.trim().isNotEmpty) _addActivity(name.trim());
                Navigator.pop(context);
              },
              child: const Text('Guardar')),
        ],
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Elegir tema'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Claro'),
              value: ThemeMode.light,
              groupValue: Theme.of(context).brightness == Brightness.light
                  ? ThemeMode.light
                  : ThemeMode.dark,
              onChanged: (value) {
                if (value != null && widget.onThemeChanged != null) {
                  widget.onThemeChanged!(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Oscuro'),
              value: ThemeMode.dark,
              groupValue: Theme.of(context).brightness == Brightness.dark
                  ? ThemeMode.dark
                  : ThemeMode.light,
              onChanged: (value) {
                if (value != null && widget.onThemeChanged != null) {
                  widget.onThemeChanged!(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Automático (sistema)'),
              value: ThemeMode.system,
              groupValue: ThemeMode.system,
              onChanged: (value) {
                if (value != null && widget.onThemeChanged != null) {
                  widget.onThemeChanged!(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  List<Activity> _getFilteredAndSortedActivities() {
    var filtered = _activities;

    // Aplicar filtro
    if (_filterMode == 'active') {
      filtered = filtered.where((a) => a.active).toList();
    } else if (_filterMode == 'paused') {
      filtered = filtered.where((a) => !a.active).toList();
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

  void _showNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    bool notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    int notificationHour = prefs.getInt('notification_hour') ?? 20;

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications),
              SizedBox(width: 8),
              Text('Notificaciones'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                title: const Text('Activar recordatorios'),
                subtitle: const Text('Recibe un recordatorio diario'),
                value: notificationsEnabled,
                onChanged: (value) async {
                  setDialogState(() => notificationsEnabled = value);
                  await prefs.setBool('notifications_enabled', value);

                  if (value) {
                    await NotificationService().scheduleDailyReminder(
                      hour: notificationHour,
                      minute: 0,
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Notificaciones activadas'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    await NotificationService().cancelAllNotifications();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notificaciones desactivadas'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              if (notificationsEnabled) ...[
                const Divider(),
                const Text('Hora del recordatorio:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: notificationHour,
                      items: List.generate(24, (index) => index)
                          .map((hour) => DropdownMenuItem(
                                value: hour,
                                child: Text(
                                    '${hour.toString().padLeft(2, '0')}:00'),
                              ))
                          .toList(),
                      onChanged: (value) async {
                        if (value != null) {
                          setDialogState(() => notificationHour = value);
                          await prefs.setInt('notification_hour', value);
                          await NotificationService().scheduleDailyReminder(
                            hour: value,
                            minute: 0,
                          );
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Recordatorio programado para las ${value.toString().padLeft(2, '0')}:00',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            if (notificationsEnabled)
              TextButton.icon(
                onPressed: () async {
                  await NotificationService().showInstantNotification(
                    title: '🔥 Streakify',
                    body: '¡Esta es una notificación de prueba!',
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificación de prueba enviada'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Probar'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
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

    return Container(
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
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
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

    return Scaffold(
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'stats') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StatisticsScreen(activities: _activities),
                  ),
                );
              } else if (value == 'theme') {
                _showThemeDialog();
              } else if (value == 'filter') {
                _showFilterDialog();
              } else if (value == 'sort') {
                _showSortDialog();
              } else if (value == 'notifications') {
                _showNotificationSettings();
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
                value: 'filter',
                child: Row(
                  children: [
                    Icon(Icons.filter_list),
                    SizedBox(width: 8),
                    Text('Filtrar'),
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
            ],
          ),
        ],
      ),
      body: Padding(
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
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _showAddDialog, child: const Icon(Icons.add)),
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

  const StreakWidgetView({
    super.key,
    required this.activities,
    required this.onComplete,
    required this.onUseProtector,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleActive,
  });

  @override
  State<StreakWidgetView> createState() => _StreakWidgetViewState();
}

class _StreakWidgetViewState extends State<StreakWidgetView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: widget.activities
          .map((activity) => _buildActivityCard(context, activity))
          .toList(),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = activity.lastCompleted != null
        ? DateTime(activity.lastCompleted!.year, activity.lastCompleted!.month,
            activity.lastCompleted!.day)
        : null;

    // Determinar estado de la actividad
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

    return Opacity(
      opacity: activity.active ? 1.0 : 0.5,
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
          children: [
            Row(
              children: [
                // Icono de estado
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: completedToday
                        ? Colors.green.withOpacity(0.2)
                        : (isAtRisk
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.blue.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    completedToday
                        ? Icons.check_circle
                        : (isAtRisk
                            ? Icons.warning_amber
                            : Icons.local_fire_department),
                    color: completedToday
                        ? Colors.green
                        : (isAtRisk ? Colors.orange : Colors.blue),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
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
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Racha actual
                      Row(
                        children: [
                          const Icon(Icons.local_fire_department,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${activity.streak} ${activity.streak == 1 ? "día" : "días"} de racha',
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
                      const SizedBox(height: 2),
                      // Última vez completada
                      Text(
                        lastCompletedText,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
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
                    ],
                  ),
                ),
                // Botón principal (completar o info)
                Column(
                  children: [
                    if (!completedToday)
                      IconButton(
                        onPressed: activity.active
                            ? () => widget.onComplete(activity)
                            : null,
                        icon: const Icon(Icons.check_circle_outline),
                        tooltip: 'Marcar completado',
                        color: activity.active ? Colors.green : Colors.grey,
                        iconSize: 32,
                      )
                    else
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
                  ],
                ),
              ],
            ),
            const Divider(height: 16, thickness: 1),
            Wrap(
              alignment: WrapAlignment.spaceEvenly,
              spacing: 4,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () => widget.onEdit(activity),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Editar', style: TextStyle(fontSize: 11)),
                ),
                TextButton.icon(
                  onPressed: () => widget.onToggleActive(activity),
                  icon: Icon(activity.active ? Icons.pause : Icons.play_arrow,
                      size: 16),
                  label: Text(
                    activity.active ? 'Pausar' : 'Activar',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => widget.onUseProtector(activity),
                  icon: Icon(
                    hasProtectorAvailable
                        ? Icons.shield
                        : Icons.shield_outlined,
                    size: 16,
                  ),
                  label:
                      const Text('Protector', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(
                    foregroundColor:
                        hasProtectorAvailable ? Colors.blue : Colors.grey,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _confirmDelete(context, activity),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Eliminar', style: TextStyle(fontSize: 11)),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
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
