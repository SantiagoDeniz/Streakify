import 'package:flutter/material.dart';

class LazyListController<T> extends ChangeNotifier {
  final Future<List<T>> Function(int page, int pageSize) fetchItems;
  final int pageSize;
  
  List<T> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  Object? _error;

  LazyListController({
    required this.fetchItems,
    this.pageSize = 20,
  });

  List<T> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  Object? get error => _error;

  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newItems = await fetchItems(_currentPage, pageSize);
      
      if (newItems.length < pageSize) {
        _hasMore = false;
      }
      
      _items.addAll(newItems);
      _currentPage++;
    } catch (e) {
      _error = e;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _items = [];
    _currentPage = 0;
    _hasMore = true;
    _error = null;
    await loadMore();
  }

  void removeItem(T item) {
    _items.remove(item);
    notifyListeners();
  }

  void updateItem(T oldItem, T newItem) {
    final index = _items.indexOf(oldItem);
    if (index != -1) {
      _items[index] = newItem;
      notifyListeners();
    }
  }
  
  void addItem(T item) {
    _items.insert(0, item);
    notifyListeners();
  }
}
