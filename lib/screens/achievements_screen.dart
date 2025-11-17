import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  final AchievementService _service = AchievementService();
  late TabController _tabController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = _service.getUnlockedAchievements();
    final lockedAchievements = _service.getLockedAchievements();
    final userLevel = _service.getUserLevel();
    final userPoints = _service.getUserPoints();
    final completionPercentage = _service.getCompletionPercentage();
    final progressToNextLevel = _service.getProgressToNextLevel();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Hero(
              tag: 'achievements_title',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  'Logros y Gamificación',
                  style: Theme.of(context).appBarTheme.titleTextStyle,
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.emoji_events),
                  text: 'Desbloqueados (${unlockedAchievements.length})',
                ),
                Tab(
                  icon: const Icon(Icons.lock_outline),
                  text: 'Bloqueados (${lockedAchievements.length})',
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // Card de perfil del usuario
              _buildUserProfileCard(
                userLevel: userLevel,
                userPoints: userPoints,
                completionPercentage: completionPercentage,
                progressToNextLevel: progressToNextLevel,
              ),

              // Lista de logros por tabs
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab de desbloqueados
                    unlockedAchievements.isEmpty
                        ? _buildEmptyState(
                            icon: Icons.emoji_events,
                            message: 'Aún no has desbloqueado logros',
                            subtitle:
                                '¡Sigue completando actividades para desbloquear!',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: unlockedAchievements.length,
                            itemBuilder: (context, index) {
                              return _buildAchievementCard(
                                unlockedAchievements[index],
                                isUnlocked: true,
                              );
                            },
                          ),

                    // Tab de bloqueados
                    lockedAchievements.isEmpty
                        ? _buildEmptyState(
                            icon: Icons.auto_awesome,
                            message: '¡Felicidades!',
                            subtitle:
                                'Has desbloqueado todos los logros disponibles',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: lockedAchievements.length,
                            itemBuilder: (context, index) {
                              return _buildAchievementCard(
                                lockedAchievements[index],
                                isUnlocked: false,
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.2,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.yellow,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfileCard({
    required int userLevel,
    required int userPoints,
    required double completionPercentage,
    required double progressToNextLevel,
  }) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar con nivel
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Nivel',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$userLevel',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Información del usuario
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu Progreso',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$userPoints puntos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.emoji_events,
                            color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${completionPercentage.toStringAsFixed(0)}% completado',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barra de progreso al siguiente nivel
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Nivel $userLevel',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Nivel ${userLevel + 1}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: progressToNextLevel),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.amber),
                      minHeight: 10,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement,
      {required bool isUnlocked}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: isUnlocked ? 4 : 1,
        child: ListTile(
          leading: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? achievement.color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              achievement.icon,
              color: isUnlocked ? achievement.color : Colors.grey,
              size: 32,
            ),
          ),
          title: Text(
            achievement.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isUnlocked ? null : Colors.grey,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.description,
                style: TextStyle(
                  color: isUnlocked ? null : Colors.grey,
                ),
              ),
              if (isUnlocked && achievement.unlockedAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Desbloqueado: ${_formatDate(achievement.unlockedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: achievement.color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          trailing: isUnlocked
              ? Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: achievement.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: achievement.color,
                  ),
                )
              : Icon(
                  Icons.lock_outline,
                  color: Colors.grey,
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
