import 'package:flutter/material.dart';
import '../services/advanced_statistics_service.dart';

/// Widget de heatmap de actividad estilo GitHub
/// Muestra un calendario anual con intensidad de color según actividad
class ActivityHeatmap extends StatefulWidget {
  final int? year;

  const ActivityHeatmap({super.key, this.year});

  @override
  State<ActivityHeatmap> createState() => _ActivityHeatmapState();
}

class _ActivityHeatmapState extends State<ActivityHeatmap> {
  final AdvancedStatisticsService _stats = AdvancedStatisticsService();
  Map<DateTime, int> _heatmapData = {};
  bool _loading = true;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.year ?? DateTime.now().year;
    _loadHeatmap();
  }

  Future<void> _loadHeatmap() async {
    setState(() => _loading = true);
    final data = await _stats.getActivityHeatmap(
      year: DateTime(_selectedYear),
    );
    setState(() {
      _heatmapData = data;
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Actividad en $_selectedYear',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() => _selectedYear--);
                        _loadHeatmap();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        if (_selectedYear < DateTime.now().year) {
                          setState(() => _selectedYear++);
                          _loadHeatmap();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHeatmapGrid(),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    // Construir grid de 53 semanas x 7 días
    final startOfYear = DateTime(_selectedYear, 1, 1);
    final endOfYear = DateTime(_selectedYear, 12, 31);

    // Calcular primer lunes del año (o día más cercano)
    final firstMonday = startOfYear.subtract(
      Duration(days: (startOfYear.weekday - 1) % 7),
    );

    // Generar todas las semanas del año
    final weeks = <List<DateTime>>[];
    var currentWeek = <DateTime>[];
    var currentDay = firstMonday;

    while (currentDay.isBefore(endOfYear) ||
        currentDay.isAtSameMomentAs(endOfYear)) {
      currentWeek.add(currentDay);

      if (currentWeek.length == 7) {
        weeks.add(List.from(currentWeek));
        currentWeek.clear();
      }

      currentDay = currentDay.add(const Duration(days: 1));
    }

    if (currentWeek.isNotEmpty) {
      // Rellenar última semana con días del siguiente año
      while (currentWeek.length < 7) {
        currentWeek.add(currentDay);
        currentDay = currentDay.add(const Duration(days: 1));
      }
      weeks.add(currentWeek);
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etiquetas de días de la semana
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildDayLabel('L'),
              _buildDayLabel('M'),
              _buildDayLabel('M'),
              _buildDayLabel('J'),
              _buildDayLabel('V'),
              _buildDayLabel('S'),
              _buildDayLabel('D'),
            ],
          ),
          const SizedBox(width: 8),
          // Grid de semanas
          Row(
            children: weeks.map((week) {
              return Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Column(
                  children: week.map((day) {
                    return _buildDayCell(day);
                  }).toList(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayLabel(String label) {
    return SizedBox(
      height: 15,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDayCell(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    final count = _heatmapData[normalizedDay] ?? 0;
    final isCurrentYear = day.year == _selectedYear;

    Color color;
    if (!isCurrentYear) {
      color = Colors.grey.withOpacity(0.1);
    } else if (count == 0) {
      color = Colors.grey.withOpacity(0.1);
    } else if (count == 1) {
      color = Colors.green.withOpacity(0.3);
    } else if (count == 2) {
      color = Colors.green.withOpacity(0.5);
    } else if (count == 3) {
      color = Colors.green.withOpacity(0.7);
    } else {
      color = Colors.green.withOpacity(0.9);
    }

    return Tooltip(
      message: isCurrentYear
          ? '${day.day}/${day.month}/${day.year}: $count actividad${count != 1 ? 'es' : ''}'
          : '',
      child: Container(
        width: 12,
        height: 12,
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Menos',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
        const SizedBox(width: 8),
        _buildLegendBox(Colors.grey.withOpacity(0.1)),
        _buildLegendBox(Colors.green.withOpacity(0.3)),
        _buildLegendBox(Colors.green.withOpacity(0.5)),
        _buildLegendBox(Colors.green.withOpacity(0.7)),
        _buildLegendBox(Colors.green.withOpacity(0.9)),
        const SizedBox(width: 8),
        const Text(
          'Más',
          style: TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 0.5,
        ),
      ),
    );
  }
}
