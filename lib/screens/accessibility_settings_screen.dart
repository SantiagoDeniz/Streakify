import 'package:flutter/material.dart';
import '../services/accessibility_service.dart';
import '../services/theme_service.dart';
import '../themes/app_themes.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  final AccessibilityService _accessibilityService = AccessibilityService();
  final ThemeService _themeService = ThemeService();

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
          _buildColorblindModeOption(),
          _buildTextScaleOption(),
          const Divider(height: 32),
          _buildSectionHeader('Interacción'),
          _buildReduceMotionOption(),
          _buildIncreasedTouchTargetsOption(),
          const Divider(height: 32),
          _buildSectionHeader('Información'),
          _buildScreenReaderInfo(),
          _buildKeyboardNavigationInfo(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 8),
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
    final isHighContrast = _themeService.currentTheme == AppThemeMode.highContrast;
    
    return ListTile(
      leading: const Icon(Icons.contrast),
      title: const Text('Tema de Alto Contraste'),
      subtitle: Text(
        isHighContrast 
            ? 'Actualmente activo' 
            : 'Mejora la legibilidad con colores de alto contraste'
      ),
      trailing: isHighContrast 
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        if (!isHighContrast) {
          await _themeService.setTheme(AppThemeMode.highContrast);
          setState(() {});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tema de Alto Contraste activado'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildColorblindModeOption() {
    final isColorblind = _themeService.currentTheme == AppThemeMode.colorblind;
    
    return ListTile(
      leading: const Icon(Icons.accessibility_new),
      title: const Text('Modo Daltónico'),
      subtitle: Text(
        isColorblind
            ? 'Actualmente activo'
            : 'Usa patrones y bordes gruesos además de colores'
      ),
      trailing: isColorblind
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () async {
        if (!isColorblind) {
          await _themeService.setTheme(AppThemeMode.colorblind);
          await _accessibilityService.setColorblindMode(true);
          setState(() {});
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Modo Daltónico activado'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildTextScaleOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tamaño del texto',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                '${(_accessibilityService.textScaleFactor * 100).round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
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

  Widget _buildIncreasedTouchTargetsOption() {
    return SwitchListTile(
      title: const Text('Aumentar áreas táctiles'),
      subtitle: const Text('Hace los botones más grandes y fáciles de tocar'),
      secondary: const Icon(Icons.touch_app),
      value: _accessibilityService.increasedTouchTargets,
      onChanged: (value) {
        setState(() {
          _accessibilityService.setIncreasedTouchTargets(value);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value 
                  ? 'Áreas táctiles aumentadas a 56x56pt' 
                  : 'Áreas táctiles restauradas a 44x44pt'
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  Widget _buildScreenReaderInfo() {
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
                Icon(Icons.record_voice_over, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Lector de Pantalla',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Streakify es totalmente compatible con lectores de pantalla:\n\n'
              '• Android: TalkBack\n'
              '• iOS: VoiceOver\n\n'
              'Todos los elementos interactivos tienen etiquetas descriptivas '
              'que anuncian el estado de las actividades, rachas, y acciones disponibles.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardNavigationInfo() {
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
                Icon(Icons.keyboard, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Navegación por Teclado',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Disponible en tablet y desktop:\n\n'
              '• Tab: Navegar entre elementos\n'
              '• Enter/Espacio: Activar botones\n'
              '• Flechas: Navegar en listas\n\n'
              'El foco del teclado es visible en todos los elementos interactivos.',
            ),
          ],
        ),
      ),
    );
  }
}
