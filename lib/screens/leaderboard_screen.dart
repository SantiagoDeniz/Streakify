import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';
import '../models/leaderboard_entry.dart';
import '../widgets/leaderboard_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardService _leaderboardService = LeaderboardService();
  bool _isGlobal = true;
  bool _isLoading = true;
  List<LeaderboardEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final entries = _isGlobal
          ? await _leaderboardService.getGlobalLeaderboard()
          : await _leaderboardService.getFriendsLeaderboard();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment<bool>(
                value: true,
                label: Text('Global'),
                icon: Icon(Icons.public),
              ),
              ButtonSegment<bool>(
                value: false,
                label: Text('Amigos'),
                icon: Icon(Icons.group),
              ),
            ],
            selected: {_isGlobal},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                _isGlobal = newSelection.first;
                _loadLeaderboard();
              });
            },
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return LeaderboardCard(
                      entry: entry,
                      isCurrentUser: entry.userId == 'local_user',
                    );
                  },
                ),
        ),
      ],
    );
  }
}
