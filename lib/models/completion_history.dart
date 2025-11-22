/// Representa una completación individual de una actividad
/// Usado para tracking histórico y análisis de tendencias
class CompletionHistory {
  final String id;
  final String activityId;
  final DateTime completedAt;
  final String? notes; // Notas opcionales del usuario
  final bool protectorUsed; // Si se usó protector este día
  
  CompletionHistory({
    required this.id,
    required this.activityId,
    required this.completedAt,
    this.notes,
    this.protectorUsed = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'activityId': activityId,
        'completedAt': completedAt.toIso8601String(),
        'notes': notes,
        'protectorUsed': protectorUsed ? 1 : 0,
      };

  factory CompletionHistory.fromMap(Map<String, dynamic> map) {
    return CompletionHistory(
      id: map['id'],
      activityId: map['activityId'],
      completedAt: DateTime.parse(map['completedAt']),
      notes: map['notes'],
      protectorUsed: map['protectorUsed'] == 1,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'activityId': activityId,
        'completedAt': completedAt.toIso8601String(),
        'notes': notes,
        'protectorUsed': protectorUsed,
      };

  factory CompletionHistory.fromJson(Map<String, dynamic> json) {
    return CompletionHistory(
      id: json['id'],
      activityId: json['activityId'],
      completedAt: DateTime.parse(json['completedAt']),
      notes: json['notes'],
      protectorUsed: json['protectorUsed'] ?? false,
    );
  }
}
