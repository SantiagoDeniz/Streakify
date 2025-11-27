import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/activity.dart';
import '../services/optimal_time_service.dart';
import '../services/activity_service.dart';
import '../services/notification_service.dart';

/// Pantalla para mostrar insights sobre horarios óptimos de completación
class OptimalTimeInsightsScreen extends StatefulWidget {
  const OptimalTimeInsightsScreen({Key? key}) : super(key: key);

  @override
  State<OptimalTimeInsightsScreen> createState() =>
      _OptimalTimeInsightsScreenState();
}

class _OptimalTimeInsightsScreenState extends State<OptimalTimeInsightsScreen> {
  final OptimalTimeService _optimalTimeService = OptimalTimeService();
  final ActivityService _activityService = ActivityService();
  final NotificationService _notificationService = NotificationService();

  List<Activity> _activities = [];
  Map<String, Map<String, dynamic>> _recommendations = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final activities = await _activityService.getActiveActivities();
    final recommendations =
        await _optimalTimeService.getRecommendationsForActivities(activities);

    setState(() {
      _activities = activities;
      _recommendations = recommendations;
      _isLoading = false;
    });
  }

  Future<void> _applyRecommendation(Activity activity) async {
    final recommendation = _recommendations[activity.id];
    if (recommendation == null) return;

    final hour = recommendation['hour'] as int;
    final minute = recommendation['minute'] as int;

    // Actualizar horario de la actividad
    await _activityService.updateActivityNotificationTime(
      activity.id,
      hour,
      minute,
    );

    // Reprogramar notificación
    activity.notificationHour = hour;
    activity.notificationMinute = minute;
    await _notificationService.updateActivityNotification(activity);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Horario actualizado a ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Recargar datos
    await _loadData();
  }

  Future<void> _applyAllRecommendations() async {
    int applied = 0;

    for (var activity in _activities) {
      final recommendation = _recommendations[activity.id];
      if (recommendation == null) continue;

      final hour = recommendation['hour'] as int;
      final minute = recommendation['minute'] as int;

      // Actualizar horario
      await _activityService.updateActivityNotificationTime(
        activity.id,
        hour,
        minute,
      );

      // Reprogramar notificación
      activity.notificationHour = hour;
      activity.notificationMinute = minute;
      await _notificationService.updateActivityNotification(activity);

      applied++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$applied horarios actualizados'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Recargar datos
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios Óptimos'),
        actions: [
          if (_recommendations.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check_circle),
              tooltip: 'Aplicar todas las recomendaciones',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Aplicar todas las recomendaciones'),
                    content: Text(
                      '¿Deseas actualizar los horarios de ${_recommendations.length} actividades?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Aplicar'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _applyAllRecommendations();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activities.isEmpty
              ? const Center(
                  child: Text(
                    'No hay actividades para analizar',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _activities.length,
                  itemBuilder: (context, index) {
                    final activity = _activities[index];
                    final recommendation = _recommendations[activity.id];

                    return _ActivityInsightCard(
                      activity: activity,
                      recommendation: recommendation,
                      optimalTimeService: _optimalTimeService,
                      onApply: () => _applyRecommendation(activity),
                    );
                  },
                ),
    );
  }
}

class _ActivityInsightCard extends StatefulWidget {
  final Activity activity;
  final Map<String, dynamic>? recommendation;
  final OptimalTimeService optimalTimeService;
  final VoidCallback onApply;

  const _ActivityInsightCard({
    required this.activity,
    required this.recommendation,
    required this.optimalTimeService,
    required this.onApply,
  });

  @override
  State<_ActivityInsightCard> createState() => _ActivityInsightCardState();
}

class _ActivityInsightCardState extends State<_ActivityInsightCard> {
  bool _expanded = false;
  Map<int, int>? _hourlyDistribution;

  @override
  void initState() {
    super.initState();
    _loadDistribution();
  }

  Future<void> _loadDistribution() async {
    final distribution = await widget.optimalTimeService
        .getHourlyCompletionDistribution(widget.activity.id);
    setState(() => _hourlyDistribution = distribution);
  }

  @override
  Widget build(BuildContext context) {
    final hasRecommendation = widget.recommendation != null;
    final currentTime =
        '${widget.activity.notificationHour.toString().padLeft(2, '0')}:${widget.activity.notificationMinute.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.activity.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: hasRecommendation
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Horario actual: $currentTime'),
                      const SizedBox(height: 4),
                      _buildRecommendationText(),
                    ],
                  )
                : const Text('No hay suficientes datos para analizar'),
            trailing: hasRecommendation
                ? IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    color: Colors.green,
                    onPressed: widget.onApply,
                    tooltip: 'Aplicar recomendación',
                  )
                : null,
            onTap: () => setState(() => _expanded = !_expanded),
          ),
          if (_expanded && hasRecommendation) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfidenceIndicator(),
                  const SizedBox(height: 16),
                  if (_hourlyDistribution != null) _buildHourlyChart(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationText() {
    final hour = widget.recommendation!['hour'] as int;
    final minute = widget.recommendation!['minute'] as int;
    final confidence = widget.recommendation!['confidence'] as double;

    final recommendedTime =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

    return Row(
      children: [
        const Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          'Recomendado: $recommendedTime',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '(${(confidence * 100).toStringAsFixed(0)}% confianza)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator() {
    final confidence = widget.recommendation!['confidence'] as double;

    Color getColor() {
      if (confidence >= 0.8) return Colors.green;
      if (confidence >= 0.6) return Colors.orange;
      return Colors.red;
    }

    String getLabel() {
      if (confidence >= 0.8) return 'Alta confianza';
      if (confidence >= 0.6) return 'Confianza media';
      return 'Baja confianza';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nivel de confianza',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            Text(
              getLabel(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: getColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(getColor()),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildHourlyChart() {
    if (_hourlyDistribution == null || _hourlyDistribution!.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxCount = _hourlyDistribution!.values.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución por hora',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxCount.toDouble() * 1.2,
              barTouchData: BarTouchData(enabled: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}h',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
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
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              barGroups: _hourlyDistribution!.entries.map((entry) {
                final hour = entry.key;
                final count = entry.value;
                final isOptimal = hour == widget.recommendation!['hour'];

                return BarChartGroupData(
                  x: hour,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: isOptimal ? Colors.amber : Colors.blue,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
