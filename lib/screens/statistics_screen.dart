import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/advanced_statistics_service.dart';
import '../services/statistics_export_service.dart';
import '../widgets/activity_heatmap.dart';
import '../widgets/advanced_charts.dart';

class StatisticsScreen extends StatefulWidget {
  final List<Activity> activities;

  const StatisticsScreen({super.key, required this.activities});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final CategoryService _categoryService = CategoryService();
  final AdvancedStatisticsService _advancedStats = AdvancedStatisticsService();
  Map<String, Category> _categoriesMap = {};

  // Métricas avanzadas
  Map<String, double> _successRates = {};
  Map<String, int> _bestStreaks = {};
  Map<String, double> _averageStreaks = {};
  int _totalConsecutiveDays = 0;
  List<DateTime> _perfectDays = [];
  List<WeeklyTrend> _weeklyTrends = [];
  bool _loadingAdvancedStats = true;

  // Estado de interacción con gráficos
  int _touchedCategoryIndex = -1;
  int _touchedStatusIndex = -1;
  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadAdvancedStatistics();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getAllCategories();
    setState(() {
      _categoriesMap = {for (var cat in categories) cat.id: cat};
    });
  }

  Future<void> _loadAdvancedStatistics() async {
    try {
      final successRates = await _advancedStats.getSuccessRate();
      final bestStreaks = await _advancedStats.getBestStreaks();
      final averageStreaks = await _advancedStats.getAverageStreaks();
      final totalDays = await _advancedStats.getTotalConsecutiveDays();
      final perfectDays = await _advancedStats.getPerfectDays();
      final weeklyTrends = await _advancedStats.getWeeklyTrends();

      setState(() {
        _successRates = successRates;
        _bestStreaks = bestStreaks;
        _averageStreaks = averageStreaks;
        _totalConsecutiveDays = totalDays;
        _perfectDays = perfectDays;
        _weeklyTrends = weeklyTrends;
        _loadingAdvancedStats = false;
      });
    } catch (e) {
      setState(() {
        _loadingAdvancedStats = false;
      });
    }
  }

  Future<void> _exportStatistics(String format) async {
    try {
      // Mostrar indicador de carga
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Generando estadísticas...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      await StatisticsExportService.shareStatistics(
        widget.activities,
        _advancedStats,
        format: format,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✓ Estadísticas exportadas'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al exportar: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
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
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'export_text') {
                await _exportStatistics('text');
              } else if (value == 'export_csv') {
                await _exportStatistics('csv');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export_text',
                child: Row(
                  children: [
                    Icon(Icons.text_snippet),
                    SizedBox(width: 8),
                    Text('Exportar como texto'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'export_csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart),
                    SizedBox(width: 8),
                    Text('Exportar como CSV'),
                  ],
                ),
              ),
            ],
          ),
        ],
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

          // MÉTRICAS AVANZADAS
          if (!_loadingAdvancedStats) ...[
            const SizedBox(height: 24),
            const Divider(thickness: 2),
            const SizedBox(height: 16),
            const Text(
              '📊 Métricas Avanzadas',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildStatCard(
              context,
              icon: Icons.trending_up,
              iconColor: Colors.orange,
              title: 'Días únicos completados',
              value: '$_totalConsecutiveDays días',
              subtitle: 'Total histórico de días activos',
            ),

            _buildStatCard(
              context,
              icon: Icons.star,
              iconColor: Colors.yellow,
              title: 'Días perfectos',
              value: '${_perfectDays.length} días',
              subtitle: 'Todos los hábitos completados',
            ),

            // Tendencias semanales (sparkline)
            const SizedBox(height: 16),
            const Text(
              'Tendencias semanales (últimas 12 semanas)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildWeeklyTrendsChart(),

            // Heatmap anual
            const SizedBox(height: 24),
            const Text(
              'Heatmap de actividad anual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const ActivityHeatmap(),

            // Gráfico de área mensual
            const SizedBox(height: 24),
            const Text(
              'Evolución mensual',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const MonthlyAreaChart(),

            // Tabla de tasas de éxito
            if (_successRates.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Tasa de éxito por actividad',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.activities.map((activity) {
                final successRate = _successRates[activity.id] ?? 0.0;
                final bestStreak = _bestStreaks[activity.id] ?? 0;
                final avgStreak = _averageStreaks[activity.id] ?? 0.0;

                return Hero(
                  tag: 'activity_card_${activity.id}',
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: successRate >= 70
                            ? Colors.green
                            : successRate >= 40
                                ? Colors.orange
                                : Colors.red,
                        child: Text(
                          '${successRate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      title: Text(activity.name),
                      subtitle: Text(
                        'Récord: $bestStreak días | Promedio: ${avgStreak.toStringAsFixed(1)} días',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Actual',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${activity.streak}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          ],

          if (_loadingAdvancedStats) ...[
            const SizedBox(height: 24),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Cargando métricas avanzadas...'),
                ],
              ),
            ),
          ],

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

          // Timeline interactivo de actividades con historial
          if (widget.activities.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text(
              'Timeline de actividades',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.activities
                .where((a) => a.lastCompleted != null)
                .take(3)
                .map((activity) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InteractiveTimeline(
                        activityId: activity.id,
                        activityName: activity.name,
                      ),
                    )),
          ],

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

    final sections = sortedEntries.asMap().entries.map((entry) {
      final index = entry.key;
      final categoryEntry = entry.value;
      final category = _categoriesMap[categoryEntry.key];
      final percentage = (categoryEntry.value / widget.activities.length * 100)
          .toStringAsFixed(1);
      final color = category?.color ?? Colors.grey;
      final isTouched = index == _touchedCategoryIndex;

      return PieChartSectionData(
        color: color,
        value: categoryEntry.value.toDouble(),
        title: '$percentage%',
        radius: isTouched ? 110 : 100,
        titleStyle: TextStyle(
          fontSize: isTouched ? 16 : 14,
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
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.touchedSection != null) {
                          _touchedCategoryIndex =
                              response!.touchedSection!.touchedSectionIndex;
                        } else {
                          _touchedCategoryIndex = -1;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            if (_touchedCategoryIndex >= 0 &&
                _touchedCategoryIndex < sortedEntries.length) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_categoriesMap[sortedEntries[_touchedCategoryIndex].key]?.name ?? "Sin categoría"}: ${sortedEntries[_touchedCategoryIndex].value} actividades',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: activeCount.toDouble(),
                      title:
                          '${(activeCount / widget.activities.length * 100).toStringAsFixed(1)}%',
                      radius: _touchedStatusIndex == 0 ? 110 : 100,
                      titleStyle: TextStyle(
                        fontSize: _touchedStatusIndex == 0 ? 18 : 16,
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
                        radius: _touchedStatusIndex == 1 ? 110 : 100,
                        titleStyle: TextStyle(
                          fontSize: _touchedStatusIndex == 1 ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (response?.touchedSection != null) {
                          _touchedStatusIndex =
                              response!.touchedSection!.touchedSectionIndex;
                        } else {
                          _touchedStatusIndex = -1;
                        }
                      });
                    },
                  ),
                ),
              ),
            ),
            if (_touchedStatusIndex >= 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color:
                      (_touchedStatusIndex == 0 ? Colors.green : Colors.orange)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _touchedStatusIndex == 0
                      ? 'Activas: $activeCount actividades'
                      : 'Pausadas: $pausedCount actividades',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
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

  Widget _buildWeeklyTrendsChart() {
    if (_weeklyTrends.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No hay suficientes datos para mostrar tendencias',
            textAlign: TextAlign.center,
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
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
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
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _weeklyTrends.length) {
                            final trend = _weeklyTrends[value.toInt()];
                            return Text(
                              '${trend.weekStart.month}/${trend.weekStart.day}',
                              style: const TextStyle(fontSize: 9),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _weeklyTrends.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.completions.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                  ],
                  minY: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Completaciones por semana',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
