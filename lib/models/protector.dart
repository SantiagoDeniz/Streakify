import 'dart:convert';

/// Tipos de protectores disponibles
enum ProtectorType {
  oneDay, // Protege 1 día
  threeDays, // Protege 3 días
  weekly, // Protege toda la semana (7 días)
}

extension ProtectorTypeExtension on ProtectorType {
  String get displayName {
    switch (this) {
      case ProtectorType.oneDay:
        return '1 Día';
      case ProtectorType.threeDays:
        return '3 Días';
      case ProtectorType.weekly:
        return 'Semanal (7 días)';
    }
  }

  String get description {
    switch (this) {
      case ProtectorType.oneDay:
        return 'Protege tu racha por 1 día';
      case ProtectorType.threeDays:
        return 'Protege tu racha por 3 días consecutivos';
      case ProtectorType.weekly:
        return 'Protege tu racha por toda la semana';
    }
  }

  int get durationDays {
    switch (this) {
      case ProtectorType.oneDay:
        return 1;
      case ProtectorType.threeDays:
        return 3;
      case ProtectorType.weekly:
        return 7;
    }
  }

  String get emoji {
    switch (this) {
      case ProtectorType.oneDay:
        return '🛡️';
      case ProtectorType.threeDays:
        return '🛡️🛡️🛡️';
      case ProtectorType.weekly:
        return '🏰';
    }
  }

  String toJson() => name;

  static ProtectorType fromJson(String value) {
    return ProtectorType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProtectorType.oneDay,
    );
  }
}

/// Fuente de obtención del protector
enum ProtectorSource {
  earned, // Ganado por logros
  purchased, // Comprado con puntos de racha
  defaultFree, // Protector gratuito mensual
  reward, // Recompensa especial
}

extension ProtectorSourceExtension on ProtectorSource {
  String get displayName {
    switch (this) {
      case ProtectorSource.earned:
        return 'Ganado';
      case ProtectorSource.purchased:
        return 'Comprado';
      case ProtectorSource.defaultFree:
        return 'Gratuito';
      case ProtectorSource.reward:
        return 'Recompensa';
    }
  }

  String toJson() => name;

  static ProtectorSource fromJson(String value) {
    return ProtectorSource.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProtectorSource.defaultFree,
    );
  }
}

/// Modelo de protector de racha
class Protector {
  String id;
  ProtectorType type;
  ProtectorSource source;
  DateTime createdAt;
  DateTime? usedAt;
  String? activityId; // ID de la actividad donde se usó (null si no se ha usado)
  bool isActive; // Si está actualmente activo
  DateTime? expiresAt; // Cuándo expira el protector activo

  Protector({
    required this.id,
    required this.type,
    required this.source,
    required this.createdAt,
    this.usedAt,
    this.activityId,
    this.isActive = false,
    this.expiresAt,
  });

  /// Verifica si el protector ha sido usado
  bool get isUsed => usedAt != null;

  /// Verifica si el protector está disponible para usar
  bool get isAvailable => !isUsed && !isActive;

  /// Verifica si el protector está actualmente protegiendo
  bool get isProtecting {
    if (!isActive || expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }

  /// Días restantes de protección
  int get daysRemaining {
    if (!isProtecting) return 0;
    return expiresAt!.difference(DateTime.now()).inDays + 1;
  }

  /// Para SQLite
  Map<String, dynamic> toMap() => {
        'id': id,
        'type': type.toJson(),
        'source': source.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'usedAt': usedAt?.toIso8601String(),
        'activityId': activityId,
        'isActive': isActive ? 1 : 0,
        'expiresAt': expiresAt?.toIso8601String(),
      };

  factory Protector.fromMap(Map<String, dynamic> map) {
    return Protector(
      id: map['id'],
      type: ProtectorTypeExtension.fromJson(map['type']),
      source: ProtectorSourceExtension.fromJson(map['source']),
      createdAt: DateTime.parse(map['createdAt']),
      usedAt: map['usedAt'] != null ? DateTime.parse(map['usedAt']) : null,
      activityId: map['activityId'],
      isActive: map['isActive'] == 1,
      expiresAt:
          map['expiresAt'] != null ? DateTime.parse(map['expiresAt']) : null,
    );
  }

  /// Para JSON (exportación)
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toJson(),
        'source': source.toJson(),
        'createdAt': createdAt.toIso8601String(),
        'usedAt': usedAt?.toIso8601String(),
        'activityId': activityId,
        'isActive': isActive,
        'expiresAt': expiresAt?.toIso8601String(),
      };

  factory Protector.fromJson(Map<String, dynamic> json) {
    return Protector(
      id: json['id'],
      type: ProtectorTypeExtension.fromJson(json['type']),
      source: ProtectorSourceExtension.fromJson(json['source']),
      createdAt: DateTime.parse(json['createdAt']),
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
      activityId: json['activityId'],
      isActive: json['isActive'] ?? false,
      expiresAt:
          json['expiresAt'] != null ? DateTime.parse(json['expiresAt']) : null,
    );
  }

  /// Clonar protector
  Protector copyWith({
    String? id,
    ProtectorType? type,
    ProtectorSource? source,
    DateTime? createdAt,
    DateTime? usedAt,
    String? activityId,
    bool? isActive,
    DateTime? expiresAt,
  }) {
    return Protector(
      id: id ?? this.id,
      type: type ?? this.type,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
      activityId: activityId ?? this.activityId,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
