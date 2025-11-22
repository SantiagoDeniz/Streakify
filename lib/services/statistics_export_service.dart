import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../services/advanced_statistics_service.dart';

/// Servicio para exportar estadísticas como imágenes y documentos
class StatisticsExportService {
  /// Exportar estadísticas como texto
  static Future<String> exportAsText(
    List<Activity> activities,
    AdvancedStatisticsService statsService,
  ) async {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('       STREAKIFY - ESTADÍSTICAS        ');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Generado: ${dateFormat.format(now)}');
    buffer.writeln();

    // Resumen general
    buffer.writeln('📊 RESUMEN GENERAL');
    buffer.writeln('───────────────────────────────────────');
    final activeActivities = activities.where((a) => a.active).toList();
    buffer.writeln('Total de actividades: ${activities.length}');
    buffer.writeln('Actividades activas: ${activeActivities.length}');
    buffer.writeln(
        'Actividades pausadas: ${activities.length - activeActivities.length}');

    // Mejor racha
    int maxStreak = 0;
    String? bestActivityName;
    for (var activity in activities) {
      if (activity.streak > maxStreak) {
        maxStreak = activity.streak;
        bestActivityName = activity.name;
      }
    }
    buffer.writeln('Mejor racha actual: $maxStreak días ($bestActivityName)');

    // Métricas avanzadas
    final totalDays = await statsService.getTotalConsecutiveDays();
    final perfectDays = await statsService.getPerfectDays();
    buffer.writeln('Días únicos completados: $totalDays');
    buffer.writeln('Días perfectos: ${perfectDays.length}');
    buffer.writeln();

    // Detalles por actividad
    buffer.writeln('📋 DETALLE POR ACTIVIDAD');
    buffer.writeln('───────────────────────────────────────');

    final successRates = await statsService.getSuccessRate();
    final bestStreaks = await statsService.getBestStreaks();
    final avgStreaks = await statsService.getAverageStreaks();

    for (var activity in activities) {
      buffer.writeln();
      buffer.writeln('• ${activity.name}');
      buffer.writeln('  Estado: ${activity.active ? "Activa" : "Pausada"}');
      buffer.writeln('  Racha actual: ${activity.streak} días');
      buffer.writeln('  Mejor racha: ${bestStreaks[activity.id] ?? 0} días');
      buffer.writeln(
          '  Racha promedio: ${(avgStreaks[activity.id] ?? 0).toStringAsFixed(1)} días');
      buffer.writeln(
          '  Tasa de éxito: ${(successRates[activity.id] ?? 0).toStringAsFixed(1)}%');
      if (activity.lastCompleted != null) {
        buffer.writeln(
            '  Última vez: ${dateFormat.format(activity.lastCompleted!)}');
      }
    }

    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('  Generado por Streakify - Habit Tracker');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  /// Exportar estadísticas como CSV
  static Future<String> exportAsCSV(
    List<Activity> activities,
    AdvancedStatisticsService statsService,
  ) async {
    final buffer = StringBuffer();

    // Encabezados
    buffer.writeln(
        'Actividad,Estado,Racha Actual,Mejor Racha,Racha Promedio,Tasa de Éxito (%),Última Completación');

    final successRates = await statsService.getSuccessRate();
    final bestStreaks = await statsService.getBestStreaks();
    final avgStreaks = await statsService.getAverageStreaks();
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    for (var activity in activities) {
      final name = activity.name.replaceAll(',', ';'); // Escapar comas
      final status = activity.active ? 'Activa' : 'Pausada';
      final currentStreak = activity.streak;
      final bestStreak = bestStreaks[activity.id] ?? 0;
      final avgStreak = (avgStreaks[activity.id] ?? 0).toStringAsFixed(1);
      final successRate = (successRates[activity.id] ?? 0).toStringAsFixed(1);
      final lastCompleted = activity.lastCompleted != null
          ? dateFormat.format(activity.lastCompleted!)
          : 'Nunca';

      buffer.writeln(
          '$name,$status,$currentStreak,$bestStreak,$avgStreak,$successRate,$lastCompleted');
    }

    return buffer.toString();
  }

  /// Compartir estadísticas
  static Future<void> shareStatistics(
    List<Activity> activities,
    AdvancedStatisticsService statsService, {
    String format = 'text', // 'text' o 'csv'
  }) async {
    try {
      final content = format == 'csv'
          ? await exportAsCSV(activities, statsService)
          : await exportAsText(activities, statsService);

      final directory = await getTemporaryDirectory();
      final extension = format == 'csv' ? 'csv' : 'txt';
      final fileName =
          'streakify_estadisticas_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.$extension';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Mis estadísticas de Streakify',
      );
    } catch (e) {
      throw Exception('Error al exportar estadísticas: $e');
    }
  }

  /// Capturar widget como imagen
  static Future<Uint8List?> captureWidgetAsImage(GlobalKey key) async {
    try {
      final RenderRepaintBoundary boundary =
          key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  /// Compartir gráfico como imagen
  static Future<void> shareChartImage(
      GlobalKey chartKey, String chartName) async {
    try {
      final imageBytes = await captureWidgetAsImage(chartKey);
      if (imageBytes == null) {
        throw Exception('No se pudo capturar la imagen');
      }

      final directory = await getTemporaryDirectory();
      final fileName =
          'streakify_${chartName}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.png';
      final file = File('${directory.path}/$fileName');

      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Mi gráfico de $chartName - Streakify',
      );
    } catch (e) {
      throw Exception('Error al exportar imagen: $e');
    }
  }
}
