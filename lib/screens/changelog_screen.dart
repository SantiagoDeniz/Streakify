import 'package:flutter/material.dart';
import '../data/changelog_data.dart';
import '../models/changelog_entry.dart';

class ChangelogScreen extends StatelessWidget {
  const ChangelogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Versiones'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: changelogData.length,
        itemBuilder: (context, index) => _buildChangelogEntry(
          context,
          changelogData[index],
          isLatest: index == 0,
        ),
      ),
    );
  }

  Widget _buildChangelogEntry(
    BuildContext context,
    ChangelogEntry entry,
    {bool isLatest = false},
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        initiallyExpanded: isLatest,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isLatest
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.new_releases,
            color: isLatest
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        title: Row(
          children: [
            Text(
              'Versión ${entry.version}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isLatest) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NUEVO',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(_formatDate(entry.date)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.features.isNotEmpty) ...[
                  _buildChangeSection(
                    context,
                    '✨ Nuevas Características',
                    entry.features,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),
                ],
                if (entry.improvements.isNotEmpty) ...[
                  _buildChangeSection(
                    context,
                    '🚀 Mejoras',
                    entry.improvements,
                    Colors.green,
                  ),
                  const SizedBox(height: 16),
                ],
                if (entry.bugFixes.isNotEmpty) ...[
                  _buildChangeSection(
                    context,
                    '🐛 Correcciones',
                    entry.bugFixes,
                    Colors.orange,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeSection(
    BuildContext context,
    String title,
    List<String> changes,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 8),
        ...changes.map((change) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(child: Text(change)),
                ],
              ),
            )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }
}
