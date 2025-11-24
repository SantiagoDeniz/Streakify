import 'package:flutter/material.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardCard({
    Key? key,
    required this.entry,
    this.isCurrentUser = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isCurrentUser ? 4 : 1,
      color: isCurrentUser ? Colors.blue.shade50 : Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrentUser
            ? BorderSide(color: Colors.blue.shade300, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRankColor(entry.rank),
          child: Text(
            '#${entry.rank}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          entry.userName,
          style: TextStyle(
            fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text('${entry.streakCount} días de racha'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.score} XP',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            _getTrendIcon(entry.trend),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber; // Gold
      case 2:
        return Colors.grey.shade400; // Silver
      case 3:
        return Colors.brown.shade400; // Bronze
      default:
        return Colors.blueGrey;
    }
  }

  Widget _getTrendIcon(String trend) {
    switch (trend) {
      case 'up':
        return const Icon(Icons.arrow_upward, color: Colors.green, size: 16);
      case 'down':
        return const Icon(Icons.arrow_downward, color: Colors.red, size: 16);
      default:
        return const Icon(Icons.remove, color: Colors.grey, size: 16);
    }
  }
}
