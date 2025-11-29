import 'package:flutter/material.dart';
import '../screens/premium_screen.dart';

/// Dialog to prompt user to upgrade to premium
class UpgradePromptDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? featureName;

  const UpgradePromptDialog({
    super.key,
    required this.title,
    required this.message,
    this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.workspace_premium,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (featureName != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      featureName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Ahora no'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PremiumScreen()),
            );
          },
          icon: const Icon(Icons.star),
          label: const Text('Ver Premium'),
        ),
      ],
    );
  }

  /// Show the upgrade prompt dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? featureName,
  }) {
    return showDialog(
      context: context,
      builder: (context) => UpgradePromptDialog(
        title: title,
        message: message,
        featureName: featureName,
      ),
    );
  }
}
