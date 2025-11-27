import '../models/faq_item.dart';

/// FAQ data for the help center
final List<FAQItem> faqData = [
  // Inicio
  const FAQItem(
    question: '¿Cómo creo una nueva actividad?',
    answer: 'Toca el botón + (flotante) en la pantalla principal. Luego ingresa el nombre de tu actividad, selecciona un icono y color, y configura la frecuencia deseada.',
    category: 'Inicio',
    tags: ['crear', 'actividad', 'nueva'],
  ),
  const FAQItem(
    question: '¿Qué es una racha?',
    answer: 'Una racha es el número de días consecutivos que has completado una actividad. Mientras más larga sea tu racha, ¡más motivado estarás para continuar!',
    category: 'Inicio',
    tags: ['racha', 'streak', 'días'],
  ),
  const FAQItem(
    question: '¿Cómo completo una actividad?',
    answer: 'Toca el botón de check (✓) en la tarjeta de la actividad. La actividad se marcará como completada para el día actual y tu racha aumentará.',
    category: 'Inicio',
    tags: ['completar', 'check', 'marcar'],
  ),

  // Actividades
  const FAQItem(
    question: '¿Puedo editar una actividad después de crearla?',
    answer: 'Sí, desliza la tarjeta de la actividad hacia la derecha y selecciona "Editar". Podrás cambiar el nombre, icono, color y configuración.',
    category: 'Actividades',
    tags: ['editar', 'modificar', 'cambiar'],
  ),
  const FAQItem(
    question: '¿Cómo elimino una actividad?',
    answer: 'Desliza la tarjeta de la actividad hacia la izquierda y confirma la eliminación. Ten cuidado, esta acción no se puede deshacer.',
    category: 'Actividades',
    tags: ['eliminar', 'borrar', 'delete'],
  ),
  const FAQItem(
    question: '¿Puedo pausar una actividad temporalmente?',
    answer: 'Sí, en el menú de edición de la actividad puedes marcarla como "Pausada". Esto la ocultará de la vista principal sin eliminar tu historial.',
    category: 'Actividades',
    tags: ['pausar', 'ocultar', 'desactivar'],
  ),
  const FAQItem(
    question: '¿Cuántas actividades puedo crear?',
    answer: 'En la versión gratuita puedes crear hasta 10 actividades. Con Streakify Premium, puedes crear actividades ilimitadas.',
    category: 'Actividades',
    tags: ['límite', 'máximo', 'premium'],
  ),

  // Rachas y Protectores
  const FAQItem(
    question: '¿Qué son los protectores de racha?',
    answer: 'Los protectores te permiten mantener tu racha activa incluso si olvidas completar una actividad un día. Son útiles para vacaciones o días ocupados.',
    category: 'Rachas',
    tags: ['protector', 'freeze', 'mantener'],
  ),
  const FAQItem(
    question: '¿Cómo uso un protector?',
    answer: 'Si olvidas completar una actividad, puedes usar un protector tocando el botón de protector en la tarjeta de la actividad. Esto mantendrá tu racha activa.',
    category: 'Rachas',
    tags: ['usar', 'protector', 'aplicar'],
  ),
  const FAQItem(
    question: '¿Cómo obtengo más protectores?',
    answer: 'Ganas protectores automáticamente al alcanzar ciertos hitos (7 días, 30 días, etc.). También puedes comprarlos en la tienda premium.',
    category: 'Rachas',
    tags: ['conseguir', 'ganar', 'protectores'],
  ),

  // Estadísticas
  const FAQItem(
    question: '¿Dónde veo mis estadísticas?',
    answer: 'Toca el ícono de gráfica en la barra inferior para ver tus estadísticas detalladas, incluyendo rachas, tendencias y logros.',
    category: 'Estadísticas',
    tags: ['ver', 'estadísticas', 'gráficas'],
  ),
  const FAQItem(
    question: '¿Qué es el heatmap?',
    answer: 'El heatmap es un calendario visual que muestra tu actividad a lo largo del año, similar al de GitHub. Los días más activos aparecen con colores más intensos.',
    category: 'Estadísticas',
    tags: ['heatmap', 'calendario', 'visual'],
  ),

  // Notificaciones
  const FAQItem(
    question: '¿Cómo configuro recordatorios?',
    answer: 'Ve a Configuración > Notificaciones. Ahí puedes configurar recordatorios personalizados para cada actividad.',
    category: 'Notificaciones',
    tags: ['recordatorios', 'notificaciones', 'alarmas'],
  ),
  const FAQItem(
    question: '¿Por qué no recibo notificaciones?',
    answer: 'Verifica que hayas dado permisos de notificación a la app en la configuración de tu dispositivo. También revisa que las notificaciones estén activadas en la app.',
    category: 'Notificaciones',
    tags: ['no', 'recibo', 'permisos'],
  ),

  // Datos y Backup
  const FAQItem(
    question: '¿Cómo hago backup de mis datos?',
    answer: 'Ve a Configuración > Datos y Backup. Puedes exportar tus datos localmente o usar backup en la nube (Premium).',
    category: 'Datos',
    tags: ['backup', 'exportar', 'guardar'],
  ),
  const FAQItem(
    question: '¿Puedo exportar mis datos?',
    answer: 'Sí, con Streakify Premium puedes exportar tus datos en formato CSV o Excel desde Configuración > Datos y Backup.',
    category: 'Datos',
    tags: ['exportar', 'csv', 'excel'],
  ),

  // Premium
  const FAQItem(
    question: '¿Qué incluye Streakify Premium?',
    answer: 'Premium incluye: actividades ilimitadas, todos los temas, backup en la nube, estadísticas avanzadas, exportación de datos, widgets premium y sin anuncios.',
    category: 'Premium',
    tags: ['premium', 'características', 'beneficios'],
  ),
  const FAQItem(
    question: '¿Cómo cancelo mi suscripción?',
    answer: 'Puedes cancelar tu suscripción en cualquier momento desde la configuración de tu cuenta de Google Play o App Store. Mantendrás acceso hasta el final del período pagado.',
    category: 'Premium',
    tags: ['cancelar', 'suscripción', 'premium'],
  ),

  // Técnico
  const FAQItem(
    question: '¿La app funciona sin internet?',
    answer: 'Sí, Streakify funciona completamente offline. Solo necesitas internet para funciones premium como backup en la nube.',
    category: 'Técnico',
    tags: ['offline', 'internet', 'conexión'],
  ),
  const FAQItem(
    question: '¿En qué dispositivos funciona Streakify?',
    answer: 'Streakify funciona en Android 5.0+ e iOS 12.0+. También está optimizada para tablets.',
    category: 'Técnico',
    tags: ['dispositivos', 'compatibilidad', 'versión'],
  ),
];

/// Get FAQ categories
List<String> getFAQCategories() {
  return faqData.map((faq) => faq.category).toSet().toList()..sort();
}

/// Get FAQs by category
List<FAQItem> getFAQsByCategory(String category) {
  return faqData.where((faq) => faq.category == category).toList();
}

/// Search FAQs
List<FAQItem> searchFAQs(String query) {
  final lowerQuery = query.toLowerCase();
  return faqData.where((faq) {
    return faq.question.toLowerCase().contains(lowerQuery) ||
        faq.answer.toLowerCase().contains(lowerQuery) ||
        faq.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }).toList();
}
