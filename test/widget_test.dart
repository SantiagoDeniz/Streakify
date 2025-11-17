// Test básico para Streakify
//
// Prueba que la aplicación se inicie correctamente y muestre los elementos principales.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/main.dart';

void main() {
  testWidgets('Streakify app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StreakifyApp());

    // Verify that the app title is present
    expect(find.text('Streakify'), findsOneWidget);

    // Verify that the FAB (Floating Action Button) is present
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Verify that we can tap the FAB to open the dialog
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Verify the dialog appears
    expect(find.text('Nueva actividad'), findsOneWidget);
  });

  testWidgets('Can navigate to statistics screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StreakifyApp());

    // Find and tap the menu button
    expect(find.byIcon(Icons.more_vert), findsOneWidget);
    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();

    // Find and tap the statistics option
    expect(find.text('Estadísticas'), findsOneWidget);
    await tester.tap(find.text('Estadísticas'));
    await tester.pumpAndSettle();

    // Verify we're on the statistics screen
    expect(find.text('Estadísticas'), findsWidgets);
  });
}
