import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Mini gráfica sparkline que muestra los últimos 7 días
class ActivitySparkline extends StatelessWidget {
  final List<bool> last7Days; // true = completado, false = no completado
  final Color color;
  final double height;

  const ActivitySparkline({
    super.key,
    required this.last7Days,
    this.color = Colors.blue,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    // Asegurar que tengamos exactamente 7 días
    final data = List<bool>.from(last7Days);
    while (data.length < 7) {
      data.insert(0, false);
    }
    if (data.length > 7) {
      data.removeRange(0, data.length - 7);
    }

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 1,
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                7,
                (index) => FlSpot(index.toDouble(), data[index] ? 1.0 : 0.0),
              ),
              isCurved: true,
              color: color,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: data[index] ? color : Colors.grey[300]!,
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.1),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}

/// Widget que muestra barra de progreso con días completados
class WeeklyProgressBar extends StatelessWidget {
  final List<bool> last7Days;
  final Color color;
  final double height;

  const WeeklyProgressBar({
    super.key,
    required this.last7Days,
    this.color = Colors.blue,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    final completedDays = last7Days.where((d) => d).length;
    final progress = completedDays / 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(height / 2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: height,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$completedDays/7',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final isDayBefore = index < last7Days.length;
            final isCompleted = isDayBefore && last7Days[index];

            return Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? color
                    : isDayBefore
                        ? Colors.grey[300]
                        : Colors.grey[200],
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// Indicador de tiempo restante hasta perder racha
class TimeUntilMidnightIndicator extends StatefulWidget {
  final Color color;

  const TimeUntilMidnightIndicator({
    super.key,
    this.color = Colors.orange,
  });

  @override
  State<TimeUntilMidnightIndicator> createState() =>
      _TimeUntilMidnightIndicatorState();
}

class _TimeUntilMidnightIndicatorState
    extends State<TimeUntilMidnightIndicator> {
  late String _timeLeft;

  @override
  void initState() {
    super.initState();
    _updateTime();
    // Actualizar cada minuto
    Future.delayed(const Duration(minutes: 1), _updateTime);
  }

  void _updateTime() {
    if (!mounted) return;

    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final difference = midnight.difference(now);

    setState(() {
      if (difference.inHours > 0) {
        _timeLeft = '${difference.inHours}h ${difference.inMinutes % 60}m';
      } else {
        _timeLeft = '${difference.inMinutes}m';
      }
    });

    // Programar siguiente actualización
    Future.delayed(const Duration(minutes: 1), _updateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: widget.color),
        const SizedBox(width: 4),
        Text(
          _timeLeft,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: widget.color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          'restantes',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
