import 'package:flutter/material.dart';
import '../models/activity.dart';

/// Widget para configurar la recurrencia de una actividad
class RecurrenceSelector extends StatefulWidget {
  final RecurrenceType selectedType;
  final int interval;
  final List<int> selectedDays;
  final Function(RecurrenceType, int, List<int>) onRecurrenceChanged;

  const RecurrenceSelector({
    super.key,
    required this.selectedType,
    required this.interval,
    required this.selectedDays,
    required this.onRecurrenceChanged,
  });

  @override
  State<RecurrenceSelector> createState() => _RecurrenceSelectorState();
}

class _RecurrenceSelectorState extends State<RecurrenceSelector> {
  late RecurrenceType _type;
  late int _interval;
  late List<int> _days;

  @override
  void initState() {
    super.initState();
    _type = widget.selectedType;
    _interval = widget.interval;
    _days = List.from(widget.selectedDays);
  }

  void _updateRecurrence() {
    widget.onRecurrenceChanged(_type, _interval, _days);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recurrencia',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Selector de tipo de recurrencia
        ...RecurrenceType.values.map((type) {
          return RadioListTile<RecurrenceType>(
            value: type,
            groupValue: _type,
            title: Text(type.displayName),
            selected: _type == type,
            onChanged: (value) {
              setState(() {
                _type = value!;
                _updateRecurrence();
              });
            },
          );
        }),

        const SizedBox(height: 16),

        // Configuración adicional según el tipo
        if (_type == RecurrenceType.everyNDays) ...[
          Text(
            'Cada cuántos días:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: _interval > 1
                    ? () {
                        setState(() {
                          _interval--;
                          _updateRecurrence();
                        });
                      }
                    : null,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_interval',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: _interval < 30
                    ? () {
                        setState(() {
                          _interval++;
                          _updateRecurrence();
                        });
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                _interval == 1 ? 'día' : 'días',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],

        if (_type == RecurrenceType.specificDays) ...[
          Text(
            'Selecciona los días:',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildDayChip(1, 'Lun'),
              _buildDayChip(2, 'Mar'),
              _buildDayChip(3, 'Mié'),
              _buildDayChip(4, 'Jue'),
              _buildDayChip(5, 'Vie'),
              _buildDayChip(6, 'Sáb'),
              _buildDayChip(7, 'Dom'),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // Resumen
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.repeat,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getDescription(),
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDayChip(int dayNumber, String label) {
    final isSelected = _days.contains(dayNumber);
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _days.add(dayNumber);
          } else {
            _days.remove(dayNumber);
          }
          _days.sort();
          _updateRecurrence();
        });
      },
      backgroundColor: Colors.grey.withOpacity(0.2),
      selectedColor: theme.primaryColor.withOpacity(0.3),
      checkmarkColor: theme.primaryColor,
    );
  }

  String _getDescription() {
    switch (_type) {
      case RecurrenceType.daily:
        return 'Se completará todos los días';

      case RecurrenceType.everyNDays:
        return 'Se completará cada $_interval ${_interval == 1 ? 'día' : 'días'}';

      case RecurrenceType.specificDays:
        if (_days.isEmpty) return 'Selecciona al menos un día';
        final dayNames = ['', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
        final selectedDays = _days.map((d) => dayNames[d]).join(', ');
        return 'Se completará los: $selectedDays';

      case RecurrenceType.weekdays:
        return 'Se completará de Lunes a Viernes';

      case RecurrenceType.weekends:
        return 'Se completará Sábado y Domingo';
    }
  }
}
