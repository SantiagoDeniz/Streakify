import 'package:flutter/material.dart';

/// Widget para configurar rachas avanzadas
class StreakConfigWidget extends StatefulWidget {
  final int allowedFailures;
  final List<int> freeDays;
  final int? partialGoalRequired;
  final int? partialGoalTotal;
  final int dailyGoal;
  final Function(
    int allowedFailures,
    List<int> freeDays,
    int? partialGoalRequired,
    int? partialGoalTotal,
    int dailyGoal,
  ) onChanged;

  const StreakConfigWidget({
    Key? key,
    required this.allowedFailures,
    required this.freeDays,
    this.partialGoalRequired,
    this.partialGoalTotal,
    this.dailyGoal = 1,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<StreakConfigWidget> createState() => _StreakConfigWidgetState();
}

class _StreakConfigWidgetState extends State<StreakConfigWidget> {
  late int _allowedFailures;
  late List<int> _freeDays;
  late int? _partialGoalRequired;
  late int? _partialGoalTotal;
  late int _dailyGoal;
  bool _showPartialGoal = false;
  bool _showMultipleCompletions = false;

  @override
  void initState() {
    super.initState();
    _allowedFailures = widget.allowedFailures;
    _freeDays = List<int>.from(widget.freeDays);
    _partialGoalRequired = widget.partialGoalRequired;
    _partialGoalTotal = widget.partialGoalTotal;
    _dailyGoal = widget.dailyGoal;
    _showPartialGoal =
        _partialGoalRequired != null && _partialGoalTotal != null;
    _showMultipleCompletions = _dailyGoal > 1;
  }

  void _updateValues() {
    widget.onChanged(
      _allowedFailures,
      _freeDays,
      _showPartialGoal ? _partialGoalRequired : null,
      _showPartialGoal ? _partialGoalTotal : null,
      _dailyGoal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rachas flexibles
        Text(
          'Rachas Flexibles',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Permite fallar X veces por semana sin perder la racha',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Fallos permitidos por semana:',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: _allowedFailures > 0
                  ? () {
                      setState(() {
                        _allowedFailures--;
                        _updateValues();
                      });
                    }
                  : null,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_allowedFailures',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _allowedFailures < 6
                  ? () {
                      setState(() {
                        _allowedFailures++;
                        _updateValues();
                      });
                    }
                  : null,
            ),
          ],
        ),
        if (_allowedFailures > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: theme.primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Puedes fallar hasta $_allowedFailures ${_allowedFailures == 1 ? 'vez' : 'veces'} por semana',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        // Días libres
        Text(
          'Días Libres',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Días que no cuentan para la racha (ej: descanso semanal)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDayChip(1, 'Lun', theme, isDark),
            _buildDayChip(2, 'Mar', theme, isDark),
            _buildDayChip(3, 'Mié', theme, isDark),
            _buildDayChip(4, 'Jue', theme, isDark),
            _buildDayChip(5, 'Vie', theme, isDark),
            _buildDayChip(6, 'Sáb', theme, isDark),
            _buildDayChip(7, 'Dom', theme, isDark),
          ],
        ),
        if (_freeDays.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.beach_access, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Días libres configurados: ${_getFreeDaysText()}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        // Rachas parciales
        Row(
          children: [
            Text(
              'Rachas Parciales',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Switch(
              value: _showPartialGoal,
              onChanged: (value) {
                setState(() {
                  _showPartialGoal = value;
                  if (value) {
                    _partialGoalRequired = 5;
                    _partialGoalTotal = 7;
                  }
                  _updateValues();
                });
              },
            ),
          ],
        ),
        if (_showPartialGoal) ...[
          const SizedBox(height: 8),
          Text(
            'Completar X días de Y días por semana',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Completar', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: (_partialGoalRequired ?? 1) > 1
                              ? () {
                                  setState(() {
                                    _partialGoalRequired =
                                        (_partialGoalRequired ?? 1) - 1;
                                    _updateValues();
                                  });
                                }
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_partialGoalRequired ?? 1}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: (_partialGoalRequired ?? 1) <
                                  (_partialGoalTotal ?? 7)
                              ? () {
                                  setState(() {
                                    _partialGoalRequired =
                                        (_partialGoalRequired ?? 1) + 1;
                                    _updateValues();
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('De total', style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: (_partialGoalTotal ?? 7) >
                                  (_partialGoalRequired ?? 1)
                              ? () {
                                  setState(() {
                                    _partialGoalTotal =
                                        (_partialGoalTotal ?? 7) - 1;
                                    _updateValues();
                                  });
                                }
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_partialGoalTotal ?? 7}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.purple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: (_partialGoalTotal ?? 7) < 7
                              ? () {
                                  setState(() {
                                    _partialGoalTotal =
                                        (_partialGoalTotal ?? 7) + 1;
                                    _updateValues();
                                  });
                                }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.analytics, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Completar ${_partialGoalRequired ?? 1} de ${_partialGoalTotal ?? 7} días por semana',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),

        // Múltiples completaciones diarias
        Row(
          children: [
            Text(
              'Múltiples Completaciones',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Switch(
              value: _showMultipleCompletions,
              onChanged: (value) {
                setState(() {
                  _showMultipleCompletions = value;
                  _dailyGoal = value ? 2 : 1;
                  _updateValues();
                });
              },
            ),
          ],
        ),
        if (_showMultipleCompletions) ...[
          const SizedBox(height: 8),
          Text(
            'Completar varias veces al día',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Completaciones por día:'),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: _dailyGoal > 1
                    ? () {
                        setState(() {
                          _dailyGoal--;
                          _updateValues();
                        });
                      }
                    : null,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_dailyGoal',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: _dailyGoal < 10
                    ? () {
                        setState(() {
                          _dailyGoal++;
                          _updateValues();
                        });
                      }
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.repeat, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Marcar completada $_dailyGoal ${_dailyGoal == 1 ? 'vez' : 'veces'} al día',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDayChip(int day, String label, ThemeData theme, bool isDark) {
    final isSelected = _freeDays.contains(day);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _freeDays.add(day);
          } else {
            _freeDays.remove(day);
          }
          _freeDays.sort();
          _updateValues();
        });
      },
      selectedColor: Colors.green.withOpacity(0.3),
      checkmarkColor: Colors.green,
      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.green
            : (isDark ? Colors.white70 : Colors.black87),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _getFreeDaysText() {
    if (_freeDays.isEmpty) return 'Ninguno';
    final dayNames = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
    return _freeDays.map((d) => dayNames[d]).join(', ');
  }
}
