import 'dart:math';

/// Utilidad para obtener frases motivacionales aleatorias
class MotivationalQuotes {
  static final Random _random = Random();

  /// Lista de frases motivacionales en español
  static final List<String> _quotes = [
    // Perseverancia
    '🔥 La consistencia es la clave del éxito',
    '💪 Un día a la vez, un paso a la vez',
    '⭐ Los pequeños pasos llevan a grandes cambios',
    '🎯 El progreso es progreso, sin importar qué tan pequeño',
    '🌟 Cada día es una nueva oportunidad',
    '🚀 No te rindas, estás más cerca de lo que crees',
    '💎 Los hábitos forman el carácter',
    '🏆 La disciplina supera a la motivación',
    '✨ Hoy es el día perfecto para mejorar',
    '🌈 El éxito es la suma de pequeños esfuerzos repetidos',

    // Superación
    '💫 Eres más fuerte de lo que piensas',
    '🎪 Los límites solo existen en tu mente',
    '🌺 Cada racha comienza con un solo día',
    '🎨 Estás creando tu mejor versión',
    '🌸 El cambio comienza contigo',
    '🦋 Transforma tus hábitos, transforma tu vida',
    '🌻 Cree en ti mismo y todo es posible',
    '🎭 No busques la perfección, busca el progreso',
    '🎪 Tú decides quién quieres ser',
    '🌠 El único fracaso es no intentarlo',

    // Motivación diaria
    '☀️ ¡Hoy va a ser un gran día!',
    '🌅 Comienza el día con energía positiva',
    '⚡ Tienes el poder de hacer la diferencia',
    '🎯 Enfócate en lo que puedes controlar',
    '🔋 Recarga tu energía con buenos hábitos',
    '🎁 Cada día completado es un regalo para ti',
    '🌟 Brilla con tus logros de hoy',
    '🎊 Celebra cada pequeña victoria',
    '🎉 ¡Vas por buen camino!',
    '👏 Date crédito por llegar hasta aquí',

    // Hábitos
    '📚 Los hábitos son la arquitectura de la vida',
    '⏰ El mejor momento para empezar es ahora',
    '🔄 La repetición crea maestría',
    '📈 Mejora un 1% cada día',
    '🎯 Los objetivos se logran con acciones diarias',
    '🧩 Cada pieza cuenta en el rompecabezas del éxito',
    '🌱 Planta hoy, cosecha mañana',
    '🔨 Construye tu futuro con tus acciones de hoy',
    '📊 Mide tu progreso, no la perfección',
    '🎪 La práctica hace al maestro',

    // Resiliencia
    '🛡️ Los obstáculos son oportunidades disfrazadas',
    '🌊 Surfea las olas del cambio',
    '🏔️ Las montañas se escalan paso a paso',
    '🌪️ Después de la tormenta viene la calma',
    '🦅 Vuela alto, no mires atrás',
    '🌳 Las raíces profundas resisten cualquier tormenta',
    '💪 Lo que no te mata te hace más fuerte',
    '🎯 Enfócate en el objetivo, no en el obstáculo',
    '🚀 Los fracasos son peldaños hacia el éxito',
    '⚓ Mantente firme en tus propósitos',

    // Inspiración
    '✨ Sé la mejor versión de ti mismo',
    '🌟 Tu potencial es ilimitado',
    '💫 Crea la vida que deseas vivir',
    '🎨 Pinta tu futuro con colores brillantes',
    '🌈 Después de la lluvia siempre sale el sol',
    '🎪 La vida es lo que haces de ella',
    '🦄 Atrévete a ser extraordinario',
    '🌺 Florece donde estés plantado',
    '🎭 Escribe tu propia historia de éxito',
    '🌠 Alcanza las estrellas',
  ];

  /// Obtiene una frase motivacional aleatoria
  static String getRandomQuote() {
    return _quotes[_random.nextInt(_quotes.length)];
  }

  /// Obtiene una frase motivacional basada en el contexto
  static String getContextualQuote(QuoteContext context) {
    List<String> contextQuotes;

    switch (context) {
      case QuoteContext.perseverance:
        contextQuotes = _quotes.sublist(0, 10);
        break;
      case QuoteContext.achievement:
        contextQuotes = _quotes.sublist(10, 20);
        break;
      case QuoteContext.daily:
        contextQuotes = _quotes.sublist(20, 30);
        break;
      case QuoteContext.habits:
        contextQuotes = _quotes.sublist(30, 40);
        break;
      case QuoteContext.resilience:
        contextQuotes = _quotes.sublist(40, 50);
        break;
      case QuoteContext.inspiration:
        contextQuotes = _quotes.sublist(50, 60);
        break;
    }

    return contextQuotes[_random.nextInt(contextQuotes.length)];
  }

  /// Obtiene múltiples frases aleatorias únicas
  static List<String> getMultipleQuotes(int count) {
    final shuffled = List<String>.from(_quotes)..shuffle(_random);
    return shuffled.take(count.clamp(1, _quotes.length)).toList();
  }

  /// Obtiene el total de frases disponibles
  static int get totalQuotes => _quotes.length;
}

/// Contextos para frases motivacionales
enum QuoteContext {
  perseverance, // Perseverancia
  achievement, // Logros
  daily, // Motivación diaria
  habits, // Hábitos
  resilience, // Resiliencia
  inspiration, // Inspiración
}
