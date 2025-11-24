import 'package:flutter/material.dart';
import '../models/buddy.dart';

class BuddyCard extends StatelessWidget {
  final Buddy buddy;
  final VoidCallback? onTap;

  const BuddyCard({
    Key? key,
    required this.buddy,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  buddy.name.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: Colors.indigo.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      buddy.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.local_fire_department,
                            size: 16, color: Colors.orange),
                        const SizedBox(width: 4),
                        Text(
                          '${buddy.currentStreak} días',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.message_outlined),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Mensaje a ${buddy.name}')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
