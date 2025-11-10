class Activity {
  String id;
  String name;
  int streak;
  DateTime? lastCompleted;
  DateTime? nextProtectorAvailable;
  bool active;
  bool protectorUsed;

  Activity({
    required this.id,
    required this.name,
    this.streak = 0,
    this.lastCompleted,
    this.nextProtectorAvailable,
    this.active = true,
    this.protectorUsed = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'streak': streak,
        'lastCompleted': lastCompleted?.toIso8601String(),
        'nextProtectorAvailable': nextProtectorAvailable?.toIso8601String(),
        'active': active,
        'protectorUsed': protectorUsed,
      };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      streak: json['streak'] ?? 0,
      lastCompleted: json['lastCompleted'] != null ? DateTime.parse(json['lastCompleted']) : null,
      nextProtectorAvailable: json['nextProtectorAvailable'] != null ? DateTime.parse(json['nextProtectorAvailable']) : null,
      active: json['active'] ?? true,
      protectorUsed: json['protectorUsed'] ?? false,
    );
  }
}