import 'dart:math';

class MotivationService {
  final List<String> _quotes = [
    "El éxito es la suma de pequeños esfuerzos repetidos día tras día. - Robert Collier",
    "No cuentes los días, haz que los días cuenten. - Muhammad Ali",
    "La disciplina es el puente entre metas y logros. - Jim Rohn",
    "Somos lo que hacemos repetidamente. La excelencia, entonces, no es un acto, sino un hábito. - Aristóteles",
    "El secreto de tu futuro está escondido en tu rutina diaria. - Mike Murdock",
    "No necesitas ser grande para empezar, pero necesitas empezar para ser grande. - Zig Ziglar",
    "La motivación es lo que te pone en marcha. El hábito es lo que hace que sigas. - Jim Ryun",
  ];

  final List<String> _tips = [
    "Empieza pequeño: Es mejor hacer 5 minutos de ejercicio que nada.",
    "Prepara tu entorno: Deja tu ropa de gimnasio lista la noche anterior.",
    "Usa la regla de los 2 minutos: Si te lleva menos de 2 minutos, hazlo ahora.",
    "No rompas la cadena: Visualiza tu progreso en el calendario.",
    "Celebra las pequeñas victorias: Date una recompensa al completar una semana.",
  ];

  String getDailyQuote() {
    final random = Random();
    // In a real app, this could be seeded by the date to be consistent throughout the day
    final dayOfYear = int.parse("${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}");
    final seed = Random(dayOfYear);
    return _quotes[seed.nextInt(_quotes.length)];
  }

  String getRandomTip() {
    final random = Random();
    return _tips[random.nextInt(_tips.length)];
  }

  Map<String, String> getCommunityStory() {
    return {
      "title": "Cómo Juan recuperó su salud",
      "author": "Juan P.",
      "content": "Empecé caminando 10 minutos al día. Al principio fue difícil, pero después de 21 días se convirtió en algo que mi cuerpo pedía. Ahora corro maratones.",
    };
  }
  
  Map<String, dynamic> getMonthlyChallenge() {
    final now = DateTime.now();
    // Example logic for monthly challenges
    return {
      "title": "Reto de ${now.month == 1 ? 'Enero' : 'Mes'}",
      "description": "Completa 20 días de cualquier actividad de salud este mes.",
      "target": 20,
      "reward": "Medalla de Bronce",
    };
  }
}
