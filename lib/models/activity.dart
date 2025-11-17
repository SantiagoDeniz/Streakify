import 'dart:convert';

class Activity {
  String id;
  String name;
  int streak;
  DateTime? lastCompleted;
  DateTime? nextProtectorAvailable;
  bool active;
  bool protectorUsed;
  String? categoryId; // ID de la categoría
  List<String> tags; // Lista de tags

  // Configuración de notificaciones
  bool notificationsEnabled;
  int notificationHour;
  int notificationMinute;
  String? customMessage;

  // Personalización visual
  String?
      customIcon; // Nombre del icono (ej: 'fitness_center', 'book', 'water_drop')
  String? customColor; // Color en formato hex (ej: '#FF5722')
  int displayOrder; // Orden de visualización para drag & drop

  Activity({
    required this.id,
    required this.name,
    this.streak = 0,
    this.lastCompleted,
    this.nextProtectorAvailable,
    this.active = true,
    this.protectorUsed = false,
    this.categoryId,
    List<String>? tags,
    this.notificationsEnabled = false,
    this.notificationHour = 20,
    this.notificationMinute = 0,
    this.customMessage,
    this.customIcon,
    this.customColor,
    this.displayOrder = 0,
  }) : tags = tags ?? [];

  // Para JSON (usado por widget y exportación)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'streak': streak,
        'lastCompleted': lastCompleted?.toIso8601String(),
        'nextProtectorAvailable': nextProtectorAvailable?.toIso8601String(),
        'active': active,
        'protectorUsed': protectorUsed,
        'categoryId': categoryId,
        'tags': tags,
        'notificationsEnabled': notificationsEnabled,
        'notificationHour': notificationHour,
        'notificationMinute': notificationMinute,
        'customMessage': customMessage,
        'customIcon': customIcon,
        'customColor': customColor,
        'displayOrder': displayOrder,
      };

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'],
      name: json['name'],
      streak: json['streak'] ?? 0,
      lastCompleted: json['lastCompleted'] != null
          ? DateTime.parse(json['lastCompleted'])
          : null,
      nextProtectorAvailable: json['nextProtectorAvailable'] != null
          ? DateTime.parse(json['nextProtectorAvailable'])
          : null,
      active: json['active'] ?? true,
      protectorUsed: json['protectorUsed'] ?? false,
      categoryId: json['categoryId'],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      notificationsEnabled: json['notificationsEnabled'] ?? false,
      notificationHour: json['notificationHour'] ?? 20,
      notificationMinute: json['notificationMinute'] ?? 0,
      customMessage: json['customMessage'],
      customIcon: json['customIcon'],
      customColor: json['customColor'],
      displayOrder: json['displayOrder'] ?? 0,
    );
  }

  // Para SQLite (almacenamiento local)
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'streak': streak,
        'lastCompleted': lastCompleted?.toIso8601String(),
        'nextProtectorAvailable': nextProtectorAvailable?.toIso8601String(),
        'active': active ? 1 : 0, // SQLite usa INTEGER para booleanos
        'protectorUsed': protectorUsed ? 1 : 0,
        'categoryId': categoryId,
        'tags': jsonEncode(tags), // Guardar tags como JSON string
        'notificationsEnabled': notificationsEnabled ? 1 : 0,
        'notificationHour': notificationHour,
        'notificationMinute': notificationMinute,
        'customMessage': customMessage,
        'customIcon': customIcon,
        'customColor': customColor,
        'displayOrder': displayOrder,
      };

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      name: map['name'],
      streak: map['streak'] ?? 0,
      lastCompleted: map['lastCompleted'] != null
          ? DateTime.parse(map['lastCompleted'])
          : null,
      nextProtectorAvailable: map['nextProtectorAvailable'] != null
          ? DateTime.parse(map['nextProtectorAvailable'])
          : null,
      active: map['active'] == 1, // Convertir INTEGER a bool
      protectorUsed: map['protectorUsed'] == 1,
      categoryId: map['categoryId'],
      tags:
          map['tags'] != null ? List<String>.from(jsonDecode(map['tags'])) : [],
      notificationsEnabled: map['notificationsEnabled'] == 1,
      notificationHour: map['notificationHour'] ?? 20,
      notificationMinute: map['notificationMinute'] ?? 0,
      customMessage: map['customMessage'],
      customIcon: map['customIcon'],
      customColor: map['customColor'],
      displayOrder: map['displayOrder'] ?? 0,
    );
  }
}
