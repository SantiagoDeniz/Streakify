import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:streakify/main.dart';
import 'package:streakify/services/accessibility_service.dart';
import 'package:streakify/services/personalization_service.dart';
import 'package:streakify/services/theme_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Test', () {
    testWidgets('Flow 1: Create, Edit (Swipe), and Delete (Swipe)', (WidgetTester tester) async {
      // Initialize services
      final accessibilityService = AccessibilityService();
      await accessibilityService.init();
      
      final personalizationService = PersonalizationService();
      await personalizationService.init();
      
      final themeService = ThemeService();
      await themeService.init();

      // Start app with initialized services
      await tester.pumpWidget(StreakifyApp(
        accessibilityService: accessibilityService,
        personalizationService: personalizationService,
        themeService: themeService,
      ));
      await tester.pumpAndSettle();

      // --- CREATE ---
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Swipe Test Activity');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Swipe Test Activity'), findsOneWidget);

      // --- EDIT (Swipe Right) ---
      // Drag from left to right to trigger edit
      await tester.drag(find.text('Swipe Test Activity'), const Offset(500, 0));
      await tester.pumpAndSettle();
      
      // Confirm edit dialog
      expect(find.text('Editar actividad'), findsOneWidget);
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      // Change name
      await tester.enterText(find.byType(TextField).first, 'Edited Activity');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      expect(find.text('Edited Activity'), findsOneWidget);
      expect(find.text('Swipe Test Activity'), findsNothing);

      // --- DELETE (Swipe Left) ---
      // Drag from right to left to trigger delete
      await tester.drag(find.text('Edited Activity'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Confirm delete dialog
      expect(find.text('Eliminar actividad'), findsOneWidget);
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(find.text('Edited Activity'), findsNothing);
    });

    testWidgets('Flow 2: Create, Edit (Focus Screen), Complete (Focus Screen)', (WidgetTester tester) async {
      // Initialize services
      final accessibilityService = AccessibilityService();
      await accessibilityService.init();
      
      final personalizationService = PersonalizationService();
      await personalizationService.init();
      
      final themeService = ThemeService();
      await themeService.init();

      // Start app with initialized services
      await tester.pumpWidget(StreakifyApp(
        accessibilityService: accessibilityService,
        personalizationService: personalizationService,
        themeService: themeService,
      ));
      await tester.pumpAndSettle();

      // --- CREATE ---
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Focus Test Activity');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // --- NAVIGATE TO FOCUS SCREEN ---
      await tester.tap(find.text('Focus Test Activity'));
      await tester.pumpAndSettle();
      expect(find.text('Focus Test Activity'), findsOneWidget); // Title in AppBar

      // --- EDIT (Focus Screen) ---
      // Go to Details tab (last tab)
      await tester.tap(find.byIcon(Icons.info));
      await tester.pumpAndSettle();

      // Scroll down to find Edit button
      await tester.scrollUntilVisible(
        find.text('Editar Actividad'),
        500.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.tap(find.text('Editar Actividad'));
      await tester.pumpAndSettle();

      // Change name
      await tester.enterText(find.byType(TextField).first, 'Focus Edited Activity');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Verify we are back on Home Screen with new name
      expect(find.text('Focus Edited Activity'), findsOneWidget);

      // --- COMPLETE (Focus Screen) ---
      // Navigate back to Focus Screen
      await tester.tap(find.text('Focus Edited Activity'));
      await tester.pumpAndSettle();

      // Tap "Completar Hoy" FAB
      await tester.tap(find.text('Completar Hoy'));
      await tester.pumpAndSettle();

      // Verify we are back on Home Screen and it's completed
      // (Visual check: check icon)
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
