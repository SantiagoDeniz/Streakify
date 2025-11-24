class AccountabilityGroup {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final int memberCount;
  final int totalGroupStreak;
  final DateTime createdDate;

  AccountabilityGroup({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    this.memberCount = 1,
    this.totalGroupStreak = 0,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'member_count': memberCount,
      'total_group_streak': totalGroupStreak,
      'created_date': createdDate.toIso8601String(),
    };
  }

  factory AccountabilityGroup.fromMap(Map<String, dynamic> map) {
    return AccountabilityGroup(
      id: map['id'],
      name: map['name'],
      description: map['description'] ?? '',
      iconUrl: map['icon_url'],
      memberCount: map['member_count'] ?? 1,
      totalGroupStreak: map['total_group_streak'] ?? 0,
      createdDate: DateTime.parse(map['created_date']),
    );
  }
}
