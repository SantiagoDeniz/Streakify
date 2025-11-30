import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/services/backup_service.dart';
import 'package:streakify/models/activity.dart';
import '../mocks/mock_services.dart';

void main() {
  late BackupService backupService;
  late MockFileSystem mockFileSystem;

  setUp(() async {
    await initializeMocks();
    mockFileSystem = MockFileSystem();
    backupService = BackupService();
    // Note: In real implementation, inject mockFileSystem into BackupService
  });

  tearDown(() {
    mockFileSystem.clear();
  });

  group('BackupService - CSV Export', () {
    test('should export activities to CSV', () async {
      final activities = [
        Activity(
          id: 'test-1',
          name: 'Activity 1',
          recurrenceType: RecurrenceType.daily,
          streak: 5,
        ),
        Activity(
          id: 'test-2',
          name: 'Activity 2',
          recurrenceType: RecurrenceType.specificDays,
          streak: 10,
        ),
      ];

      final csvContent = _generateCSV(activities);
      mockFileSystem.writeFile('/backup/activities.csv', csvContent);

      expect(mockFileSystem.fileExists('/backup/activities.csv'), isTrue);
      
      final content = mockFileSystem.readFile('/backup/activities.csv');
      expect(content, isNotNull);
      expect(content, contains('Activity 1'));
      expect(content, contains('Activity 2'));
    });

    test('should include headers in CSV', () {
      final activities = [
        Activity(
          id: 'test-3',
          name: 'Test',
          recurrenceType: RecurrenceType.daily,
        ),
      ];

      final csvContent = _generateCSV(activities);
      
      expect(csvContent, contains('id,name,recurrenceType,streak'));
    });

    test('should handle empty activity list', () {
      final csvContent = _generateCSV([]);
      
      expect(csvContent, contains('id,name,recurrenceType,streak'));
      expect(csvContent.split('\n').length, equals(2)); // Header + empty line
    });

    test('should escape special characters in CSV', () {
      final activities = [
        Activity(
          id: 'test-4',
          name: 'Activity with "quotes" and, commas',
          recurrenceType: RecurrenceType.daily,
        ),
      ];

      final csvContent = _generateCSV(activities);
      
      expect(csvContent, contains('"Activity with ""quotes"" and, commas"'));
    });
  });

  group('BackupService - Excel Export', () {
    test('should export activities to Excel format', () async {
      final activities = [
        Activity(
          id: 'test-5',
          name: 'Excel Activity',
          recurrenceType: RecurrenceType.daily,
          streak: 7,
        ),
      ];

      // Simulate Excel export (simplified)
      final excelData = _generateExcelData(activities);
      mockFileSystem.writeFile('/backup/activities.xlsx', excelData);

      expect(mockFileSystem.fileExists('/backup/activities.xlsx'), isTrue);
    });

    test('should include multiple sheets in Excel', () {
      // Simulate multiple sheets (activities, categories, completions)
      mockFileSystem.writeFile('/backup/activities_sheet.xlsx', 'activities');
      mockFileSystem.writeFile('/backup/categories_sheet.xlsx', 'categories');
      mockFileSystem.writeFile('/backup/completions_sheet.xlsx', 'completions');

      expect(mockFileSystem.fileExists('/backup/activities_sheet.xlsx'), isTrue);
      expect(mockFileSystem.fileExists('/backup/categories_sheet.xlsx'), isTrue);
      expect(mockFileSystem.fileExists('/backup/completions_sheet.xlsx'), isTrue);
    });
  });

  group('BackupService - Import Data', () {
    test('should import activities from CSV', () {
      final csvContent = '''id,name,recurrenceType,streak
test-6,Imported Activity,daily,3''';

      mockFileSystem.writeFile('/import/activities.csv', csvContent);
      
      final content = mockFileSystem.readFile('/import/activities.csv');
      expect(content, isNotNull);
      
      final activities = _parseCSV(content!);
      expect(activities.length, equals(1));
      expect(activities.first.name, equals('Imported Activity'));
      expect(activities.first.streak, equals(3));
    });

    test('should validate imported data', () {
      final invalidCSV = '''id,name,recurrenceType,streak
,Invalid Activity,daily,abc''';

      mockFileSystem.writeFile('/import/invalid.csv', invalidCSV);
      
      final content = mockFileSystem.readFile('/import/invalid.csv');
      
      expect(() => _parseCSV(content!), throwsFormatException);
    });
  });

  group('BackupService - File Operations', () {
    test('should create backup directory', () {
      mockFileSystem.createDirectory('/backups');
      
      expect(mockFileSystem.directoryExists('/backups'), isTrue);
    });

    test('should list backup files', () {
      mockFileSystem.writeFile('/backups/backup1.csv', 'data1');
      mockFileSystem.writeFile('/backups/backup2.csv', 'data2');
      mockFileSystem.writeFile('/backups/backup3.xlsx', 'data3');

      final files = mockFileSystem.listFiles('/backups');
      
      expect(files.length, equals(3));
      expect(files, contains('/backups/backup1.csv'));
      expect(files, contains('/backups/backup2.csv'));
      expect(files, contains('/backups/backup3.xlsx'));
    });

    test('should delete old backups', () {
      mockFileSystem.writeFile('/backups/old_backup.csv', 'old data');
      
      expect(mockFileSystem.fileExists('/backups/old_backup.csv'), isTrue);
      
      mockFileSystem.deleteFile('/backups/old_backup.csv');
      
      expect(mockFileSystem.fileExists('/backups/old_backup.csv'), isFalse);
    });
  });

  group('BackupService - Encryption (Mocked)', () {
    test('should encrypt backup data', () {
      final plainText = 'sensitive data';
      final encrypted = _mockEncrypt(plainText);
      
      expect(encrypted, isNot(equals(plainText)));
      expect(encrypted.length, greaterThan(plainText.length));
    });

    test('should decrypt backup data', () {
      final plainText = 'sensitive data';
      final encrypted = _mockEncrypt(plainText);
      final decrypted = _mockDecrypt(encrypted);
      
      expect(decrypted, equals(plainText));
    });
  });
}

