import 'package:flutter/material.dart';
import '../services/activity_service.dart';

/// Widget para seleccionar y gestionar tags
class TagSelector extends StatefulWidget {
  final List<String> selectedTags;
  final Function(List<String>) onTagsChanged;

  const TagSelector({
    super.key,
    required this.selectedTags,
    required this.onTagsChanged,
  });

  @override
  State<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends State<TagSelector> {
  final ActivityService _activityService = ActivityService();
  final TextEditingController _tagController = TextEditingController();
  List<String> _allTags = [];
  List<String> _filteredTags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    final tags = await _activityService.getAllTags();
    setState(() {
      _allTags = tags;
      _filteredTags = tags;
      _isLoading = false;
    });
  }

  void _filterTags(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTags = _allTags;
      } else {
        _filteredTags = _allTags
            .where((tag) => tag.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _addTag(String tag) {
    if (tag.trim().isEmpty) return;

    final cleanTag = tag.trim();
    if (!widget.selectedTags.contains(cleanTag)) {
      final updatedTags = [...widget.selectedTags, cleanTag];
      widget.onTagsChanged(updatedTags);

      // Actualizar lista local
      if (!_allTags.contains(cleanTag)) {
        setState(() {
          _allTags.add(cleanTag);
          _filteredTags.add(cleanTag);
        });
      }

      _tagController.clear();
    }
  }

  void _removeTag(String tag) {
    final updatedTags = widget.selectedTags.where((t) => t != tag).toList();
    widget.onTagsChanged(updatedTags);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags seleccionados
        if (widget.selectedTags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedTags.map((tag) {
              return TagChip(
                tag: tag,
                onRemove: () => _removeTag(tag),
              );
            }).toList(),
          ),

        const SizedBox(height: 12),

        // Campo para agregar tag
        TextField(
          controller: _tagController,
          decoration: InputDecoration(
            labelText: 'Agregar tag',
            hintText: 'Escribe y presiona Enter',
            prefixIcon: const Icon(Icons.local_offer),
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(_tagController.text),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: _filterTags,
          onSubmitted: _addTag,
        ),

        const SizedBox(height: 12),

        // Sugerencias de tags
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_filteredTags.isNotEmpty) ...[
          Text(
            'Tags sugeridos:',
            style: TextStyle(
              fontSize: 12,
              color: theme.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _filteredTags
                .where((tag) => !widget.selectedTags.contains(tag))
                .take(10)
                .map((tag) {
              return InkWell(
                onTap: () => _addTag(tag),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_offer, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        tag,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

/// Chip visual para un tag
class TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const TagChip({
    super.key,
    required this.tag,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.blueGrey[700] : Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_offer,
              size: 14,
              color: isDark ? Colors.blueGrey[200] : Colors.blueGrey[700],
            ),
            const SizedBox(width: 4),
            Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.blueGrey[200] : Colors.blueGrey[700],
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isDark ? Colors.blueGrey[200] : Colors.blueGrey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
