import '../models/activity.dart';
import '../models/category.dart';
import 'database_helper.dart';

/// Servicio para gestionar las categorías
class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  factory CategoryService() => _instance;
  CategoryService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Obtener todas las categorías
  Future<List<Category>> getAllCategories() async {
    return await _dbHelper.getAllCategories();
  }

  /// Obtener una categoría por ID
  Future<Category?> getCategory(String id) async {
    return await _dbHelper.getCategory(id);
  }

  /// Agregar una nueva categoría
  Future<void> addCategory(Category category) async {
    await _dbHelper.insertCategory(category);
  }

  /// Actualizar una categoría existente
  Future<void> updateCategory(Category category) async {
    await _dbHelper.updateCategory(category);
  }

  /// Eliminar una categoría
  /// Las actividades asociadas perderán su referencia de categoría
  Future<void> deleteCategory(String id) async {
    await _dbHelper.deleteCategory(id);
  }

  /// Asegurar que las categorías predeterminadas existan
  Future<void> ensureDefaultCategories() async {
    final categories = await getAllCategories();
    if (categories.isEmpty) {
      // Si no hay categorías, insertar las predeterminadas
      for (final category in PredefinedCategories.defaults) {
        await addCategory(category);
      }
    }
  }

  /// Obtener categorías más usadas (por cantidad de actividades)
  Future<List<Map<String, dynamic>>> getMostUsedCategories() async {
    final categories = await getAllCategories();
    final List<Map<String, dynamic>> categoryUsage = [];

    for (final category in categories) {
      final activities = await _dbHelper.getActivitiesByCategory(category.id);
      categoryUsage.add({
        'category': category,
        'count': activities.length,
      });
    }

    // Ordenar por uso descendente
    categoryUsage
        .sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return categoryUsage;
  }

  /// Obtener actividades por categoría
  Future<List<Activity>> getActivitiesByCategory(String categoryId) async {
    return await _dbHelper.getActivitiesByCategory(categoryId);
  }
}
