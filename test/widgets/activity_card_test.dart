import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streakify/widgets/activity_card.dart';
import 'package:streakify/models/activity.dart';

void main() {
  group('ActivityCard Tests', () {
    testWidgets('renders activity name correctly', (WidgetTester tester) async {
      final activity = Activity(
        id: '1',
        name: 'Test Activity',
        streak: 5,
        active: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activity: activity,
              onComplete: () {},
              onEdit: () {},
              onDelete: () {},
              onToggleActive: () {},
              onUseProtector: () {},
              isCompactView: true, // Use compact view for simpler testing
            ),
          ),
        ),
      );

      // Verify activity name is displayed
      expect(find.text('Test Activity'), findsOneWidget);
      
      // Verify complete button exists
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('triggers onComplete callback when button tapped', (WidgetTester tester) async {
      bool completed = false;
      final activity = Activity(
        id: '1',
        name: 'Test Activity',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCard(
              activity: activity,
              onComplete: () {
                completed = true;
              },
              onEdit: () {},
              onDelete: () {},
              onToggleActive: () {},
              onUseProtector: () {},
              isCompactView: true,
            ),
          ),
        ),
      );

      // Find and tap the complete button
      final completeButton = find.byType(IconButton);
      expect(completeButton, findsWidgets);
      
      await tester.tap(completeButton.first);
      await tester.pump();

      expect(completed, true);
    });
  });
}
