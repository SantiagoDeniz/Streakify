import 'package:flutter/material.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import '../widgets/motivation_card.dart';
import '../widgets/buddy_card.dart';
import '../services/social_service.dart';
import '../models/buddy.dart';

class SocialScreen extends StatefulWidget {
  const SocialScreen({Key? key}) : super(key: key);

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final SocialService _socialService = SocialService();
  List<Buddy> _buddies = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBuddies();
  }

  Future<void> _loadBuddies() async {
    final buddies = await _socialService.getBuddies();
    if (mounted) {
      setState(() {
        _buddies = buddies;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidad'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Social', icon: Icon(Icons.people)),
            Tab(text: 'Ranking', icon: Icon(Icons.leaderboard)),
            Tab(text: 'Perfil', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSocialTab(),
          const LeaderboardScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Próximamente: Buscar amigos')),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildSocialTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Motivación Diaria',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const MotivationCard(),
        const SizedBox(height: 24),
        const Text(
          'Mis Compañeros (Buddies)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_buddies.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Aún no tienes compañeros. ¡Invita a alguien!'),
            ),
          )
        else
          ..._buddies.map((buddy) => BuddyCard(buddy: buddy)),
        const SizedBox(height: 24),
        const Text(
          'Grupos de Accountability',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.teal,
              child: Icon(Icons.group, color: Colors.white),
            ),
            title: const Text('Club de Lectura'),
            subtitle: const Text('5 miembros • Racha grupal: 45 días'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
