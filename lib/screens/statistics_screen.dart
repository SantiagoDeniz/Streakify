import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../services/category_service.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Activity> activities;

  const StatisticsScreen({super.key, required this.activities});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final CategoryService _categoryService = CategoryService();
  Map<String, Category> _categoriesMap = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getAllCategories();
    setState(() {
      _categoriesMap = {for (var cat in categories) cat.id: cat};
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeActivities = widget.activities.where((a) => a.active).toList();
    final totalActivities = widget.activities.length;
    final activeCount = activeActivities.length;

    // Calcular estadísticas
    int maxStreak = 0;
    int totalDays = 0;
    Activity? bestActivity;

    for (var activity in widget.activities) {
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
        title: Hero(
          tag: 'statistics_title',
          child: Material(
            color: Colors.transparent,
            child: Text(
              'Estadísticas',
              style: Theme.of(context).appBarTheme.titleTextStyle,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarjetas de resumen
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

          // Gráfico de barras - Top 10 rachas
          const SizedBox(height: 24),
          const Text(
            'Top 10 Rachas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStreakBarChart(context),

          // Gráfico de pastel - Actividades por categoría
          if (_categoriesMap.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text(
              'Actividades por Categoría',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildCategoryPieChart(context),
          ],

          // Gráfico de estado
          const SizedBox(height: 32),
          const Text(
            'Estado de Actividades',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatusPieChart(context),

          // Ranking de actividades
          const SizedBox(height: 32),
          const Text(
            'Ranking de actividades',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...(widget.activities.where((a) => a.streak > 0).toList()
                ..sort((a, b) => b.streak.compareTo(a.streak)))
              .take(10)
              .map((activity) => _buildRankingItem(context, activity)),
          if (widget.activities.where((a) => a.streak > 0).isEmpty)
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

  Widget _buildStreakBarChart(BuildContext context) {
    final topActivities = (widget.activities.where((a) => a.streak > 0).toList()
          ..sort((a, b) => b.streak.compareTo(a.streak)))
        .take(10)
        .toList();

    if (topActivities.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No hay rachas para mostrar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final maxStreak =
        topActivities.isEmpty ? 1 : topActivities.first.streak.toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 300,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxStreak * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${topActivities[groupIndex].name}\n${rod.toY.toInt()} días',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= topActivities.length) {
                        return const Text('');
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          topActivities[value.toInt()].name.substring(
                              0,
                              topActivities[value.toInt()].name.length > 8
                                  ? 8
                                  : topActivities[value.toInt()].name.length),
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(
                topActivities.length,
                (index) => BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: topActivities[index].streak.toDouble(),
                      color: _getColorForIndex(index),
                      width: 20,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(BuildContext context) {
    final categoryCounts = <String, int>{};

    for (var activity in widget.activities) {
      if (activity.categoryId != null) {
        categoryCounts[activity.categoryId!] =
            (categoryCounts[activity.categoryId!] ?? 0) + 1;
      } else {
        categoryCounts['uncategorized'] =
            (categoryCounts['uncategorized'] ?? 0) + 1;
      }
    }

    if (categoryCounts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No hay actividades para mostrar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final sortedEntries = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = sortedEntries.map((entry) {
      final category = _categoriesMap[entry.key];
      final percentage =
          (entry.value / widget.activities.length * 100).toStringAsFixed(1);
      final color = category?.color ?? Colors.grey;

      return PieChartSectionData(
        color: color,
        value: entry.value.toDouble(),
        title: '$percentage%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {},
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: sortedEntries.map((entry) {
                final category = _categoriesMap[entry.key];
                final color = category?.color ?? Colors.grey;
                final name = category?.name ?? 'Sin categoría';
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$name (${entry.value})',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPieChart(BuildContext context) {
    final activeCount = widget.activities.where((a) => a.active).length;
    final pausedCount = widget.activities.length - activeCount;

    if (widget.activities.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No hay actividades para mostrar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: activeCount.toDouble(),
                      title:
                          '${(activeCount / widget.activities.length * 100).toStringAsFixed(1)}%',
                      radius: 100,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (pausedCount > 0)
                      PieChartSectionData(
                        color: Colors.orange,
                        value: pausedCount.toDouble(),
                        title:
                            '${(pausedCount / widget.activities.length * 100).toStringAsFixed(1)}%',
                        radius: 100,
                        titleStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Activas', Colors.green, activeCount),
                const SizedBox(width: 16),
                _buildLegendItem('Pausadas', Colors.orange, pausedCount),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label ($count)',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
    ];
    return colors[index % colors.length];
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
