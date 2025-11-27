import 'package:flutter/material.dart';
import '../data/faq_data.dart';
import 'faq_screen.dart';
import 'changelog_screen.dart';
import 'feedback_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centro de Ayuda'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildCategories(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.help_outline,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          '¿En qué podemos ayudarte?',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Encuentra respuestas rápidas a tus preguntas',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acceso Rápido',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.question_answer,
                title: 'FAQ',
                subtitle: 'Preguntas frecuentes',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FAQScreen()),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context,
                icon: Icons.new_releases,
                title: 'Novedades',
                subtitle: 'Últimas actualizaciones',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangelogScreen()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          context,
          icon: Icons.feedback,
          title: 'Enviar Feedback',
          subtitle: 'Reporta bugs o comparte sugerencias',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FeedbackScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(BuildContext context) {
    final categories = getFAQCategories();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorías de Ayuda',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        ...categories.map((category) => _buildCategoryTile(context, category)),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context, String category) {
    final faqs = getFAQsByCategory(category);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_getCategoryIcon(category)),
        title: Text(category),
        subtitle: Text('${faqs.length} artículos'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FAQScreen(initialCategory: category),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Inicio':
        return Icons.home;
      case 'Actividades':
        return Icons.list;
      case 'Rachas':
        return Icons.local_fire_department;
      case 'Estadísticas':
        return Icons.bar_chart;
      case 'Notificaciones':
        return Icons.notifications;
      case 'Datos':
        return Icons.storage;
      case 'Premium':
        return Icons.workspace_premium;
      case 'Técnico':
        return Icons.settings;
      default:
        return Icons.help;
    }
  }
}
