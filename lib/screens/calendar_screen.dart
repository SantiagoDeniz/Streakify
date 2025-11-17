import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late final ValueNotifier<List<Activity>> _selectedActivities;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<Activity> _allActivities = [];
  Map<DateTime, List<Activity>> _completedActivitiesByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedActivities = ValueNotifier(_getActivitiesForDay(_selectedDay!));
    _loadActivities();
  }

  @override
  void dispose() {
    _selectedActivities.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    final activities = await ActivityService().loadActivities();
    setState(() {
      _allActivities = activities;
      _completedActivitiesByDate = _buildCompletedActivitiesMap();
    });
    _selectedActivities.value = _getActivitiesForDay(_selectedDay!);
  }

  Map<DateTime, List<Activity>> _buildCompletedActivitiesMap() {
    Map<DateTime, List<Activity>> map = {};

    for (var activity in _allActivities) {
      if (activity.lastCompleted != null) {
        final date = DateTime(
          activity.lastCompleted!.year,
          activity.lastCompleted!.month,
          activity.lastCompleted!.day,
        );

        // Agregar todas las fechas de la racha
        for (int i = 0; i < activity.streak && i < 365; i++) {
          final streakDate = date.subtract(Duration(days: i));
          if (!map.containsKey(streakDate)) {
            map[streakDate] = [];
          }
          map[streakDate]!.add(activity);
        }
      }
    }

    return map;
  }

  List<Activity> _getActivitiesForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _completedActivitiesByDate[normalizedDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario de Actividades'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = _focusedDay;
                _selectedActivities.value = _getActivitiesForDay(_selectedDay!);
              });
            },
            tooltip: 'Ir a hoy',
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Activity>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getActivitiesForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red[400]),
              holidayTextStyle: TextStyle(color: Colors.red[800]),
              markerDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              todayDecoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedActivities.value = _getActivitiesForDay(selectedDay);
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Activity>>(
              valueListenable: _selectedActivities,
              builder: (context, activities, _) {
                if (activities.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay actividades completadas',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'en esta fecha',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        title: Text(
                          activity.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Racha actual: ${activity.streak} días',
                          style: TextStyle(
                            color: Colors.orange[700],
                          ),
                        ),
                        trailing: Icon(
                          Icons.local_fire_department,
                          color: Colors.orange[700],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
