import '../models/leaderboard_entry.dart';

class LeaderboardService {
  // Get Global Leaderboard (Mock)
  Future<List<LeaderboardEntry>> getGlobalLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate network
    return [
      LeaderboardEntry(
        userId: 'u1',
        userName: 'María L.',
        rank: 1,
        score: 15000,
        streakCount: 365,
        trend: 'stable',
      ),
      LeaderboardEntry(
        userId: 'u2',
        userName: 'Juan P.',
        rank: 2,
        score: 14200,
        streakCount: 300,
        trend: 'up',
      ),
      LeaderboardEntry(
        userId: 'u3',
        userName: 'Sofia R.',
        rank: 3,
        score: 13800,
        streakCount: 280,
        trend: 'down',
      ),
      LeaderboardEntry(
        userId: 'local_user',
        userName: 'Tú',
        rank: 42,
        score: 4500,
        streakCount: 45,
        trend: 'up',
      ),
    ];
  }

  // Get Friends Leaderboard (Mock)
  Future<List<LeaderboardEntry>> getFriendsLeaderboard() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      LeaderboardEntry(
        userId: 'u5',
        userName: 'Ana García',
        rank: 1,
        score: 5200,
        streakCount: 60,
        trend: 'up',
      ),
      LeaderboardEntry(
        userId: 'local_user',
        userName: 'Tú',
        rank: 2,
        score: 4500,
        streakCount: 45,
        trend: 'stable',
      ),
      LeaderboardEntry(
        userId: 'u6',
        userName: 'Carlos Ruiz',
        rank: 3,
        score: 3100,
        streakCount: 20,
        trend: 'down',
      ),
    ];
  }
}
