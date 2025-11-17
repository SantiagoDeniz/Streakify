import 'package:flutter/material.dart';
import '../services/activity_service.dart';

/// Widget para agregar y gestionar tags
class TagInput extends StatefulWidget {
  final List<String> initialTags;
  final Function(List<String>) onTagsChanged;

  const TagInput({
    Key? key,
    required this.initialTags,
    required this.onTagsChanged,
  }) : super(key: key);

  @override
  State<TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<TagInput> {
  final TextEditingController _controller = TextEditingController();
  final ActivityService _activityService = ActivityService();
  List<String> _tags = [];
  List<String> _suggestions = [];
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.initialTags);
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    final allTags = await _activityService.getAllTags();
    setState(() {
      _suggestions = allTags;
    });
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim().toLowerCase();
    if (trimmedTag.isEmpty) return;
    if (_tags.contains(trimmedTag)) return;

    setState(() {
      _tags.add(trimmedTag);
      _controller.clear();
      _showSuggestions = false;
    });
    widget.onTagsChanged(_tags);
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  List<String> _getFilteredSuggestions() {
    if (_controller.text.isEmpty) return [];

    final query = _controller.text.toLowerCase();
    return _suggestions
        .where((tag) => tag.contains(query) && !_tags.contains(tag))
        .take(5)
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSuggestions = _getFilteredSuggestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Tags',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        // Tags actuales
        if (_tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) => _buildTagChip(tag)).toList(),
            ),
          ),
        // Campo de entrada
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: 'Agregar tag...',
            prefixIcon: const Icon(Icons.label_outline),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _addTag(_controller.text),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _showSuggestions = value.isNotEmpty;
            });
          },
          onSubmitted: _addTag,
        ),
        // Sugerencias
        if (_showSuggestions && filteredSuggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredSuggestions
                  .map((tag) => _buildSuggestionChip(tag))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Chip(
      label: Text(tag),
      deleteIcon: const Icon(Icons.close, size: 18),
      onDeleted: () => _removeTag(tag),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildSuggestionChip(String tag) {
    return ActionChip(
      label: Text(tag),
      avatar: const Icon(Icons.add, size: 16),
      onPressed: () => _addTag(tag),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }
}
