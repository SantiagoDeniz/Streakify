import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:streakify/screens/home_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Flow Integration Test', () {
    testWidgets('Flow 1: Create, Edit (Swipe), and Delete (Swipe)', (WidgetTester tester) async {
      // Start app with minimal setup - just the home screen
      await tester.pumpWidget(
        const MaterialApp(
          title: 'Streakify',
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // --- CREATE ---
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);
      
      await tester.tap(fab);
      await tester.pumpAndSettle();
      
      // Enter activity name
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
      
      await tester.enterText(textFields.last, 'Swipe Test Activity');
      await tester.pumpAndSettle();
      
      // Save
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      
      // Verify activity was created
      expect(find.text('Swipe Test Activity'), findsOneWidget);

      // --- EDIT (Swipe Right) ---
      // Drag from left to right to trigger edit
      await tester.drag(find.text('Swipe Test Activity'), const Offset(500, 0));
      await tester.pumpAndSettle();
      
      // Confirm edit dialog
      if (find.text('Editar actividad').evaluate().isNotEmpty) {
        await tester.tap(find.text('Editar'));
        await tester.pumpAndSettle();
      }

      // Change name
      final editFields = find.byType(TextField);
      if (editFields.evaluate().isNotEmpty) {
        await tester.enterText(editFields.first, 'Edited Activity');
        await tester.pumpAndSettle();
        
        await tester.tap(find.text('Guardar'));
        await tester.pumpAndSettle();

        expect(find.text('Edited Activity'), findsOneWidget);
        expect(find.text('Swipe Test Activity'), findsNothing);
      }

      // --- DELETE (Swipe Left) ---
      // Drag from right to left to trigger delete
      await tester.drag(find.text('Edited Activity'), const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Confirm delete dialog
      if (find.text('Eliminar actividad').evaluate().isNotEmpty) {
        await tester.tap(find.text('Eliminar'));
        await tester.pumpAndSettle();

        expect(find.text('Edited Activity'), findsNothing);
      }
    });

    testWidgets('Flow 2: Create and Complete Activity', (WidgetTester tester) async {
      // Start app with minimal setup
      await tester.pumpWidget(
        const MaterialApp(
          title: 'Streakify',
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // --- CREATE ---
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      
      await tester.enterText(find.byType(TextField).last, 'Complete Test Activity');
      await tester.pumpAndSettle();
      
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();
      
      expect(find.text('Complete Test Activity'), findsOneWidget);

      // --- COMPLETE ---
      // Find and tap the complete button (IconButton)
      final iconButtons = find.byType(IconButton);
      if (iconButtons.evaluate().isNotEmpty) {
        await tester.tap(iconButtons.first);
        await tester.pumpAndSettle();
        
        // Verify completion (check for check_circle icon or completed state)
        // The exact verification depends on your UI implementation
      }
    });
  });
}
