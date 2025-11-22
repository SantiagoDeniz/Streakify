import 'package:flutter/material.dart';
import '../models/activity_template.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../utils/activity_icons.dart';

/// Widget para seleccionar plantillas de actividades predefinidas
class TemplateSelector extends StatefulWidget {
  final Function(ActivityTemplate) onTemplateSelected;

  const TemplateSelector({
    Key? key,
    required this.onTemplateSelected,
  }) : super(key: key);

  @override
  State<TemplateSelector> createState() => _TemplateSelectorState();
}

class _TemplateSelectorState extends State<TemplateSelector> {
  String? _selectedCategoryFilter;
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await CategoryService().getCategories();
    setState(() {
      _categories = categories;
    });
  }

  List<ActivityTemplate> _getFilteredTemplates() {
    if (_selectedCategoryFilter == null) {
      return ActivityTemplate.predefinedTemplates;
    }
    return ActivityTemplate.getTemplatesByCategory(_selectedCategoryFilter!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredTemplates = _getFilteredTemplates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Plantillas Predefinidas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Elige una plantilla para comenzar rápidamente',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),

        // Filtro por categoría
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              FilterChip(
                label: const Text('Todas'),
                selected: _selectedCategoryFilter == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategoryFilter = null;
                  });
                },
              ),
              const SizedBox(width: 8),
              ..._categories.map((category) {
                final isSelected = _selectedCategoryFilter == category.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          category.icon,
                          size: 16,
                          color: isSelected ? Colors.white : category.color,
                        ),
                        const SizedBox(width: 4),
                        Text(category.name),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: category.color,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategoryFilter = selected ? category.id : null;
                      });
                    },
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Lista de plantillas
        SizedBox(
          height: 400,
          child: filteredTemplates.isEmpty
              ? Center(
                  child: Text(
                    'No hay plantillas para esta categoría',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: filteredTemplates.length,
                  itemBuilder: (context, index) {
                    final template = filteredTemplates[index];
                    return _buildTemplateCard(template, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTemplateCard(ActivityTemplate template, ThemeData theme) {
    final color = ActivityColors.hexToColor(template.colorHex);
    final icon = ActivityIcons.getIconByName(template.iconName);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => widget.onTemplateSelected(template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (template.defaultTargetDays != null) ...[
                          Icon(
                            Icons.flag,
                            size: 14,
                            color: Colors.purple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Meta: ${template.defaultTargetDays} días',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.purple,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Icon(
                          Icons.repeat,
                          size: 14,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getRecurrenceText(template.defaultRecurrence),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    if (template.suggestedTags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: template.suggestedTags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              // Botón de selección
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRecurrenceText(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily:
        return 'Diario';
      case RecurrenceType.weekdays:
        return 'Entre semana';
      case RecurrenceType.weekends:
        return 'Fines de semana';
      case RecurrenceType.specificDays:
        return 'Días específicos';
      case RecurrenceType.everyNDays:
        return 'Cada N días';
    }
  }
}
