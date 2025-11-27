import 'package:flutter/material.dart';

/// Widget to display a premium badge/indicator
class PremiumBadge extends StatelessWidget {
  final bool showLabel;
  final double size;

  const PremiumBadge({
    super.key,
    this.showLabel = true,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    if (showLabel) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: size, color: Colors.white),
            const SizedBox(width: 4),
            const Text(
              'PRO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Icon(
      Icons.workspace_premium,
      size: size,
      color: const Color(0xFFFFD700),
    );
  }
}
