import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../models/category.dart';
import 'activity_service.dart';
import 'category_service.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final ActivityService _activityService = ActivityService();
  final CategoryService _categoryService = CategoryService();

  /// Obtiene el directorio de backups
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Exporta todos los datos a un objeto JSON
  Future<Map<String, dynamic>> exportToJson() async {
    final activities = await _activityService.loadActivities();
    final categories = await _categoryService.getAllCategories();

    return {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'appName': 'Streakify',
      'data': {
        'activities': activities.map((a) => a.toJson()).toList(),
        'categories': categories.map((c) => c.toJson()).toList(),
      },
      'metadata': {
        'totalActivities': activities.length,
        'activeActivities': activities.where((a) => a.active).length,
        'totalCategories': categories.length,
        'longestStreak': activities.isEmpty
            ? 0
            : activities.map((a) => a.streak).reduce((a, b) => a > b ? a : b),
      },
    };
  }

  /// Exporta los datos a un archivo JSON local
  Future<File> exportToFile({String? customName}) async {
    final data = await exportToJson();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = customName ?? 'streakify_backup_$timestamp.json';

    final backupDir = await _getBackupDirectory();
    final file = File('${backupDir.path}/$fileName');

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );

    return file;
  }

  /// Comparte el archivo de backup
  Future<void> shareBackup() async {
    final file = await exportToFile();
    final result = await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Backup de Streakify',
      text: 'Aquí está mi backup de datos de Streakify',
    );

    if (result.status == ShareResultStatus.success) {
      print('Backup compartido exitosamente');
    }
  }

  /// Importa datos desde un archivo JSON
  Future<bool> importFromFile(File file, {bool merge = false}) async {
    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      return await importFromJson(data, merge: merge);
    } catch (e) {
      print('Error al importar archivo: $e');
      return false;
    }
  }

  /// Importa datos desde un objeto JSON
  Future<bool> importFromJson(Map<String, dynamic> data,
      {bool merge = false}) async {
    try {
      // Validar estructura básica
      if (!data.containsKey('version') || !data.containsKey('data')) {
        throw Exception('Formato de backup inválido');
      }

      final backupData = data['data'] as Map<String, dynamic>;

      // Cargar actividades actuales si es merge
      List<Activity> currentActivities = [];
      if (merge) {
        currentActivities = await _activityService.loadActivities();
      }

      // Importar actividades
      if (backupData.containsKey('activities')) {
        final activitiesList = backupData['activities'] as List;
        final importedActivities =
            activitiesList.map((json) => Activity.fromJson(json)).toList();

        if (merge) {
          // Merge: agregar solo las que no existen (por ID)
          final existingIds = currentActivities.map((a) => a.id).toSet();
          final newActivities = importedActivities
              .where((a) => !existingIds.contains(a.id))
              .toList();
          currentActivities.addAll(newActivities);
          await _activityService.saveActivities(currentActivities);
        } else {
          // Replace: reemplazar todo
          await _activityService.saveActivities(importedActivities);
        }
      }

      // Importar categorías (solo si es replace, o si no existen en merge)
      if (backupData.containsKey('categories')) {
        final categoriesList = backupData['categories'] as List;
        final importedCategories =
            categoriesList.map((json) => Category.fromJson(json)).toList();

        if (!merge) {
          // En replace, guardamos todas las categorías
          for (final category in importedCategories) {
            await _categoryService.addCategory(category);
          }
        } else {
          // En merge, solo agregamos las que no existen
          final existingCategories = await _categoryService.getAllCategories();
          final existingIds = existingCategories.map((c) => c.id).toSet();

          for (final category in importedCategories) {
            if (!existingIds.contains(category.id)) {
              await _categoryService.addCategory(category);
            }
          }
        }
      }

      return true;
    } catch (e) {
      print('Error al importar datos: $e');
      return false;
    }
  }

  /// Crea un backup automático
  Future<File> createAutoBackup() async {
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    return await exportToFile(customName: 'auto_backup_$timestamp.json');
  }

  /// Lista todos los backups locales
  Future<List<File>> listBackups() async {
    final backupDir = await _getBackupDirectory();
    final files = await backupDir.list().toList();

    final backupFiles =
        files.whereType<File>().where((f) => f.path.endsWith('.json')).toList();

    // Ordenar por fecha de modificación (más reciente primero)
    backupFiles
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    return backupFiles;
  }

  /// Elimina un backup específico
  Future<void> deleteBackup(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Mantiene solo los últimos N backups automáticos
  Future<void> cleanupOldBackups({int keepLast = 5}) async {
    final backups = await listBackups();
    final autoBackups =
        backups.where((f) => f.path.contains('auto_backup')).toList();

    if (autoBackups.length > keepLast) {
      final toDelete = autoBackups.sublist(keepLast);
      for (final backup in toDelete) {
        await deleteBackup(backup);
      }
    }
  }

  /// Obtiene información de un archivo de backup
  Future<Map<String, dynamic>?> getBackupInfo(File file) async {
    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      return {
        'fileName': file.path.split('/').last,
        'filePath': file.path,
        'fileSize': await file.length(),
        'fileDate': file.statSync().modified,
        'exportDate': data['exportDate'],
        'version': data['version'],
        'metadata': data['metadata'],
      };
    } catch (e) {
      print('Error al leer info del backup: $e');
      return null;
    }
  }

  /// Verifica si debe crear un backup automático
  Future<bool> shouldCreateAutoBackup() async {
    final backups = await listBackups();
    final autoBackups =
        backups.where((f) => f.path.contains('auto_backup')).toList();

    if (autoBackups.isEmpty) return true;

    // Verificar si el último backup es de hace más de 7 días
    final lastBackup = autoBackups.first;
    final lastBackupDate = lastBackup.statSync().modified;
    final daysSinceLastBackup =
        DateTime.now().difference(lastBackupDate).inDays;

    return daysSinceLastBackup >= 7;
  }

  /// Crea backup automático si es necesario
  Future<void> checkAndCreateAutoBackup() async {
    if (await shouldCreateAutoBackup()) {
      await createAutoBackup();
      await cleanupOldBackups();
    }
  }
}
