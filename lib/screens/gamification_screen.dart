import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/gamification.dart';

import '../services/gamification_service.dart';
import '../services/activity_service.dart';

/// Pantalla completa de gamificación
class GamificationScreen extends StatefulWidget {
  const GamificationScreen({super.key});

  @override
  State<GamificationScreen> createState() => _GamificationScreenState();
}

class _GamificationScreenState extends State<GamificationScreen>
    with SingleTickerProviderStateMixin {
  final GamificationService _gamification = GamificationService();
  final ActivityService _activityService = ActivityService();

  UserLevel? _userLevel;
  List<Medal> _medals = [];
  WeeklyChallenge? _weeklyChallenge;
  List<ConsistencyReward> _rewards = [];
  bool _loading = true;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    final level = await _gamification.getUserLevel();
    final medals = await _gamification.getMedals();
    await _gamification.getWeeklyChallenge();
    final rewards = await _gamification.getConsistencyRewards();

    // Actualizar progreso del desafío
    final activities = await _activityService.loadActivities();
    await _gamification.updateChallengeProgress(activities);
    final updatedChallenge = await _gamification.getWeeklyChallenge();

    setState(() {
      _userLevel = level;
      _medals = medals;
      _weeklyChallenge = updatedChallenge;
      _rewards = rewards;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gamificación'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.star), text: 'Nivel'),
            Tab(icon: Icon(Icons.workspace_premium), text: 'Medallas'),
            Tab(icon: Icon(Icons.flag), text: 'Desafío'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Recompensas'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLevelTab(),
                _buildMedalsTab(),
                _buildChallengeTab(),
                _buildRewardsTab(),
              ],
            ),
    );
  }

  Widget _buildLevelTab() {
    if (_userLevel == null) return const SizedBox();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          UserLevel.getColorForLevel(_userLevel!.level),
                          UserLevel.getColorForLevel(_userLevel!.level)
                              .withOpacity(0.5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: UserLevel.getColorForLevel(_userLevel!.level)
                              .withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${_userLevel!.level}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _userLevel!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Progreso al siguiente nivel',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _userLevel!.progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      UserLevel.getColorForLevel(_userLevel!.level),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_userLevel!.currentPoints} / ${_userLevel!.pointsForNextLevel} puntos',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '¿Cómo ganar puntos?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildPointsInfoCard(
            'Medalla de Bronce',
            '10 puntos',
            Icons.workspace_premium,
            MedalTier.bronze.color,
          ),
          _buildPointsInfoCard(
            'Medalla de Plata',
            '25 puntos',
            Icons.workspace_premium,
            MedalTier.silver.color,
          ),
          _buildPointsInfoCard(
            'Medalla de Oro',
            '50 puntos',
            Icons.workspace_premium,
            MedalTier.gold.color,
          ),
          _buildPointsInfoCard(
            'Medalla de Platino',
            '100 puntos',
            Icons.workspace_premium,
            MedalTier.platinum.color,
          ),
          _buildPointsInfoCard(
            'Desafío Semanal',
            '50 puntos',
            Icons.flag,
            Colors.purple,
          ),
          _buildPointsInfoCard(
            'Recompensas por Consistencia',
            '2× días de racha',
            Icons.emoji_events,
            Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _buildPointsInfoCard(
    String title,
    String points,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(title),
        trailing: Text(
          points,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMedalsTab() {
    final bronzeMedals =
        _medals.where((m) => m.tier == MedalTier.bronze).length;
    final silverMedals =
        _medals.where((m) => m.tier == MedalTier.silver).length;
    final goldMedals = _medals.where((m) => m.tier == MedalTier.gold).length;
    final platinumMedals =
        _medals.where((m) => m.tier == MedalTier.platinum).length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Colección de Medallas',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMedalCount(
                        MedalTier.bronze.name,
                        bronzeMedals,
                        MedalTier.bronze.color,
                      ),
                      _buildMedalCount(
                        MedalTier.silver.name,
                        silverMedals,
                        MedalTier.silver.color,
                      ),
                      _buildMedalCount(
                        MedalTier.gold.name,
                        goldMedals,
                        MedalTier.gold.color,
                      ),
                      _buildMedalCount(
                        MedalTier.platinum.name,
                        platinumMedals,
                        MedalTier.platinum.color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_medals.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  '¡Aún no tienes medallas!\n\nCompleta logros para ganar medallas de diferentes niveles.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            )
          else
            ..._medals.map((medal) => _buildMedalCard(medal)),
        ],
      ),
    );
  }

  Widget _buildMedalCount(String name, int count, Color color) {
    return Column(
      children: [
        Icon(Icons.workspace_premium, color: color, size: 40),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          name,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMedalCard(Medal medal) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.workspace_premium,
          color: medal.tier.color,
          size: 40,
        ),
        title: Text(medal.tier.name),
        subtitle: Text(
          'Logro: ${medal.achievementId}\n${DateFormat('dd/MM/yyyy').format(medal.earnedAt)}',
        ),
        trailing: Text(
          '+${medal.tier.points}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeTab() {
    if (_weeklyChallenge == null) return const SizedBox();

    final daysLeft =
        _weeklyChallenge!.endDate.difference(DateTime.now()).inDays;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    _weeklyChallenge!.icon,
                    size: 64,
                    color: _weeklyChallenge!.isCompleted
                        ? Colors.green
                        : Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _weeklyChallenge!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _weeklyChallenge!.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_weeklyChallenge!.isCompleted) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            '¡Desafío Completado! +50 puntos',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'Progreso: ${_weeklyChallenge!.currentProgress} / ${_weeklyChallenge!.targetValue}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _weeklyChallenge!.progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'Quedan $daysLeft días',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Consejos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '• Los desafíos se renuevan cada semana\n'
                    '• Completa el desafío antes de que termine la semana\n'
                    '• Cada desafío completado otorga 50 puntos\n'
                    '• El progreso se actualiza automáticamente',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsTab() {
    final earnedCount = _rewards.where((r) => r.isEarned).length;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Recompensas por Consistencia',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$earnedCount de ${_rewards.length} desbloqueadas',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: earnedCount / _rewards.length,
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._rewards.map((reward) => _buildRewardCard(reward)),
        ],
      ),
    );
  }

  Widget _buildRewardCard(ConsistencyReward reward) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Opacity(
        opacity: reward.isEarned ? 1.0 : 0.5,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: reward.isEarned
                      ? reward.color.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reward.icon,
                  color: reward.isEarned ? reward.color : Colors.grey,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${reward.daysRequired * 2} puntos',
                      style: TextStyle(
                        fontSize: 12,
                        color: reward.isEarned ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (reward.isEarned)
                const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 32,
                )
              else
                const Icon(
                  Icons.lock,
                  color: Colors.grey,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
