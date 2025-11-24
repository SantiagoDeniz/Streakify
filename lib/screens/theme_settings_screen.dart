import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../themes/app_themes.dart';
import '../l10n/app_localizations.dart';
import 'custom_theme_creator_screen.dart';

class ThemeSettingsScreen extends StatefulWidget {
  final ThemeService themeService;
  final String localeCode;
  final Function(AppThemeMode) onThemeChanged;

  const ThemeSettingsScreen({
    super.key,
    required this.themeService,
    required this.localeCode,
    required this.onThemeChanged,
  });

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  late AppLocalizations _l10n;

  @override
  void initState() {
    super.initState();
    _l10n = AppLocalizations.of(widget.localeCode);
    widget.themeService.addListener(_onThemeServiceChanged);
  }

  @override
  void dispose() {
    widget.themeService.removeListener(_onThemeServiceChanged);
    super.dispose();
  }

  void _onThemeServiceChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_l10n.themes),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createCustomTheme,
            tooltip: _l10n.createCustomTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAutoThemeSection(),
          const SizedBox(height: 24),
          _buildBuiltInThemesSection(),
          if (widget.themeService.customThemes.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildCustomThemesSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoThemeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              value: widget.themeService.autoSwitchEnabled,
              onChanged: (value) {
                widget.themeService.setAutoSwitchEnabled(value);
                if (value) {
                  // Apply auto theme immediately
                  final autoTheme = widget.themeService.getAutoTheme();
                  widget.onThemeChanged(autoTheme);
                }
              },
              title: Text(
                _l10n.autoTheme,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(_l10n.autoThemeDesc),
            ),
            if (widget.themeService.autoSwitchEnabled) ...[
              const Divider(),
              const SizedBox(height: 8),
              _buildTimeRangeSelector(),
              const SizedBox(height: 16),
              _buildThemeSelectors(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.localeCode == 'es' ? 'Horario del tema claro' : 'Light theme hours',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildHourSelector(
                label: widget.localeCode == 'es' ? 'Inicio' : 'Start',
                value: widget.themeService.lightThemeStartHour,
                onChanged: (hour) {
                  widget.themeService.setLightThemeHours(
                    hour,
                    widget.themeService.lightThemeEndHour,
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildHourSelector(
                label: widget.localeCode == 'es' ? 'Fin' : 'End',
                value: widget.themeService.lightThemeEndHour,
                onChanged: (hour) {
                  widget.themeService.setLightThemeHours(
                    widget.themeService.lightThemeStartHour,
                    hour,
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHourSelector({
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        DropdownButtonFormField<int>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: List.generate(24, (i) => i).map((hour) {
            return DropdownMenuItem(
              value: hour,
              child: Text('${hour.toString().padLeft(2, '0')}:00'),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildThemeSelectors() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThemeDropdown(
          label: _l10n.lightTheme,
          value: widget.themeService.lightThemeMode,
          onChanged: (theme) {
            widget.themeService.setAutoSwitchThemes(
              theme,
              widget.themeService.darkThemeMode,
            );
          },
        ),
        const SizedBox(height: 12),
        _buildThemeDropdown(
          label: _l10n.darkTheme,
          value: widget.themeService.darkThemeMode,
          onChanged: (theme) {
            widget.themeService.setAutoSwitchThemes(
              widget.themeService.lightThemeMode,
              theme,
            );
          },
        ),
      ],
    );
  }

  Widget _buildThemeDropdown({
    required String label,
    required AppThemeMode value,
    required Function(AppThemeMode) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        DropdownButtonFormField<AppThemeMode>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: AppThemeMode.values.map((mode) {
            return DropdownMenuItem(
              value: mode,
              child: Row(
                children: [
                  Icon(AppThemes.getThemeIcon(mode), size: 20),
                  const SizedBox(width: 8),
                  Text(AppThemes.getThemeName(mode)),
                ],
              ),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) onChanged(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildBuiltInThemesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.localeCode == 'es' ? 'Temas integrados' : 'Built-in themes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: AppThemeMode.values.length,
          itemBuilder: (context, index) {
            final mode = AppThemeMode.values[index];
            return _buildThemeCard(mode);
          },
        ),
      ],
    );
  }

  Widget _buildThemeCard(AppThemeMode mode) {
    final theme = AppThemes.getTheme(mode);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          widget.onThemeChanged(mode);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_l10n.themeApplied)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                color: theme.colorScheme.background,
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildColorCircle(theme.colorScheme.primary),
                        _buildColorCircle(theme.colorScheme.secondary),
                        _buildColorCircle(theme.colorScheme.tertiary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: theme.colorScheme.surfaceVariant,
              child: Row(
                children: [
                  Icon(
                    AppThemes.getThemeIcon(mode),
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      AppThemes.getThemeName(mode),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
    );
  }

  Widget _buildCustomThemesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _l10n.customThemes,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.themeService.customThemes.length,
          itemBuilder: (context, index) {
            final customTheme = widget.themeService.customThemes[index];
            return Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: customTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                title: Text(customTheme.name),
                subtitle: customTheme.description != null
                    ? Text(customTheme.description!)
                    : null,
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteCustomTheme(customTheme.id),
                ),
                onTap: () {
                  // Apply custom theme (would need to integrate with main app)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_l10n.themeApplied)),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _createCustomTheme() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomThemeCreatorScreen(
          themeService: widget.themeService,
          localeCode: widget.localeCode,
        ),
      ),
    );
  }

  void _deleteCustomTheme(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_l10n.delete),
        content: Text(
          widget.localeCode == 'es'
              ? '¿Eliminar este tema personalizado?'
              : 'Delete this custom theme?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.themeService.deleteCustomTheme(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(_l10n.themeDeleted)),
              );
            },
            child: Text(_l10n.delete),
          ),
        ],
      ),
    );
  }
}
