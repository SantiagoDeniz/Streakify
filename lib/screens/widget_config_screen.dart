import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity.dart';
import '../services/activity_service.dart';
import '../widgets/home_widget_service.dart';

class WidgetConfigScreen extends StatefulWidget {
  const WidgetConfigScreen({super.key});

  @override
  State<WidgetConfigScreen> createState() => _WidgetConfigScreenState();
}

class _WidgetConfigScreenState extends State<WidgetConfigScreen> {
  List<Activity> _activities = [];
  List<String> _selectedIds = [];
  bool _isDark = false;
  bool _isLoading = true;
  final ActivityService _activityService = ActivityService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final activities = await _activityService.loadActivities();
      final prefs = await SharedPreferences.getInstance();

      setState(() {
        _activities = activities.where((a) => a.active).toList();
        _selectedIds = prefs
                .getStringList(HomeWidgetService.widgetSelectedActivitiesKey) ??
            [];
        _isDark = prefs.getBool(HomeWidgetService.widgetThemeKey) ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar datos: $e')),
        );
      }
    }
  }

  Future<void> _saveConfig() async {
    try {
      await HomeWidgetService.setSelectedActivities(_selectedIds);
      await HomeWidgetService.setWidgetTheme(_isDark);

      // Forzar actualización del widget
      await HomeWidgetService.updateWidget(_activities);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Configuración guardada y widget actualizado')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Widget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildThemeSection(),
                const SizedBox(height: 24),
                _buildSelectionSection(),
                const SizedBox(height: 24),
                _buildPreviewSection(),
              ],
            ),
    );
  }

  Widget _buildThemeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apariencia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Modo Oscuro'),
              subtitle: const Text('Usar colores oscuros en el widget'),
              value: _isDark,
              onChanged: (value) => setState(() => _isDark = value),
              secondary: const Icon(Icons.dark_mode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actividades Visibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecciona hasta 3 actividades para mostrar. Si no seleccionas ninguna, se mostrarán las de mayor racha.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ..._activities.map((activity) {
              final isSelected = _selectedIds.contains(activity.id);
              return CheckboxListTile(
                title: Text(activity.name),
                subtitle: Text('Racha: ${activity.streak} días'),
                secondary: Text(activity.customIcon ?? '🎯'),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      if (_selectedIds.length < 3) {
                        _selectedIds.add(activity.id);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Máximo 3 actividades')),
                        );
                      }
                    } else {
                      _selectedIds.remove(activity.id);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vista Previa (Aproximada)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🔥 Streakify',
                    style: TextStyle(
                      color: const Color(0xFFFF6B35),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'Tus rachas',
                    style: TextStyle(
                      color: _isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_selectedIds.isEmpty)
                _buildPreviewItem(
                    _activities.isNotEmpty ? _activities.first : null, 1)
              else
                ..._selectedIds.map((id) {
                  final activity = _activities.firstWhere(
                    (a) => a.id == id,
                    orElse: () => _activities.first,
                  );
                  return _buildPreviewItem(
                      activity, _selectedIds.indexOf(id) + 1);
                }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewItem(Activity? activity, int index) {
    if (activity == null) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            index == 1
                ? '🥇'
                : index == 2
                    ? '🥈'
                    : '🥉',
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDark ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '🔥 ${activity.streak} días',
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
