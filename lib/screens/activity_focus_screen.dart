import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../models/completion_history.dart';
import '../services/database_helper.dart';
import '../utils/activity_icons.dart';
import '../widgets/activity_visualizations.dart';

class ActivityFocusScreen extends StatefulWidget {
  final Activity activity;
  final VoidCallback onComplete;
  final VoidCallback onEdit;

  const ActivityFocusScreen({
    super.key,
    required this.activity,
    required this.onComplete,
    required this.onEdit,
  });

  @override
  State<ActivityFocusScreen> createState() => _ActivityFocusScreenState();
}

class _ActivityFocusScreenState extends State<ActivityFocusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastCompleted = widget.activity.lastCompleted != null
        ? DateTime(
            widget.activity.lastCompleted!.year,
            widget.activity.lastCompleted!.month,
            widget.activity.lastCompleted!.day,
          )
        : null;
    final completedToday = lastCompleted == today;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con efecto de parallax
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.activity.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.activity.customColor != null
                          ? ActivityColors.getColor(
                              widget.activity.customColor!)
                          : Colors.blue,
                      widget.activity.customColor != null
                          ? ActivityColors.getColor(
                                  widget.activity.customColor!)
                              .withOpacity(0.6)
                          : Colors.blue.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Icono grande
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ActivityIcons.getIcon(widget.activity.customIcon),
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Racha
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.activity.streak}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'días',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Contenido
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Estado actual
                _buildStatusCard(completedToday, lastCompleted),

                // Tabs
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.label,
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Estadísticas', icon: Icon(Icons.bar_chart)),
                      Tab(text: 'Progreso', icon: Icon(Icons.trending_up)),
                      Tab(text: 'Historial', icon: Icon(Icons.history)),
                      Tab(text: 'Detalles', icon: Icon(Icons.info)),
                    ],
                  ),
                ),

                // Tab Content
                SizedBox(
                  height: 400,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildStatsTab(),
                      _buildProgressTab(),
                      _buildHistoryTab(),
                      _buildDetailsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !completedToday
          ? FloatingActionButton.extended(
              onPressed: () {
                widget.onComplete();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check),
              label: const Text('Completar Hoy'),
              backgroundColor: Colors.green,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildStatusCard(bool completedToday, DateTime? lastCompleted) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (completedToday) {
      statusText = '¡Completada hoy!';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (lastCompleted != null) {
      final daysSince = DateTime.now().difference(lastCompleted).inDays;
      if (daysSince == 1) {
        statusText = 'Completar hoy para mantener la racha';
        statusColor = Colors.orange;
        statusIcon = Icons.warning_amber;
      } else {
        statusText = 'Racha perdida hace $daysSince días';
        statusColor = Colors.red;
        statusIcon = Icons.error;
      }
    } else {
      statusText = 'Nunca completada';
      statusColor = Colors.grey;
      statusIcon = Icons.radio_button_unchecked;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      color: statusColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  if (lastCompleted != null)
                    Text(
                      'Última vez: ${DateFormat('d MMM yyyy', 'es').format(lastCompleted)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          'Racha Actual',
          '${widget.activity.streak}',
          'días consecutivos',
          Icons.local_fire_department,
          Colors.orange,
        ),
        _buildStatCard(
          'Mejor Racha',
          '${widget.activity.streak}',
          'récord personal',
          Icons.emoji_events,
          Colors.amber,
        ),
        _buildStatCard(
          'Protector',
          widget.activity.protectorUsed ? 'Usado' : 'Disponible',
          widget.activity.protectorUsed &&
                  widget.activity.nextProtectorAvailable != null
              ? 'Se renueva el ${DateFormat('d MMM', 'es').format(widget.activity.nextProtectorAvailable!)}'
              : 'Úsalo cuando sea necesario',
          Icons.shield,
          widget.activity.protectorUsed ? Colors.grey : Colors.blue,
        ),
      ],
    );
  }

  Widget _buildProgressTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progreso Semanal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<bool>>(
                  future: _calculateLast7Days(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return WeeklyProgressBar(last7Days: snapshot.data!);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiempo Restante Hoy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const TimeUntilMidnightIndicator(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return FutureBuilder<List<CompletionHistory>>(
      future: DatabaseHelper().getCompletionHistory(widget.activity.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Sin historial aún',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completa esta actividad para ver tu progreso',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final completions = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completions.length,
          itemBuilder: (context, index) {
            final completion = completions[index];
            final date =
                DateFormat('dd MMM yyyy').format(completion.completedAt);
            final time = DateFormat('HH:mm').format(completion.completedAt);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: completion.protectorUsed
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    completion.protectorUsed
                        ? Icons.shield
                        : Icons.check_circle,
                    color:
                        completion.protectorUsed ? Colors.blue : Colors.green,
                  ),
                ),
                title: Text(
                  date,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hora: $time'),
                    if (completion.notes != null &&
                        completion.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        '📝 ${completion.notes}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (completion.protectorUsed) ...[
                      const SizedBox(height: 4),
                      const Text(
                        '🛡️ Protector usado',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: completion.notes == null || completion.notes!.isEmpty
                    ? IconButton(
                        icon: const Icon(Icons.note_add, size: 20),
                        onPressed: () => _showEditNoteDialog(completion),
                      )
                    : IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => _showEditNoteDialog(completion),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditNoteDialog(CompletionHistory completion) {
    final TextEditingController noteController = TextEditingController(
      text: completion.notes ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          completion.notes == null || completion.notes!.isEmpty
              ? 'Agregar nota'
              : 'Editar nota',
        ),
        content: TextField(
          controller: noteController,
          decoration: const InputDecoration(
            hintText: '¿Cómo te fue ese día?',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          maxLength: 500,
          autofocus: true,
        ),
        actions: [
          if (completion.notes != null && completion.notes!.isNotEmpty)
            TextButton(
              onPressed: () async {
                await DatabaseHelper().updateCompletionNote(completion.id, '');
                Navigator.pop(context);
                setState(() {}); // Refresh
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nota eliminada')),
                );
              },
              child: const Text('Eliminar'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (noteController.text.trim().isNotEmpty) {
                await DatabaseHelper().updateCompletionNote(
                  completion.id,
                  noteController.text.trim(),
                );
                Navigator.pop(context);
                setState(() {}); // Refresh
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('📝 Nota guardada')),
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Tags
        if (widget.activity.tags.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.label, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Tags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.activity.tags
                        .map((tag) => Chip(
                              label: Text('#$tag'),
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Notificaciones
        Card(
          child: ListTile(
            leading: Icon(
              widget.activity.notificationsEnabled
                  ? Icons.notifications_active
                  : Icons.notifications_off,
              color: widget.activity.notificationsEnabled
                  ? Colors.blue
                  : Colors.grey,
            ),
            title: const Text('Notificaciones'),
            subtitle: Text(
              widget.activity.notificationsEnabled
                  ? 'Activadas - ${widget.activity.notificationHour.toString().padLeft(2, '0')}:${widget.activity.notificationMinute.toString().padLeft(2, '0')}'
                  : 'Desactivadas',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
        ),
        const SizedBox(height: 8),

        // Estado
        Card(
          child: ListTile(
            leading: Icon(
              widget.activity.active ? Icons.check_circle : Icons.cancel,
              color: widget.activity.active ? Colors.green : Colors.grey,
            ),
            title: const Text('Estado'),
            subtitle: Text(widget.activity.active ? 'Activa' : 'Inactiva'),
          ),
        ),
        const SizedBox(height: 16),

        // Botón de editar
        ElevatedButton.icon(
          onPressed: () {
            widget.onEdit();
            Navigator.pop(context);
          },
          icon: const Icon(Icons.edit),
          label: const Text('Editar Actividad'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<bool>> _calculateLast7Days() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    List<bool> last7Days = [];

    if (widget.activity.lastCompleted == null) {
      return List.filled(7, false);
    }

    final lastCompletedDate = DateTime(
      widget.activity.lastCompleted!.year,
      widget.activity.lastCompleted!.month,
      widget.activity.lastCompleted!.day,
    );

    for (int i = 6; i >= 0; i--) {
      final checkDate = today.subtract(Duration(days: i));

      if (i == 0) {
        last7Days.add(checkDate == lastCompletedDate);
      } else {
        final daysDiff = today.difference(checkDate).inDays;
        final wasCompleted =
            daysDiff <= widget.activity.streak && lastCompletedDate == today;
        last7Days.add(wasCompleted);
      }
    }

    return last7Days;
  }
}
