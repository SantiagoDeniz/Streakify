class Buddy {
  final String id;
  final String userId;
  final String name;
  final String? avatarUrl;
  final int currentStreak;
  final String status; // 'active', 'pending', 'blocked'
  final DateTime lastInteraction;

  Buddy({
    required this.id,
    required this.userId,
    required this.name,
    this.avatarUrl,
    this.currentStreak = 0,
    this.status = 'pending',
    required this.lastInteraction,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'avatar_url': avatarUrl,
      'current_streak': currentStreak,
      'status': status,
      'last_interaction': lastInteraction.toIso8601String(),
    };
  }

  factory Buddy.fromMap(Map<String, dynamic> map) {
    return Buddy(
      id: map['id'],
      userId: map['user_id'],
      name: map['name'],
      avatarUrl: map['avatar_url'],
      currentStreak: map['current_streak'] ?? 0,
      status: map['status'],
      lastInteraction: DateTime.parse(map['last_interaction']),
    );
  }
}
