import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';

/// Widget para seleccionar una categoría
class CategorySelector extends StatefulWidget {
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;

  const CategorySelector({
    Key? key,
    this.selectedCategoryId,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    await _categoryService.ensureDefaultCategories();
    final categories = await _categoryService.getAllCategories();
    setState(() {
      _categories = categories;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Categoría',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // Opción para no seleccionar categoría
            _buildCategoryChip(
              context: context,
              category: null,
              isSelected: widget.selectedCategoryId == null,
            ),
            // Todas las categorías disponibles
            ..._categories.map(
              (category) => _buildCategoryChip(
                context: context,
                category: category,
                isSelected: widget.selectedCategoryId == category.id,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip({
    required BuildContext context,
    required Category? category,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (category == null) {
      // Chip para "Sin categoría"
      return FilterChip(
        label: const Text('Sin categoría'),
        selected: isSelected,
        onSelected: (_) => widget.onCategorySelected(null),
        backgroundColor: Colors.grey.withOpacity(0.2),
        selectedColor: Colors.grey.withOpacity(0.4),
        checkmarkColor: isDark ? Colors.white : Colors.black,
      );
    }

    return FilterChip(
      avatar: Icon(
        category.icon,
        color: isSelected
            ? (isDark ? Colors.white : Colors.black)
            : category.color,
        size: 20,
      ),
      label: Text(category.name),
      selected: isSelected,
      onSelected: (_) => widget.onCategorySelected(category.id),
      backgroundColor: category.color.withOpacity(0.1),
      selectedColor: category.color.withOpacity(0.3),
      checkmarkColor: isDark ? Colors.white : Colors.black,
      side: BorderSide(
        color: isSelected ? category.color : category.color.withOpacity(0.3),
        width: isSelected ? 2 : 1,
      ),
    );
  }
}
