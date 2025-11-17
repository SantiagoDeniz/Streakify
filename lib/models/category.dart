import 'package:flutter/material.dart';

class Category {
  String id;
  String name;
  IconData icon;
  Color color;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  // Para JSON (exportación)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCodePoint': icon.codePoint,
        'colorValue': color.value,
      };

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      icon: IconData(json['iconCodePoint'], fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue']),
    );
  }

  // Para SQLite
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'iconCodePoint': icon.codePoint,
        'colorValue': color.value,
      };

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: IconData(map['iconCodePoint'], fontFamily: 'MaterialIcons'),
      color: Color(map['colorValue']),
    );
  }
}

// Categorías predefinidas
class PredefinedCategories {
  static final List<Category> defaults = [
    Category(
      id: 'health',
      name: 'Salud',
      icon: Icons.favorite,
      color: const Color(0xFFE91E63), // Rosa
    ),
    Category(
      id: 'fitness',
      name: 'Fitness',
      icon: Icons.fitness_center,
      color: const Color(0xFFFF6B35), // Naranja
    ),
    Category(
      id: 'productivity',
      name: 'Productividad',
      icon: Icons.work,
      color: const Color(0xFF2196F3), // Azul
    ),
    Category(
      id: 'learning',
      name: 'Aprendizaje',
      icon: Icons.school,
      color: const Color(0xFF9C27B0), // Púrpura
    ),
    Category(
      id: 'creativity',
      name: 'Creatividad',
      icon: Icons.palette,
      color: const Color(0xFFFF9800), // Naranja claro
    ),
    Category(
      id: 'social',
      name: 'Social',
      icon: Icons.people,
      color: const Color(0xFF4CAF50), // Verde
    ),
    Category(
      id: 'mindfulness',
      name: 'Mindfulness',
      icon: Icons.spa,
      color: const Color(0xFF00BCD4), // Cyan
    ),
    Category(
      id: 'habits',
      name: 'Hábitos',
      icon: Icons.check_circle,
      color: const Color(0xFF795548), // Marrón
    ),
    Category(
      id: 'finance',
      name: 'Finanzas',
      icon: Icons.attach_money,
      color: const Color(0xFF4CAF50), // Verde dinero
    ),
    Category(
      id: 'home',
      name: 'Hogar',
      icon: Icons.home,
      color: const Color(0xFF607D8B), // Gris azulado
    ),
    Category(
      id: 'other',
      name: 'Otros',
      icon: Icons.category,
      color: const Color(0xFF9E9E9E), // Gris
    ),
  ];
}
