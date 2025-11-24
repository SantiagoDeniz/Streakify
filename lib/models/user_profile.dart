class UserProfile {
  final String id;
  final String username;
  final String displayName;
  final String? avatarUrl;
  final String bio;
  final bool isPublic;
  final int totalStreaks;
  final int currentStreak;
  final int totalXp;
  final List<String> badges;
  final DateTime joinedDate;

  UserProfile({
    required this.id,
    required this.username,
    required this.displayName,
    this.avatarUrl,
    this.bio = '',
    this.isPublic = true,
    this.totalStreaks = 0,
    this.currentStreak = 0,
    this.totalXp = 0,
    this.badges = const [],
    required this.joinedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'is_public': isPublic ? 1 : 0,
      'total_streaks': totalStreaks,
      'current_streak': currentStreak,
      'total_xp': totalXp,
      'badges': badges.join(','),
      'joined_date': joinedDate.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      username: map['username'],
      displayName: map['display_name'],
      avatarUrl: map['avatar_url'],
      bio: map['bio'] ?? '',
      isPublic: map['is_public'] == 1,
      totalStreaks: map['total_streaks'] ?? 0,
      currentStreak: map['current_streak'] ?? 0,
      totalXp: map['total_xp'] ?? 0,
      badges: map['badges'] != null && map['badges'].toString().isNotEmpty
          ? map['badges'].toString().split(',')
          : [],
      joinedDate: DateTime.parse(map['joined_date']),
    );
  }
}
