class LeaderboardEntry {
  final String userId;
  final String userName;
  final String? avatarUrl;
  final int rank;
  final int score;
  final int streakCount;
  final String trend; // 'up', 'down', 'stable'

  LeaderboardEntry({
    required this.userId,
    required this.userName,
    this.avatarUrl,
    required this.rank,
    required this.score,
    required this.streakCount,
    this.trend = 'stable',
  });

  // Mostly used for UI, so map conversion might be simpler or not needed for DB if calculated on fly
  // But useful for caching
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'avatar_url': avatarUrl,
      'rank': rank,
      'score': score,
      'streak_count': streakCount,
      'trend': trend,
    };
  }

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map) {
    return LeaderboardEntry(
      userId: map['user_id'],
      userName: map['user_name'],
      avatarUrl: map['avatar_url'],
      rank: map['rank'],
      score: map['score'],
      streakCount: map['streak_count'],
      trend: map['trend'] ?? 'stable',
    );
  }
}
