import 'package:flutter/material.dart';
import '../services/social_service.dart';

class ShareAchievementDialog extends StatelessWidget {
  final String title;
  final String description;
  final String? imagePath;
  final SocialService _socialService = SocialService();

  ShareAchievementDialog({
    Key? key,
    required this.title,
    required this.description,
    this.imagePath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.share, size: 40, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              '¡Comparte tu logro!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await _socialService.shareAchievement(
                      title,
                      description,
                      imagePath: imagePath,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Compartir'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
