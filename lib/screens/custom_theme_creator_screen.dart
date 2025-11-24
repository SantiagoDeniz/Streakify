import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/theme_service.dart';
import '../models/custom_theme.dart';
import '../l10n/app_localizations.dart';

class CustomThemeCreatorScreen extends StatefulWidget {
  final ThemeService themeService;
  final String localeCode;
  final CustomTheme? editingTheme;

  const CustomThemeCreatorScreen({
    super.key,
    required this.themeService,
    required this.localeCode,
    this.editingTheme,
  });

  @override
  State<CustomThemeCreatorScreen> createState() => _CustomThemeCreatorScreenState();
}

class _CustomThemeCreatorScreenState extends State<CustomThemeCreatorScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late bool _isDark;
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _tertiaryColor;
  late Color _backgroundColor;
  late AppLocalizations _l10n;

  @override
  void initState() {
    super.initState();
    _l10n = AppLocalizations.of(widget.localeCode);
    
    if (widget.editingTheme != null) {
      _nameController = TextEditingController(text: widget.editingTheme!.name);
      _descriptionController = TextEditingController(text: widget.editingTheme!.description ?? '');
      _isDark = widget.editingTheme!.isDark;
      _primaryColor = widget.editingTheme!.primaryColor;
      _secondaryColor = widget.editingTheme!.secondaryColor;
      _tertiaryColor = widget.editingTheme!.tertiaryColor;
      _backgroundColor = widget.editingTheme!.backgroundColor;
    } else {
      _nameController = TextEditingController();
      _descriptionController = TextEditingController();
      _isDark = false;
      _primaryColor = const Color(0xFF6200EE);
      _secondaryColor = const Color(0xFF03DAC6);
      _tertiaryColor = const Color(0xFFFF6B6B);
      _backgroundColor = Colors.white;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editingTheme != null ? _l10n.edit : _l10n.createCustomTheme),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildColorPickers(),
          const SizedBox(height: 24),
          _buildPreview(),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _l10n.themeName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: _l10n.themeDescription,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _isDark,
              onChanged: (value) {
                setState(() {
                  _isDark = value;
                  if (value) {
                    _backgroundColor = const Color(0xFF121212);
                  } else {
                    _backgroundColor = Colors.white;
                  }
                });
              },
              title: Text(_l10n.darkMode),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPickers() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.localeCode == 'es' ? 'Colores' : 'Colors',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildColorPicker(
              label: _l10n.primaryColor,
              color: _primaryColor,
              onColorChanged: (color) => setState(() => _primaryColor = color),
            ),
            const SizedBox(height: 12),
            _buildColorPicker(
              label: _l10n.secondaryColor,
              color: _secondaryColor,
              onColorChanged: (color) => setState(() => _secondaryColor = color),
            ),
            const SizedBox(height: 12),
            _buildColorPicker(
              label: _l10n.tertiaryColor,
              color: _tertiaryColor,
              onColorChanged: (color) => setState(() => _tertiaryColor = color),
            ),
            const SizedBox(height: 12),
            _buildColorPicker(
              label: _l10n.backgroundColor,
              color: _backgroundColor,
              onColorChanged: (color) => setState(() => _backgroundColor = color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker({
    required String label,
    required Color color,
    required Function(Color) onColorChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(label),
        ),
        InkWell(
          onTap: () => _showColorPicker(color, onColorChanged),
          child: Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(Color initialColor, Function(Color) onColorChanged) {
    final List<Color> presetColors = [
      Colors.red, Colors.pink, Colors.purple, Colors.deepPurple,
      Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan,
      Colors.teal, Colors.green, Colors.lightGreen, Colors.lime,
      Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
      Colors.brown, Colors.grey, Colors.blueGrey, Colors.black,
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.localeCode == 'es' ? 'Seleccionar color' : 'Select color'),
        content: SizedBox(
          width: 300,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: presetColors.length,
            itemBuilder: (context, index) {
              final color = presetColors[index];
              return InkWell(
                onTap: () {
                  onColorChanged(color);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color == initialColor ? Colors.white : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_l10n.cancel),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final customTheme = _createThemeFromCurrentSettings();
    final themeData = customTheme.toThemeData();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.preview,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Theme(
              data: themeData,
              child: Builder(
                builder: (context) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: themeData.colorScheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: themeData.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.palette,
                              color: themeData.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sample Card',
                              style: TextStyle(
                                color: themeData.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {},
                            child: const Text('Button'),
                          ),
                          FloatingActionButton.small(
                            onPressed: () {},
                            child: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  CustomTheme _createThemeFromCurrentSettings() {
    final now = DateTime.now();
    
    return CustomTheme(
      id: widget.editingTheme?.id ?? const Uuid().v4(),
      name: _nameController.text.isEmpty ? 'Custom Theme' : _nameController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      isDark: _isDark,
      primaryColor: _primaryColor,
      onPrimaryColor: _isDark ? Colors.black : Colors.white,
      primaryContainerColor: Color.alphaBlend(_primaryColor.withOpacity(0.3), _backgroundColor),
      onPrimaryContainerColor: _isDark ? Colors.white : Colors.black,
      secondaryColor: _secondaryColor,
      onSecondaryColor: _isDark ? Colors.black : Colors.white,
      secondaryContainerColor: Color.alphaBlend(_secondaryColor.withOpacity(0.3), _backgroundColor),
      onSecondaryContainerColor: _isDark ? Colors.white : Colors.black,
      tertiaryColor: _tertiaryColor,
      onTertiaryColor: _isDark ? Colors.black : Colors.white,
      tertiaryContainerColor: Color.alphaBlend(_tertiaryColor.withOpacity(0.3), _backgroundColor),
      onTertiaryContainerColor: _isDark ? Colors.white : Colors.black,
      backgroundColor: _backgroundColor,
      onBackgroundColor: _isDark ? Colors.white : Colors.black,
      surfaceColor: _backgroundColor,
      onSurfaceColor: _isDark ? Colors.white : Colors.black,
      errorColor: const Color(0xFFBA1A1A),
      onErrorColor: Colors.white,
      createdAt: widget.editingTheme?.createdAt ?? now,
      modifiedAt: widget.editingTheme != null ? now : null,
    );
  }

  void _saveTheme() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.localeCode == 'es' 
                ? 'Por favor ingresa un nombre para el tema' 
                : 'Please enter a theme name',
          ),
        ),
      );
      return;
    }

    final customTheme = _createThemeFromCurrentSettings();

    if (widget.editingTheme != null) {
      widget.themeService.updateCustomTheme(widget.editingTheme!.id, customTheme);
    } else {
      widget.themeService.addCustomTheme(customTheme);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_l10n.themeCreated)),
    );
  }
}
