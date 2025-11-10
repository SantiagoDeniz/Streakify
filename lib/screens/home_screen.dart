import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/home_widget_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ActivityService _service = ActivityService();
  List<Activity> _activities = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await _service.loadActivities();
    setState(() => _activities = list);
    // Update widget once loaded
    HomeWidgetService.updateWidget(_activities);
  }

  Future<void> _save() async => _service.saveActivities(_activities);

  void _addActivity(String name) {
    final newAct = Activity(id: const Uuid().v4(), name: name);
    setState(() => _activities.add(newAct));
    _save();
    HomeWidgetService.updateWidget(_activities);
  }

  void _delete(Activity act) {
    setState(() => _activities.remove(act));
    _save();
    HomeWidgetService.updateWidget(_activities);
  }

  void _markCompleted(Activity act) {
    final today = DateTime.now();
    final last = act.lastCompleted != null ? DateTime(act.lastCompleted!.year, act.lastCompleted!.month, act.lastCompleted!.day) : null;
    final nowDay = DateTime(today.year, today.month, today.day);
    if (last == nowDay) return;
    if (last != null && nowDay.difference(last).inDays == 1) {
      act.streak += 1;
    } else {
      act.streak = 1;
    }
    act.lastCompleted = nowDay;
    _save();
    HomeWidgetService.updateWidget(_activities);
    setState(() {});
  }

  void _useProtector(Activity act) {
    if (act.protectorUsed) return;
    act.protectorUsed = true;
    act.nextProtectorAvailable = DateTime.now().add(const Duration(days: 5));
    _save();
    HomeWidgetService.updateWidget(_activities);
    setState(() {});
  }

  void _showAddDialog() {
    String name = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Nueva actividad'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Nombre'),
          onChanged: (val) => name = val,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () { if (name.trim().isNotEmpty) _addActivity(name.trim()); Navigator.pop(context); }, child: const Text('Guardar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Streakify')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: _activities.isEmpty ? Center(child: Text('No hay actividades. Agregá la primera.')) : StreakWidgetView(activities: _activities),
      ),
      floatingActionButton: FloatingActionButton(onPressed: _showAddDialog, child: const Icon(Icons.add)),
    );
  }
}

// Local UI widget used in app preview - not the home screen widget layout
class StreakWidgetView extends StatelessWidget {
  final List<Activity> activities;
  const StreakWidgetView({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final pages = (activities.length / 3).ceil();
    return SizedBox(
      height: 260,
      child: PageView.builder(
        itemCount: pages,
        itemBuilder: (context, index) {
          final start = index * 3;
          final end = (start + 3 > activities.length) ? activities.length : start + 3;
          final subset = activities.sublist(start, end);
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: subset.map((activity) => _buildActivityCard(context, activity)).toList(),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    final protectorText = activity.protectorUsed
        ? '🛡️ Se renueva el ${activity.nextProtectorAvailable != null ? activity.nextProtectorAvailable!.toLocal().toString().split(' ').first : ''}'
        : '🛡️ Disponible';
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: Theme.of(context).brightness == Brightness.dark ? [] : const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0,2))],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_fire_department, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${activity.streak} días de racha', style: const TextStyle(fontSize: 14)),
                Text(protectorText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.check_circle_outline)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.shield)),
            ],
          )
        ],
      ),
    );
  }
}