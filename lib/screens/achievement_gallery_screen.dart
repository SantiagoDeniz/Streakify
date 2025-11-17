import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

class AchievementGalleryScreen extends StatefulWidget {
  const AchievementGalleryScreen({super.key});

  @override
  State<AchievementGalleryScreen> createState() =>
      _AchievementGalleryScreenState();
}

class _AchievementGalleryScreenState extends State<AchievementGalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<AchievementType, List<Achievement>> _achievementsByType = {};
  int _totalUnlocked = 0;
  int _totalAchievements = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    final achievements = await AchievementService().getAllAchievements();

    setState(() {
      _totalAchievements = achievements.length;
      _totalUnlocked = achievements.where((a) => a.isUnlocked).length;

      // Agrupar por tipo
      _achievementsByType = {
        AchievementType.streak: [],
        AchievementType.totalDays: [],
        AchievementType.activities: [],
        AchievementType.perfect: [],
      };

      for (var achievement in achievements) {
        _achievementsByType[achievement.type]?.add(achievement);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalAchievements > 0
        ? (_totalUnlocked / _totalAchievements * 100).round()
        : 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con estadísticas
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Galería de Logros',
                style: TextStyle(
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
                      Colors.amber.shade700,
                      Colors.orange.shade600,
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Trofeo grande
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.emoji_events,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Estadísticas
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$_totalUnlocked / $_totalAchievements desbloqueados ($progress%)',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Barra de progreso
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progreso General',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$progress%',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: progress == 100 ? Colors.green : Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _totalAchievements > 0
                          ? _totalUnlocked / _totalAchievements
                          : 0,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 100 ? Colors.green : Colors.amber,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tabs
          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.view_module, size: 20),
                      const SizedBox(width: 4),
                      Text('Todos (${_totalAchievements})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department, size: 20),
                      const SizedBox(width: 4),
                      Text(
                          'Rachas (${_achievementsByType[AchievementType.streak]?.length ?? 0})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 20),
                      const SizedBox(width: 4),
                      Text(
                          'Días (${_achievementsByType[AchievementType.totalDays]?.length ?? 0})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 20),
                      const SizedBox(width: 4),
                      Text(
                          'Perfectos (${_achievementsByType[AchievementType.perfect]?.length ?? 0})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(Icons.list_alt, size: 20),
                      const SizedBox(width: 4),
                      Text(
                          'Actividades (${_achievementsByType[AchievementType.activities]?.length ?? 0})'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Contenido de tabs
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllAchievements(),
                _buildAchievementsByType(AchievementType.streak),
                _buildAchievementsByType(AchievementType.totalDays),
                _buildAchievementsByType(AchievementType.perfect),
                _buildAchievementsByType(AchievementType.activities),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllAchievements() {
    final allAchievements =
        _achievementsByType.values.expand((list) => list).toList()
          ..sort((a, b) {
            // Desbloqueados primero, luego por tipo y valor
            if (a.isUnlocked != b.isUnlocked) {
              return a.isUnlocked ? -1 : 1;
            }
            if (a.type != b.type) {
              return a.type.index.compareTo(b.type.index);
            }
            return a.requiredValue.compareTo(b.requiredValue);
          });

    return _buildAchievementGrid(allAchievements);
  }

  Widget _buildAchievementsByType(AchievementType type) {
    final achievements = _achievementsByType[type] ?? [];
    achievements.sort((a, b) => a.requiredValue.compareTo(b.requiredValue));
    return _buildAchievementGrid(achievements);
  }

  Widget _buildAchievementGrid(List<Achievement> achievements) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay logros en esta categoría',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(achievements[index]);
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return GestureDetector(
      onTap: () => _showAchievementDetail(achievement),
      child: Card(
        elevation: achievement.isUnlocked ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: achievement.isUnlocked
                ? achievement.color.withOpacity(0.5)
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: achievement.isUnlocked
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      achievement.color.withOpacity(0.1),
                      achievement.color.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge/Medalla
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: achievement.isUnlocked
                          ? achievement.color.withOpacity(0.2)
                          : Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    achievement.icon,
                    size: 50,
                    color: achievement.isUnlocked
                        ? achievement.color
                        : Colors.grey.shade400,
                  ),
                  if (achievement.isUnlocked)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Título
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: achievement.isUnlocked
                        ? Colors.black
                        : Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // Descripción
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  achievement.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              if (achievement.isUnlocked && achievement.unlockedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('d MMM yyyy', 'es')
                        .format(achievement.unlockedAt!),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAchievementDetail(Achievement achievement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Medalla grande
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? achievement.color.withOpacity(0.2)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                achievement.icon,
                size: 80,
                color: achievement.isUnlocked
                    ? achievement.color
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            // Título
            Text(
              achievement.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Descripción
            Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            // Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? Colors.green.withOpacity(0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    achievement.isUnlocked ? Icons.check_circle : Icons.lock,
                    color: achievement.isUnlocked ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    achievement.isUnlocked ? 'Desbloqueado' : 'Bloqueado',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          achievement.isUnlocked ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Desbloqueado el ${DateFormat('d MMMM yyyy', 'es').format(achievement.unlockedAt!)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Tipo y requisito
            Chip(
              avatar: Icon(
                _getTypeIcon(achievement.type),
                size: 18,
              ),
              label: Text(
                '${_getTypeName(achievement.type)}: ${achievement.requiredValue}',
                style: const TextStyle(fontSize: 12),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.totalDays:
        return Icons.calendar_today;
      case AchievementType.perfect:
        return Icons.star;
      case AchievementType.activities:
        return Icons.list_alt;
    }
  }

  String _getTypeName(AchievementType type) {
    switch (type) {
      case AchievementType.streak:
        return 'Racha';
      case AchievementType.totalDays:
        return 'Total días';
      case AchievementType.perfect:
        return 'Días perfectos';
      case AchievementType.activities:
        return 'Actividades';
    }
  }
}
