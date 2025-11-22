import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/advanced_statistics_service.dart';
import '../services/database_helper.dart';

/// Gráfico de área interactivo con tendencias mensuales
class MonthlyAreaChart extends StatefulWidget {
  const MonthlyAreaChart({super.key});

  @override
  State<MonthlyAreaChart> createState() => _MonthlyAreaChartState();
}

class _MonthlyAreaChartState extends State<MonthlyAreaChart> {
  final AdvancedStatisticsService _stats = AdvancedStatisticsService();
  List<MonthlyTrend> _trends = [];
  bool _loading = true;
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final trends = await _stats.getMonthlyTrends();
    setState(() {
      _trends = trends;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_trends.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No hay datos suficientes para mostrar',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tendencia mensual (últimos 12 meses)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (_selectedIndex >= 0) ...[
              const SizedBox(height: 8),
              _buildSelectedInfo(),
            ],
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
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
                              value.toInt() < _trends.length) {
                            final trend = _trends[value.toInt()];
                            final month = _getMonthAbbr(trend.month.month);
                            return Text(
                              month,
                              style: const TextStyle(fontSize: 10),
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
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchCallback: (event, response) {
                      if (response?.lineBarSpots != null &&
                          response!.lineBarSpots!.isNotEmpty) {
                        setState(() {
                          _selectedIndex =
                              response.lineBarSpots!.first.x.toInt();
                        });
                      }
                    },
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final trend = _trends[spot.x.toInt()];
                          return LineTooltipItem(
                            '${_getMonthName(trend.month.month)}\n${spot.y.toInt()} completaciones',
                            const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _trends.asMap().entries.map((entry) {
                        return FlSpot(
                          entry.key.toDouble(),
                          entry.value.completions.toDouble(),
                        );
                      }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: _selectedIndex == index ? 6 : 4,
                            color: _selectedIndex == index
                                ? Colors.orange
                                : Colors.blue,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.3),
                            Colors.blue.withOpacity(0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  minY: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedInfo() {
    if (_selectedIndex < 0 || _selectedIndex >= _trends.length) {
      return const SizedBox.shrink();
    }

    final trend = _trends[_selectedIndex];
    final monthName = _getMonthName(trend.month.month);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            'Mes',
            monthName,
            Icons.calendar_month,
          ),
          _buildInfoItem(
            'Completaciones',
            trend.completions.toString(),
            Icons.check_circle,
          ),
          _buildInfoItem(
            'Días activos',
            trend.activeDays.toString(),
            Icons.wb_sunny,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _getMonthAbbr(int month) {
    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return months[month - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Enero',
      'Febrero',
      'Marzo',
      'Abril',
      'Mayo',
      'Junio',
      'Julio',
      'Agosto',
      'Septiembre',
      'Octubre',
      'Noviembre',
      'Diciembre'
    ];
    return months[month - 1];
  }
}

/// Timeline interactivo con scroll horizontal
class InteractiveTimeline extends StatefulWidget {
  final String activityId;
  final String activityName;

  const InteractiveTimeline({
    super.key,
    required this.activityId,
    required this.activityName,
  });

  @override
  State<InteractiveTimeline> createState() => _InteractiveTimelineState();
}

class _InteractiveTimelineState extends State<InteractiveTimeline> {
  final DatabaseHelper _db = DatabaseHelper();
  List<DateTime> _completionDates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletions();
  }

  Future<void> _loadCompletions() async {
    final completions = await _db.getCompletionHistory(widget.activityId);
    setState(() {
      _completionDates = completions.map((c) => c.completedAt).toList()..sort();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_completionDates.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No hay historial para ${widget.activityName}',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Agrupar por día
    final dayGroups = <DateTime, int>{};
    for (var date in _completionDates) {
      final day = DateTime(date.year, date.month, date.day);
      dayGroups[day] = (dayGroups[day] ?? 0) + 1;
    }

    final sortedDays = dayGroups.keys.toList()..sort();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline: ${widget.activityName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_completionDates.length} completaciones en ${sortedDays.length} días',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sortedDays.length,
                itemBuilder: (context, index) {
                  final day = sortedDays[index];
                  final count = dayGroups[day]!;
                  final isFirst = index == 0;
                  final isLast = index == sortedDays.length - 1;

                  return _buildTimelineItem(
                    day,
                    count,
                    isFirst,
                    isLast,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    DateTime date,
    int count,
    bool isFirst,
    bool isLast,
  ) {
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green, width: 2),
            ),
            child: Center(
              child: Text(
                count > 1 ? '$count×' : '✓',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${date.day}/${date.month}',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
          ),
          Text(
            _getWeekday(date.weekday),
            style: const TextStyle(fontSize: 9, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  String _getWeekday(int weekday) {
    const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return days[weekday - 1];
  }
}
