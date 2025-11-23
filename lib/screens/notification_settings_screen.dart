import 'package:flutter/material.dart';
import '../models/notification_preferences.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';
import '../services/activity_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final _dbHelper = DatabaseHelper();
  final _notificationService = NotificationService();
  final _activityService = ActivityService();

  NotificationPreferences? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await _dbHelper.getNotificationPreferences();
    setState(() {
      _prefs = prefs;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    if (_prefs == null) return;

    await _dbHelper.updateNotificationPreferences(_prefs!);

    // Reprogramar notificaciones con las nuevas preferencias
    final activities = await _activityService.getAllActivities();
    await _notificationService.rescheduleAllSmartNotifications(
      activities: activities,
      prefs: _prefs!,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Preferencias guardadas'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testNotification() async {
    if (_prefs == null) return;

    await _notificationService.showMotivationalNotification(prefs: _prefs!);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔔 Notificación de prueba enviada'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración de Notificaciones'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_prefs == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Configuración de Notificaciones'),
        ),
        body: const Center(child: Text('Error al cargar preferencias')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración de Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: _testNotification,
            tooltip: 'Probar notificación',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notificaciones Contextuales
          _buildSectionHeader('🎊 Notificaciones Contextuales'),
          SwitchListTile(
            title: const Text('Mensajes motivacionales'),
            subtitle: const Text('Recibe mensajes según tu progreso'),
            value: _prefs!.contextualNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _prefs = _prefs!.copyWith(
                  contextualNotificationsEnabled: value,
                );
              });
              _savePreferences();
            },
          ),
          const Divider(),

          // Alertas de Riesgo
          _buildSectionHeader('🚨 Alertas de Riesgo'),
          SwitchListTile(
            title: const Text('Alertas antes de perder racha'),
            subtitle: Text(
                'Aviso ${_prefs!.riskAlertHoursBefore} horas antes de medianoche'),
            value: _prefs!.riskAlertsEnabled,
            onChanged: (value) {
              setState(() {
                _prefs = _prefs!.copyWith(riskAlertsEnabled: value);
              });
              _savePreferences();
            },
          ),
          if (_prefs!.riskAlertsEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Horas de anticipación: ${_prefs!.riskAlertHoursBefore}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Slider(
                    value: _prefs!.riskAlertHoursBefore.toDouble(),
                    min: 1,
                    max: 6,
                    divisions: 5,
                    label: '${_prefs!.riskAlertHoursBefore} horas',
                    onChanged: (value) {
                      setState(() {
                        _prefs = _prefs!.copyWith(
                          riskAlertHoursBefore: value.toInt(),
                        );
                      });
                    },
                    onChangeEnd: (value) => _savePreferences(),
                  ),
                ],
              ),
            ),
          const Divider(),

          // Resúmenes Diarios
          _buildSectionHeader('🌅 Resúmenes Diarios'),
          SwitchListTile(
            title: const Text('Resúmenes matutinos y nocturnos'),
            subtitle: const Text('Recibe un resumen de tus actividades'),
            value: _prefs!.dailySummaryEnabled,
            onChanged: (value) {
              setState(() {
                _prefs = _prefs!.copyWith(dailySummaryEnabled: value);
              });
              _savePreferences();
            },
          ),
          if (_prefs!.dailySummaryEnabled) ...[
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('Resumen matutino'),
              subtitle: Text(
                  '${_prefs!.morningSummaryHour.toString().padLeft(2, '0')}:${_prefs!.morningSummaryMinute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: _prefs!.morningSummaryHour,
                    minute: _prefs!.morningSummaryMinute,
                  ),
                );
                if (time != null) {
                  setState(() {
                    _prefs = _prefs!.copyWith(
                      morningSummaryHour: time.hour,
                      morningSummaryMinute: time.minute,
                    );
                  });
                  _savePreferences();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: const Text('Resumen nocturno'),
              subtitle: Text(
                  '${_prefs!.eveningSummaryHour.toString().padLeft(2, '0')}:${_prefs!.eveningSummaryMinute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: _prefs!.eveningSummaryHour,
                    minute: _prefs!.eveningSummaryMinute,
                  ),
                );
                if (time != null) {
                  setState(() {
                    _prefs = _prefs!.copyWith(
                      eveningSummaryHour: time.hour,
                      eveningSummaryMinute: time.minute,
                    );
                  });
                  _savePreferences();
                }
              },
            ),
          ],
          const Divider(),

          // Frases Motivacionales
          _buildSectionHeader('💫 Frases Motivacionales'),
          SwitchListTile(
            title: const Text('Incluir frases inspiradoras'),
            subtitle:
                const Text('Agrega frases motivacionales a las notificaciones'),
            value: _prefs!.motivationalQuotesEnabled,
            onChanged: (value) {
              setState(() {
                _prefs = _prefs!.copyWith(motivationalQuotesEnabled: value);
              });
              _savePreferences();
            },
          ),
          const Divider(),

          // Notificaciones de Logros
          _buildSectionHeader('🏆 Logros'),
          SwitchListTile(
            title: const Text('Notificaciones de logros'),
            subtitle: const Text('Aviso cuando desbloqueas un logro'),
            value: _prefs!.achievementNotificationsEnabled,
            onChanged: (value) {
              setState(() {
                _prefs =
                    _prefs!.copyWith(achievementNotificationsEnabled: value);
              });
              _savePreferences();
            },
          ),
          const Divider(),

          // Recordatorios Progresivos
          _buildSectionHeader('⏰ Recordatorios Progresivos'),
          SwitchListTile(
            title: const Text('Recordatorios durante el día'),
            subtitle: const Text('Avisos que aumentan en urgencia'),
            value: _prefs!.progressiveRemindersEnabled,
            onChanged: (value) {
              setState(() {
                _prefs = _prefs!.copyWith(progressiveRemindersEnabled: value);
              });
              _savePreferences();
            },
          ),
          if (_prefs!.progressiveRemindersEnabled) ...[
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Primer recordatorio (suave)'),
              subtitle: Text('${_prefs!.firstReminderHour}:00'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: _prefs!.firstReminderHour, minute: 0),
                );
                if (time != null) {
                  setState(() {
                    _prefs = _prefs!.copyWith(firstReminderHour: time.hour);
                  });
                  _savePreferences();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Segundo recordatorio (moderado)'),
              subtitle: Text('${_prefs!.secondReminderHour}:00'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      TimeOfDay(hour: _prefs!.secondReminderHour, minute: 0),
                );
                if (time != null) {
                  setState(() {
                    _prefs = _prefs!.copyWith(secondReminderHour: time.hour);
                  });
                  _savePreferences();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.notification_important),
              title: const Text('Recordatorio final (urgente)'),
              subtitle: Text('${_prefs!.finalReminderHour}:00'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(hour: _prefs!.finalReminderHour, minute: 0),
                );
                if (time != null) {
                  setState(() {
                    _prefs = _prefs!.copyWith(finalReminderHour: time.hour);
                  });
                  _savePreferences();
                }
              },
            ),
          ],
          const Divider(),

          // Modo No Molestar
          _buildSectionHeader('🌙 Modo No Molestar'),
          SwitchListTile(
            title: const Text('Modo No Molestar'),
            subtitle: const Text('Silenciar notificaciones en horario específico'),
            value: _prefs!.doNotDisturbEnabled,
            onChanged: (value) {
              setState(() {
                _prefs = _prefs!.copyWith(doNotDisturbEnabled: value);
              });
              _savePreferences();
            },
          ),
          if (_prefs!.doNotDisturbEnabled) ...[
            ListTile(
              leading: const Icon(Icons.bedtime),
              title: const Text('Inicio'),
              subtitle: Text(
                  '${_prefs!.doNotDisturbStartHour.toString().padLeft(2, '0')}:${_prefs!.doNotDisturbStartMinute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: _prefs!.doNotDisturbStartHour,
                    minute: _prefs!.doNotDisturbStartMinute,
                  ),
                );
                if (time != null) {
                  setState(() {
                    _prefs = _prefs!.copyWith(
                      doNotDisturbStartHour: time.hour,
                      doNotDisturbStartMinute: time.minute,
                    );
                  });
                  _savePreferences();
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.wb_sunny),
              title: const Text('Fin'),
              subtitle: Text(
                  '${_prefs!.doNotDisturbEndHour.toString().padLeft(2, '0')}:${_prefs!.doNotDisturbEndMinute.toString().padLeft(2, '0')}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay(
                    hour: _prefs!.doNotDisturbEndHour,
                    minute: _prefs!.doNotDisturbEndMinute,
                  ),
                );
                if (time != null) {
                  setState(() {
                    _prefs = _prefs!.copyWith(
                      doNotDisturbEndHour: time.hour,
                      doNotDisturbEndMinute: time.minute,
                    );
                  });
                  _savePreferences();
                }
              },
            ),
          ],
          const SizedBox(height: 24),

          // Botón de prueba
          ElevatedButton.icon(
            onPressed: _testNotification,
            icon: const Icon(Icons.notifications_active),
            label: const Text('Probar Notificación'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}
