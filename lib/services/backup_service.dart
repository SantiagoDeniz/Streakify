import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:excel/excel.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
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

  /// Exporta actividades a formato CSV
  Future<File> exportToCSV() async {
    final activities = await _activityService.loadActivities();
    final categories = await _categoryService.getAllCategories();
    
    // Crear mapa de categorías para búsqueda rápida
    final categoryMap = {for (var c in categories) c.id: c.name};
    
    // Crear filas CSV
    List<List<dynamic>> rows = [];
    
    // Encabezados
    rows.add([
      'ID',
      'Nombre',
      'Racha',
      'Última Completación',
      'Activa',
      'Categoría',
      'Tags',
      'Recurrencia',
      'Meta de Días',
      'Archivada',
      'Congelada',
      'Puntos de Racha',
    ]);
    
    // Datos de actividades
    for (final activity in activities) {
      rows.add([
        activity.id,
        activity.name,
        activity.streak,
        activity.lastCompleted?.toIso8601String() ?? '',
        activity.active ? 'Sí' : 'No',
        activity.categoryId != null ? categoryMap[activity.categoryId] ?? '' : '',
        activity.tags.join('; '),
        activity.getRecurrenceDescription(),
        activity.targetDays?.toString() ?? '',
        activity.isArchived ? 'Sí' : 'No',
        activity.isCurrentlyFrozen() ? 'Sí' : 'No',
        activity.streakPoints,
      ]);
    }
    
    // Convertir a CSV
    String csv = const ListToCsvConverter().convert(rows);
    
    // Guardar archivo
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'streakify_export_$timestamp.csv';
    
    final backupDir = await _getBackupDirectory();
    final file = File('${backupDir.path}/$fileName');
    await file.writeAsString(csv);
    
    return file;
  }

  /// Exporta datos a formato Excel con múltiples hojas
  Future<File> exportToExcel() async {
    final activities = await _activityService.loadActivities();
    final categories = await _categoryService.getAllCategories();
    
    var excel = Excel.createExcel();
    
    // Eliminar hoja por defecto
    excel.delete('Sheet1');
    
    // === HOJA 1: ACTIVIDADES ===
    var activitiesSheet = excel['Actividades'];
    
    // Encabezados
    activitiesSheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nombre'),
      IntCellValue(0), // Placeholder para "Racha"
      TextCellValue('Última Completación'),
      TextCellValue('Activa'),
      TextCellValue('Categoría ID'),
      TextCellValue('Tags'),
      TextCellValue('Recurrencia'),
      TextCellValue('Meta de Días'),
      TextCellValue('Archivada'),
      TextCellValue('Congelada'),
      IntCellValue(0), // Placeholder para "Puntos"
    ]);
    
    // Reemplazar el placeholder de "Racha" con el texto correcto
    activitiesSheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Racha');
    activitiesSheet.cell(CellIndex.indexByString('L1')).value = TextCellValue('Puntos de Racha');
    
    // Datos
    for (final activity in activities) {
      activitiesSheet.appendRow([
        TextCellValue(activity.id),
        TextCellValue(activity.name),
        IntCellValue(activity.streak),
        TextCellValue(activity.lastCompleted?.toIso8601String() ?? ''),
        TextCellValue(activity.active ? 'Sí' : 'No'),
        TextCellValue(activity.categoryId ?? ''),
        TextCellValue(activity.tags.join('; ')),
        TextCellValue(activity.getRecurrenceDescription()),
        TextCellValue(activity.targetDays?.toString() ?? ''),
        TextCellValue(activity.isArchived ? 'Sí' : 'No'),
        TextCellValue(activity.isCurrentlyFrozen() ? 'Sí' : 'No'),
        IntCellValue(activity.streakPoints),
      ]);
    }
    
    // === HOJA 2: CATEGORÍAS ===
    var categoriesSheet = excel['Categorías'];
    
    categoriesSheet.appendRow([
      TextCellValue('ID'),
      TextCellValue('Nombre'),
      TextCellValue('Icono'),
      TextCellValue('Color'),
    ]);
    
    for (final category in categories) {
      categoriesSheet.appendRow([
        TextCellValue(category.id),
        TextCellValue(category.name),
        TextCellValue(category.icon.codePoint.toString()),
        TextCellValue(category.color.value.toRadixString(16)),
      ]);
    }
    
    // === HOJA 3: ESTADÍSTICAS ===
    var statsSheet = excel['Estadísticas'];
    
    final totalActivities = activities.length;
    final activeActivities = activities.where((a) => a.active).length;
    final archivedActivities = activities.where((a) => a.isArchived).length;
    final longestStreak = activities.isEmpty
        ? 0
        : activities.map((a) => a.streak).reduce((a, b) => a > b ? a : b);
    final totalStreakPoints = activities.fold(0, (sum, a) => sum + a.streakPoints);
    
    statsSheet.appendRow([TextCellValue('Métrica'), TextCellValue('Valor')]);
    statsSheet.appendRow([TextCellValue('Total de Actividades'), IntCellValue(totalActivities)]);
    statsSheet.appendRow([TextCellValue('Actividades Activas'), IntCellValue(activeActivities)]);
    statsSheet.appendRow([TextCellValue('Actividades Archivadas'), IntCellValue(archivedActivities)]);
    statsSheet.appendRow([TextCellValue('Racha Más Larga'), IntCellValue(longestStreak)]);
    statsSheet.appendRow([TextCellValue('Total Puntos de Racha'), IntCellValue(totalStreakPoints)]);
    statsSheet.appendRow([TextCellValue('Total de Categorías'), IntCellValue(categories.length)]);
    statsSheet.appendRow([TextCellValue('Fecha de Exportación'), TextCellValue(DateTime.now().toIso8601String())]);
    
    // Guardar archivo
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'streakify_export_$timestamp.xlsx';
    
    final backupDir = await _getBackupDirectory();
    final file = File('${backupDir.path}/$fileName');
    
    final bytes = excel.encode();
    if (bytes != null) {
      await file.writeAsBytes(bytes);
    }
    
    return file;
  }

  /// Exporta datos a archivo JSON cifrado
  Future<File> exportToFileEncrypted(String password) async {
    final data = await exportToJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(data);
    
    // Generar clave desde password
    final key = encrypt.Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
    final iv = encrypt.IV.fromLength(16);
    
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(jsonString, iv: iv);
    
    // Crear objeto con datos cifrados e IV
    final encryptedData = {
      'encrypted': encrypted.base64,
      'iv': iv.base64,
      'version': '1.0',
      'appName': 'Streakify',
    };
    
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'streakify_backup_encrypted_$timestamp.json';
    
    final backupDir = await _getBackupDirectory();
    final file = File('${backupDir.path}/$fileName');
    
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(encryptedData),
    );
    
    return file;
  }

  /// Importa datos desde archivo JSON cifrado
  Future<bool> importFromFileEncrypted(File file, String password) async {
    try {
      final content = await file.readAsString();
      final encryptedData = jsonDecode(content) as Map<String, dynamic>;
      
      if (!encryptedData.containsKey('encrypted') || !encryptedData.containsKey('iv')) {
        throw Exception('Formato de backup cifrado inválido');
      }
      
      // Generar clave desde password
      final key = encrypt.Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
      final iv = encrypt.IV.fromBase64(encryptedData['iv']);
      
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypt.Encrypted.fromBase64(encryptedData['encrypted']);
      
      // Descifrar
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      final data = jsonDecode(decrypted) as Map<String, dynamic>;
      
      // Importar datos descifrados
      return await importFromJson(data, merge: false);
    } catch (e) {
      print('Error al importar backup cifrado: $e');
      return false;
    }
  }
}

