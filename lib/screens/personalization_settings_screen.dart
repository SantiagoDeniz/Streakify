import 'package:flutter/material.dart';
import '../services/personalization_service.dart';
import '../l10n/app_localizations.dart';

class PersonalizationSettingsScreen extends StatefulWidget {
  final PersonalizationService personalizationService;

  const PersonalizationSettingsScreen({
    super.key,
    required this.personalizationService,
  });

  @override
  State<PersonalizationSettingsScreen> createState() => _PersonalizationSettingsScreenState();
}

class _PersonalizationSettingsScreenState extends State<PersonalizationSettingsScreen> {
  late AppLocalizations _l10n;

  @override
  void initState() {
    super.initState();
    _l10n = AppLocalizations.of(widget.personalizationService.localeCode);
    widget.personalizationService.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    widget.personalizationService.removeListener(_onSettingsChanged);
    super.dispose();
  }

  void _onSettingsChanged() {
    setState(() {
      _l10n = AppLocalizations.of(widget.personalizationService.localeCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_l10n.personalization),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLanguageSection(),
          const SizedBox(height: 24),
          _buildFontSection(),
          const SizedBox(height: 24),
          _buildTextSizeSection(),
          const SizedBox(height: 24),
          _buildDensitySection(),
          const SizedBox(height: 24),
          _buildDateFormatSection(),
          const SizedBox(height: 24),
          _buildDayStartSection(),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.language,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'es',
                  label: Text(_l10n.spanish),
                  icon: const Icon(Icons.language),
                ),
                ButtonSegment(
                  value: 'en',
                  label: Text(_l10n.english),
                  icon: const Icon(Icons.language),
                ),
              ],
              selected: {widget.personalizationService.localeCode},
              onSelectionChanged: (Set<String> selected) {
                widget.personalizationService.setLocale(selected.first);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_l10n.settingsSaved)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSection() {
    final fonts = PersonalizationService.getAvailableFonts();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.font,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: widget.personalizationService.fontFamily,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: fonts.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(
                    font,
                    style: TextStyle(fontFamily: font),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  widget.personalizationService.setFontFamily(value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextSizeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _l10n.textSize,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${(widget.personalizationService.textSizeMultiplier * 100).round()}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.text_fields, size: 16),
                Expanded(
                  child: Slider(
                    value: widget.personalizationService.textSizeMultiplier,
                    min: 0.8,
                    max: 1.5,
                    divisions: 14,
                    label: '${(widget.personalizationService.textSizeMultiplier * 100).round()}%',
                    onChanged: (value) {
                      widget.personalizationService.setTextSizeMultiplier(value);
                    },
                  ),
                ),
                const Icon(Icons.text_fields, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Aa Bb Cc 123',
              style: TextStyle(
                fontSize: 20 * widget.personalizationService.textSizeMultiplier,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDensitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.density,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<InformationDensity>(
              segments: InformationDensity.values.map((density) {
                return ButtonSegment(
                  value: density,
                  label: Text(widget.personalizationService.getDensityName(density)),
                  icon: Icon(_getDensityIcon(density)),
                );
              }).toList(),
              selected: {widget.personalizationService.density},
              onSelectionChanged: (Set<InformationDensity> selected) {
                widget.personalizationService.setDensity(selected.first);
              },
            ),
            const SizedBox(height: 16),
            _buildDensityPreview(),
          ],
        ),
      ),
    );
  }

  IconData _getDensityIcon(InformationDensity density) {
    switch (density) {
      case InformationDensity.compact:
        return Icons.view_compact;
      case InformationDensity.normal:
        return Icons.view_comfortable;
      case InformationDensity.spacious:
        return Icons.view_cozy;
    }
  }

  Widget _buildDensityPreview() {
    final padding = widget.personalizationService.getPadding();
    final spacing = widget.personalizationService.getSpacing();
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _l10n.preview,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: spacing),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.center,
            child: Text(
              'Sample Card',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateFormatSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _l10n.dateFormat,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...DateFormatType.values.map((format) {
              final isSelected = widget.personalizationService.dateFormat == format;
              final exampleDate = DateTime(2025, 11, 23);
              
              return RadioListTile<DateFormatType>(
                value: format,
                groupValue: widget.personalizationService.dateFormat,
                onChanged: (value) {
                  if (value != null) {
                    widget.personalizationService.setDateFormat(value);
                  }
                },
                title: Text(widget.personalizationService.getDateFormatName(format)),
                subtitle: Text(
                  widget.personalizationService.formatDate(exampleDate),
                  style: TextStyle(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary 
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                dense: true,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDayStartSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _l10n.dayStartHour,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${widget.personalizationService.dayStartHour.toString().padLeft(2, '0')}:00',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.personalizationService.localeCode == 'es'
                  ? 'Para personas nocturnas: establece cuándo comienza tu "día"'
                  : 'For night owls: set when your "day" begins',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Slider(
              value: widget.personalizationService.dayStartHour.toDouble(),
              min: 0,
              max: 23,
              divisions: 23,
              label: '${widget.personalizationService.dayStartHour.toString().padLeft(2, '0')}:00',
              onChanged: (value) {
                widget.personalizationService.setDayStartHour(value.round());
              },
            ),
          ],
        ),
      ),
    );
  }
}
