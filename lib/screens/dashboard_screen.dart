import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/activity.dart';
import '../models/achievement.dart';
import '../models/dashboard_widget.dart';
import '../services/activity_service.dart';
import '../services/achievement_service.dart';
import '../widgets/activity_visualizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<DashboardWidget> _widgets = [];
  List<Activity> _activities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Cargar widgets guardados o usar predeterminados
    final prefs = await SharedPreferences.getInstance();
    final widgetsJson = prefs.getString('dashboard_widgets');

    if (widgetsJson != null) {
      final List<dynamic> decoded = json.decode(widgetsJson);
      _widgets = decoded.map((w) => DashboardWidget.fromJson(w)).toList();
    } else {
      _widgets = PredefinedDashboardWidgets.all;
    }

    // Ordenar por order
    _widgets.sort((a, b) => a.order.compareTo(b.order));

    // Cargar actividades
    _activities = await ActivityService().loadActivities();

    setState(() => _isLoading = false);
  }

  Future<void> _saveWidgets() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_widgets.map((w) => w.toJson()).toList());
    await prefs.setString('dashboard_widgets', encoded);
  }

  void _showCustomizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personalizar Dashboard'),
        content: SizedBox(
          width: double.maxFinite,
          child: ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: _widgets.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final widget = _widgets.removeAt(oldIndex);
                _widgets.insert(newIndex, widget);

                // Actualizar orden
                for (int i = 0; i < _widgets.length; i++) {
                  _widgets[i].order = i;
                }
              });
            },
            itemBuilder: (context, index) {
              final widget = _widgets[index];
              return ListTile(
                key: ValueKey(widget.id),
                leading: Icon(widget.icon),
                title: Text(widget.title),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: widget.isVisible,
                      onChanged: (value) {
                        setState(() {
                          _widgets[index] = widget.copyWith(isVisible: value);
                        });
                      },
                    ),
                    const Icon(Icons.drag_handle),
                  ],
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
          ElevatedButton(
            onPressed: () {
              _saveWidgets();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Dashboard personalizado')),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showCustomizeDialog,
            tooltip: 'Personalizar',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _widgets.where((w) => w.isVisible).length,
                itemBuilder: (context, index) {
                  final widget =
                      _widgets.where((w) => w.isVisible).toList()[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildWidget(widget),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildWidget(DashboardWidget widget) {
    switch (widget.type) {
      case DashboardWidgetType.totalActivities:
        return _buildTotalActivitiesWidget();
      case DashboardWidgetType.activeStreak:
        return _buildActiveStreakWidget();
      case DashboardWidgetType.todayProgress:
        return _buildTodayProgressWidget();
      case DashboardWidgetType.weekProgress:
        return _buildWeekProgressWidget();
      case DashboardWidgetType.bestStreak:
        return _buildBestStreakWidget();
      case DashboardWidgetType.totalDays:
        return _buildTotalDaysWidget();
      case DashboardWidgetType.perfectDays:
        return _buildPerfectDaysWidget();
      case DashboardWidgetType.recentAchievements:
        return _buildRecentAchievementsWidget();
      case DashboardWidgetType.upcomingTasks:
        return _buildUpcomingTasksWidget();
      case DashboardWidgetType.timeRemaining:
        return _buildTimeRemainingWidget();
    }
  }

  Widget _buildTotalActivitiesWidget() {
    final total = _activities.length;
    final active = _activities.where((a) => a.active).length;
    final inactive = total - active;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Total de Actividades',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total', total.toString(), Colors.blue),
                _buildStatColumn('Activas', active.toString(), Colors.green),
                _buildStatColumn('Inactivas', inactive.toString(), Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveStreakWidget() {
    final activeActivities =
        _activities.where((a) => a.active && a.streak > 0).toList();
    final totalStreak =
        activeActivities.fold<int>(0, (sum, a) => sum + a.streak);
    final avgStreak = activeActivities.isNotEmpty
        ? (totalStreak / activeActivities.length).round()
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Rachas Activas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                    'Total', totalStreak.toString(), Colors.orange),
                _buildStatColumn(
                    'Promedio', avgStreak.toString(), Colors.amber),
                _buildStatColumn('Activas', activeActivities.length.toString(),
                    Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayProgressWidget() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final activeActivities = _activities.where((a) => a.active).toList();
    final completedToday = activeActivities.where((a) {
      if (a.lastCompleted == null) return false;
      final lastCompleted = DateTime(
        a.lastCompleted!.year,
        a.lastCompleted!.month,
        a.lastCompleted!.day,
      );
      return lastCompleted == today;
    }).length;

    final percentage = activeActivities.isNotEmpty
        ? (completedToday / activeActivities.length * 100).round()
        : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.today, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'Progreso de Hoy',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedToday de ${activeActivities.length}',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 32,
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
                value: activeActivities.isNotEmpty
                    ? completedToday / activeActivities.length
                    : 0,
                minHeight: 12,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage == 100 ? Colors.green : Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekProgressWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_view_week, color: Colors.purple[700]),
                const SizedBox(width: 8),
                const Text(
                  'Progreso Semanal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_activities.isNotEmpty)
              FutureBuilder<List<bool>>(
                future: _calculateWeekProgress(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return WeeklyProgressBar(last7Days: snapshot.data!);
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              )
            else
              const Center(child: Text('No hay actividades')),
          ],
        ),
      ),
    );
  }

  Widget _buildBestStreakWidget() {
    final bestStreak =
        _activities.fold<int>(0, (max, a) => a.streak > max ? a.streak : max);
    final activitiesWithBestStreak =
        _activities.where((a) => a.streak == bestStreak).toList();
    final bestActivity = activitiesWithBestStreak.isNotEmpty
        ? activitiesWithBestStreak.first
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text(
                  'Mejor Racha',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    bestStreak.toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber[700],
                    ),
                  ),
                  const Text(
                    'días',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  if (bestActivity != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      bestActivity.name,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalDaysWidget() {
    final totalDays = _activities.fold<int>(0, (sum, a) => sum + a.streak);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.indigo[700]),
                const SizedBox(width: 8),
                const Text(
                  'Días Totales',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    totalDays.toString(),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[700],
                    ),
                  ),
                  const Text(
                    'días acumulados',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerfectDaysWidget() {
    // Simplificado: días donde todas las actividades activas están completadas
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.yellow[700]),
                const SizedBox(width: 8),
                const Text(
                  'Días Perfectos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Text(
                    '0',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[700],
                    ),
                  ),
                  const Text(
                    'días perfectos',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Próximamente',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAchievementsWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium, color: Colors.pink[700]),
                const SizedBox(width: 8),
                const Text(
                  'Logros Recientes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Achievement>>(
              future: Future.value(AchievementService().getAllAchievements()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final achievements = snapshot.data as List<Achievement>;
                final unlockedAchievements = achievements
                    .where((a) => a.isUnlocked)
                    .toList()
                  ..sort((a, b) => (b.unlockedAt ?? DateTime(2000))
                      .compareTo(a.unlockedAt ?? DateTime(2000)));

                if (unlockedAchievements.isEmpty) {
                  return const Center(
                    child: Text('No hay logros desbloqueados aún'),
                  );
                }

                return Column(
                  children: unlockedAchievements.take(3).map((achievement) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(achievement.icon, color: achievement.color),
                      title: Text(achievement.title),
                      subtitle: Text(achievement.description),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingTasksWidget() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final pending = _activities.where((a) {
      if (!a.active) return false;
      if (a.lastCompleted == null) return true;
      final lastCompleted = DateTime(
        a.lastCompleted!.year,
        a.lastCompleted!.month,
        a.lastCompleted!.day,
      );
      return lastCompleted != today;
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pending_actions, color: Colors.teal[700]),
                const SizedBox(width: 8),
                const Text(
                  'Próximas Tareas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pending.isEmpty)
              const Center(child: Text('¡Todo completado por hoy!'))
            else
              Column(
                children: pending.take(5).map((activity) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.circle_outlined),
                    title: Text(activity.name),
                    subtitle: Text('Racha: ${activity.streak} días'),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRemainingWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.timer, color: Colors.red[700]),
                const SizedBox(width: 8),
                const Text(
                  'Tiempo Restante',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const TimeUntilMidnightIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Future<List<bool>> _calculateWeekProgress() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<bool> last7Days = [];

    for (int i = 6; i >= 0; i--) {
      final checkDate = today.subtract(Duration(days: i));

      // Contar actividades completadas ese día
      final completedCount = _activities.where((activity) {
        if (activity.lastCompleted == null) return false;
        final lastCompleted = DateTime(
          activity.lastCompleted!.year,
          activity.lastCompleted!.month,
          activity.lastCompleted!.day,
        );
        return lastCompleted == checkDate;
      }).length;

      last7Days.add(completedCount > 0);
    }

    return last7Days;
  }
}
