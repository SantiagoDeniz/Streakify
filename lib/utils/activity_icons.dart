import 'package:flutter/material.dart';

/// Iconos predefinidos para actividades
class ActivityIcons {
  static const Map<String, IconData> icons = {
    // Fitness y Salud
    'fitness_center': Icons.fitness_center,
    'directions_run': Icons.directions_run,
    'directions_walk': Icons.directions_walk,
    'directions_bike': Icons.directions_bike,
    'pool': Icons.pool,
    'sports_soccer': Icons.sports_soccer,
    'sports_basketball': Icons.sports_basketball,
    'sports_tennis': Icons.sports_tennis,
    'self_improvement': Icons.self_improvement, // Yoga/Meditación
    'spa': Icons.spa,
    'favorite': Icons.favorite, // Salud
    'local_hospital': Icons.local_hospital,
    'medication': Icons.medication,

    // Alimentación
    'restaurant': Icons.restaurant,
    'local_dining': Icons.local_dining,
    'local_cafe': Icons.local_cafe,
    'water_drop': Icons.water_drop,
    'no_drinks': Icons.no_drinks, // No alcohol
    'set_meal': Icons.set_meal,
    'apple': Icons.apple,

    // Educación y Trabajo
    'book': Icons.book,
    'menu_book': Icons.menu_book,
    'school': Icons.school,
    'work': Icons.work,
    'laptop': Icons.laptop,
    'edit_note': Icons.edit_note,
    'assignment': Icons.assignment,
    'calculate': Icons.calculate,
    'code': Icons.code,
    'science': Icons.science,
    'language': Icons.language,

    // Creatividad y Hobbies
    'brush': Icons.brush,
    'palette': Icons.palette,
    'music_note': Icons.music_note,
    'piano': Icons.piano,
    'camera_alt': Icons.camera_alt,
    'photo_camera': Icons.photo_camera,
    'videocam': Icons.videocam,
    'theater_comedy': Icons.theater_comedy,
    'draw': Icons.draw,

    // Social y Relaciones
    'people': Icons.people,
    'person': Icons.person,
    'family_restroom': Icons.family_restroom,
    'call': Icons.call,
    'chat': Icons.chat,
    'forum': Icons.forum,
    'volunteer_activism': Icons.volunteer_activism,

    // Casa y Organización
    'home': Icons.home,
    'cleaning_services': Icons.cleaning_services,
    'shopping_cart': Icons.shopping_cart,
    'kitchen': Icons.kitchen,
    'checkroom': Icons.checkroom, // Organizar ropa
    'inventory': Icons.inventory,
    'business_center': Icons.business_center,

    // Finanzas
    'savings': Icons.savings,
    'account_balance_wallet': Icons.account_balance_wallet,
    'attach_money': Icons.attach_money,
    'paid': Icons.paid,
    'receipt_long': Icons.receipt_long,

    // Espiritualidad y Reflexión
    'auto_stories': Icons.auto_stories, // Diario/Journal
    'lightbulb': Icons.lightbulb,
    'psychology': Icons.psychology,
    'church': Icons.church,
    'emoji_objects': Icons.emoji_objects, // Ideas

    // Hábitos Digitales
    'phone_android': Icons.phone_android,
    'smartphone': Icons.smartphone,
    'computer': Icons.computer,
    'tv': Icons.tv,
    'videogame_asset': Icons.videogame_asset,
    'wifi_off': Icons.wifi_off, // Detox digital

    // Naturaleza y Exterior
    'park': Icons.park,
    'nature': Icons.nature,
    'eco': Icons.eco,
    'yard': Icons.yard,
    'pets': Icons.pets,
    'wb_sunny': Icons.wb_sunny, // Tomar sol

    // Tiempo y Productividad
    'access_time': Icons.access_time,
    'alarm': Icons.alarm,
    'schedule': Icons.schedule,
    'timer': Icons.timer,
    'today': Icons.today,
    'event': Icons.event,

    // Misceláneo
    'star': Icons.star,
    'emoji_events': Icons.emoji_events,
    'workspace_premium': Icons.workspace_premium,
    'local_fire_department': Icons.local_fire_department,
    'celebration': Icons.celebration,
    'nightlight': Icons.nightlight, // Dormir temprano
    'bed': Icons.bed,
  };

  static IconData getIcon(String? iconName) {
    if (iconName == null) return Icons.check_circle_outline;
    return icons[iconName] ?? Icons.check_circle_outline;
  }

  static List<MapEntry<String, IconData>> get iconsList =>
      icons.entries.toList();
}

/// Colores predefinidos para actividades
class ActivityColors {
  static const Map<String, Color> colors = {
    'red': Colors.red,
    'pink': Colors.pink,
    'purple': Colors.purple,
    'deepPurple': Colors.deepPurple,
    'indigo': Colors.indigo,
    'blue': Colors.blue,
    'lightBlue': Colors.lightBlue,
    'cyan': Colors.cyan,
    'teal': Colors.teal,
    'green': Colors.green,
    'lightGreen': Colors.lightGreen,
    'lime': Colors.lime,
    'yellow': Colors.yellow,
    'amber': Colors.amber,
    'orange': Colors.orange,
    'deepOrange': Colors.deepOrange,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'blueGrey': Colors.blueGrey,
  };

  static Color getColor(String? colorName) {
    if (colorName == null) return Colors.blue;

    // Si es un color hex
    if (colorName.startsWith('#')) {
      try {
        return Color(int.parse(colorName.substring(1), radix: 16) + 0xFF000000);
      } catch (e) {
        return Colors.blue;
      }
    }

    return colors[colorName] ?? Colors.blue;
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  static List<MapEntry<String, Color>> get colorsList =>
      colors.entries.toList();
}
