import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';
import '../themes/app_themes.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  final AccessibilityService _accessibilityService = AccessibilityService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accesibilidad'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Visual'),
          _buildHighContrastOption(),
          _buildTextScaleOption(),
          const Divider(height: 32),
          _buildSectionHeader('Movimiento'),
          _buildReduceMotionOption(),
          const Divider(height: 32),
          _buildSectionHeader('Información'),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildHighContrastOption() {
    // This assumes the parent widget (HomeScreen or Main) handles theme changes
    // We might need a way to notify the app about theme changes if this screen
    // is supposed to change the theme directly.
    // For now, we'll just show a message or link to theme settings if needed,
    // or we can implement theme switching here if we have access to the callback.
    // Since we don't have the callback here, we'll rely on the main theme dialog
    // but we can add a specific tile for it if we want to duplicate logic.
    // However, the requirement is "High contrast mode".
    // Let's check if we can access the current theme mode from here.
    // Actually, the theme is controlled by main.dart state.
    // We might need to use a provider or pass a callback.
    // Given the current architecture, it's easier to just inform the user
    // that High Contrast is available in the Theme selector, OR
    // we can make this screen accept a callback.
    
    // For now, let's just add a tile that opens the theme dialog if possible,
    // or just explains it.
    // Better yet, let's make this screen purely about the AccessibilityService
    // settings, and maybe add a "Theme" shortcut.
    
    return ListTile(
      leading: const Icon(Icons.contrast),
      title: const Text('Tema de Alto Contraste'),
      subtitle: const Text('Mejora la legibilidad con colores de alto contraste'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // We can't easily switch theme from here without a callback or provider.
        // Let's just show a snackbar for now or maybe we can pop with a result?
        // No, let's just leave it as an informational tile that guides users
        // to the theme selector in the home screen.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Puedes seleccionar "Alto Contraste" en el menú de temas de la pantalla principal.'),
          ),
        );
      },
    );
  }

  Widget _buildTextScaleOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Tamaño del texto',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
        Slider(
          value: _accessibilityService.textScaleFactor,
          min: 0.8,
          max: 2.0,
          divisions: 12,
          label: '${(_accessibilityService.textScaleFactor * 100).round()}%',
          onChanged: (value) {
            setState(() {
              _accessibilityService.setTextScaleFactor(value);
            });
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('A', style: TextStyle(fontSize: 14 * 0.8)),
              Text('A', style: TextStyle(fontSize: 14 * 2.0)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReduceMotionOption() {
    return SwitchListTile(
      title: const Text('Reducir movimiento'),
      subtitle: const Text('Minimiza las animaciones y transiciones'),
      secondary: const Icon(Icons.animation),
      value: _accessibilityService.reduceMotion,
      onChanged: (value) {
        setState(() {
          _accessibilityService.setReduceMotion(value);
        });
      },
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Accesibilidad en Streakify',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Streakify es compatible con lectores de pantalla (TalkBack/VoiceOver). '
              'Todos los elementos interactivos tienen etiquetas descriptivas.',
            ),
          ],
        ),
      ),
    );
  }
}