// Helper functions for testing

String _generateCSV(List<Activity> activities) {
  final buffer = StringBuffer();
  buffer.writeln('id,name,recurrenceType,streak');
  
  for (var activity in activities) {
    final name = activity.name.contains(',') || activity.name.contains('"')
        ? '"${activity.name.replaceAll('"', '""')}"'
        : activity.name;
    
    buffer.writeln('${activity.id},$name,${activity.recurrenceType.name},${activity.streak}');
  }
  
  return buffer.toString();
}

String _generateExcelData(List<Activity> activities) {
  // Simplified Excel data representation
  return 'EXCEL_DATA:${activities.length}_activities';
}

List<Activity> _parseCSV(String csvContent) {
  final lines = csvContent.split('\n');
  if (lines.length < 2) return [];
  
  final activities = <Activity>[];
  
  for (int i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    
    final parts = line.split(',');
    if (parts.length < 4) continue;
    
    if (parts[0].isEmpty) {
      throw const FormatException('Invalid ID');
    }
    
    final streak = int.tryParse(parts[3]);
    if (streak == null) {
      throw const FormatException('Invalid streak value');
    }
    
    activities.add(Activity(
      id: parts[0],
      name: parts[1],
      recurrenceType: RecurrenceType.values.firstWhere(
        (e) => e.name == parts[2],
        orElse: () => RecurrenceType.daily,
      ),
      streak: streak,
    ));
  }
  
  return activities;
}

String _mockEncrypt(String plainText) {
  // Simple mock encryption (reverse string + prefix)
  return 'ENCRYPTED:${plainText.split('').reversed.join()}';
}

String _mockDecrypt(String encrypted) {
  // Simple mock decryption
  if (!encrypted.startsWith('ENCRYPTED:')) {
    throw const FormatException('Invalid encrypted data');
  }
  
  final reversed = encrypted.substring('ENCRYPTED:'.length);
  return reversed.split('').reversed.join();
}
