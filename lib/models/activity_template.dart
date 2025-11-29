import 'activity.dart';

/// Plantilla predefinida de actividad
class ActivityTemplate {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String colorHex;
  final String categoryId;
  final List<String> suggestedTags;
  final RecurrenceType defaultRecurrence;
  final int? defaultTargetDays;

  const ActivityTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorHex,
    required this.categoryId,
    this.suggestedTags = const [],
    this.defaultRecurrence = RecurrenceType.daily,
    this.defaultTargetDays,
  });

  /// Lista de plantillas predefinidas
  static List<ActivityTemplate> get predefinedTemplates => [
        // Salud y Fitness
        const ActivityTemplate(
          id: 'template_exercise',
          name: 'Ejercicio',
          description: 'Rutina de ejercicio físico diario',
          iconName: 'fitness_center',
          colorHex: '#FF5722',
          categoryId: 'health',
          suggestedTags: ['salud', 'fitness'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 30,
        ),
        const ActivityTemplate(
          id: 'template_water',
          name: 'Tomar agua',
          description: '8 vasos de agua al día',
          iconName: 'water_drop',
          colorHex: '#2196F3',
          categoryId: 'health',
          suggestedTags: ['salud', 'hidratación'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 21,
        ),
        const ActivityTemplate(
          id: 'template_meditation',
          name: 'Meditación',
          description: '10 minutos de meditación',
          iconName: 'self_improvement',
          colorHex: '#9C27B0',
          categoryId: 'health',
          suggestedTags: ['mindfulness', 'bienestar'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 30,
        ),
        const ActivityTemplate(
          id: 'template_sleep',
          name: 'Dormir 8 horas',
          description: 'Descanso adecuado cada noche',
          iconName: 'bedtime',
          colorHex: '#3F51B5',
          categoryId: 'health',
          suggestedTags: ['salud', 'descanso'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 30,
        ),
        const ActivityTemplate(
          id: 'template_vitamins',
          name: 'Tomar vitaminas',
          description: 'Suplementos diarios',
          iconName: 'medication',
          colorHex: '#FF9800',
          categoryId: 'health',
          suggestedTags: ['salud'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 90,
        ),

        // Productividad
        const ActivityTemplate(
          id: 'template_reading',
          name: 'Leer',
          description: '30 minutos de lectura',
          iconName: 'book',
          colorHex: '#795548',
          categoryId: 'productivity',
          suggestedTags: ['aprendizaje', 'lectura'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 365,
        ),
        const ActivityTemplate(
          id: 'template_study',
          name: 'Estudiar',
          description: 'Sesión de estudio',
          iconName: 'school',
          colorHex: '#4CAF50',
          categoryId: 'productivity',
          suggestedTags: ['aprendizaje', 'educación'],
          defaultRecurrence: RecurrenceType.weekdays,
          defaultTargetDays: 100,
        ),
        const ActivityTemplate(
          id: 'template_practice',
          name: 'Practicar instrumento',
          description: 'Sesión de práctica musical',
          iconName: 'music_note',
          colorHex: '#E91E63',
          categoryId: 'hobbies',
          suggestedTags: ['música', 'práctica'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 100,
        ),
        const ActivityTemplate(
          id: 'template_coding',
          name: 'Programar',
          description: 'Práctica de programación',
          iconName: 'code',
          colorHex: '#00BCD4',
          categoryId: 'productivity',
          suggestedTags: ['código', 'desarrollo'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 100,
        ),
        const ActivityTemplate(
          id: 'template_journal',
          name: 'Diario personal',
          description: 'Escribir en el diario',
          iconName: 'edit_note',
          colorHex: '#FF6F00',
          categoryId: 'personal',
          suggestedTags: ['escritura', 'reflexión'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 30,
        ),

        // Social y Familia
        const ActivityTemplate(
          id: 'template_family',
          name: 'Tiempo en familia',
          description: 'Calidad con la familia',
          iconName: 'family_restroom',
          colorHex: '#FF5252',
          categoryId: 'social',
          suggestedTags: ['familia', 'social'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 30,
        ),
        const ActivityTemplate(
          id: 'template_friends',
          name: 'Llamar a un amigo',
          description: 'Mantener conexiones sociales',
          iconName: 'phone',
          colorHex: '#4CAF50',
          categoryId: 'social',
          suggestedTags: ['social', 'amistad'],
          defaultRecurrence: RecurrenceType.specificDays,
          defaultTargetDays: 52,
        ),

        // Finanzas
        const ActivityTemplate(
          id: 'template_budget',
          name: 'Revisar gastos',
          description: 'Control de presupuesto',
          iconName: 'account_balance_wallet',
          colorHex: '#4CAF50',
          categoryId: 'finance',
          suggestedTags: ['finanzas', 'ahorro'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 30,
        ),
        const ActivityTemplate(
          id: 'template_save',
          name: 'Ahorrar',
          description: 'Guardar dinero para meta',
          iconName: 'savings',
          colorHex: '#FFC107',
          categoryId: 'finance',
          suggestedTags: ['finanzas', 'ahorro'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 365,
        ),

        // Hogar
        const ActivityTemplate(
          id: 'template_cleaning',
          name: 'Limpieza',
          description: 'Mantener espacio ordenado',
          iconName: 'cleaning_services',
          colorHex: '#00BCD4',
          categoryId: 'home',
          suggestedTags: ['hogar', 'orden'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 30,
        ),
        const ActivityTemplate(
          id: 'template_plants',
          name: 'Regar plantas',
          description: 'Cuidado de plantas',
          iconName: 'local_florist',
          colorHex: '#4CAF50',
          categoryId: 'home',
          suggestedTags: ['hogar', 'plantas'],
          defaultRecurrence: RecurrenceType.specificDays,
          defaultTargetDays: 90,
        ),

        // Desarrollo Personal
        const ActivityTemplate(
          id: 'template_gratitude',
          name: 'Gratitud',
          description: 'Anotar 3 cosas por las que estás agradecido',
          iconName: 'favorite',
          colorHex: '#E91E63',
          categoryId: 'personal',
          suggestedTags: ['gratitud', 'mindfulness'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 30,
        ),
        const ActivityTemplate(
          id: 'template_learning',
          name: 'Aprender algo nuevo',
          description: 'Curso online o tutorial',
          iconName: 'lightbulb',
          colorHex: '#FFC107',
          categoryId: 'productivity',
          suggestedTags: ['aprendizaje', 'desarrollo'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 100,
        ),
        const ActivityTemplate(
          id: 'template_no_phone',
          name: 'Sin teléfono 1 hora',
          description: 'Desconexión digital',
          iconName: 'phone_disabled',
          colorHex: '#607D8B',
          categoryId: 'personal',
          suggestedTags: ['detox', 'mindfulness'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 21,
        ),

        // Creatividad
        const ActivityTemplate(
          id: 'template_drawing',
          name: 'Dibujar',
          description: 'Práctica de dibujo o arte',
          iconName: 'brush',
          colorHex: '#9C27B0',
          categoryId: 'hobbies',
          suggestedTags: ['arte', 'creatividad'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 100,
        ),
        const ActivityTemplate(
          id: 'template_writing',
          name: 'Escribir',
          description: 'Escritura creativa',
          iconName: 'create',
          colorHex: '#673AB7',
          categoryId: 'hobbies',
          suggestedTags: ['escritura', 'creatividad'],
          defaultRecurrence: RecurrenceType.daily,
          defaultTargetDays: 100,
        ),
      ];

  /// Buscar plantillas por categoría
  static List<ActivityTemplate> getTemplatesByCategory(String categoryId) {
    return predefinedTemplates
        .where((template) => template.categoryId == categoryId)
        .toList();
  }

  /// Buscar plantilla por ID
  static ActivityTemplate? getTemplateById(String id) {
    try {
      return predefinedTemplates.firstWhere((template) => template.id == id);
    } catch (e) {
      return null;
    }
  }
}
