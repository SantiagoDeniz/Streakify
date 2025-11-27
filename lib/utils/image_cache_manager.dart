import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  final Map<String, Uint8List> _memoryCache = {};
  final int _maxCacheSize = 50 * 1024 * 1024; // 50MB
  int _currentCacheSize = 0;

  Future<Uint8List?> getBytes(String key) async {
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }
    return null;
  }

  void putBytes(String key, Uint8List bytes) {
    if (_currentCacheSize + bytes.length > _maxCacheSize) {
      _evictOldest();
    }
    _memoryCache[key] = bytes;
    _currentCacheSize += bytes.length;
  }

  void _evictOldest() {
    // Simple eviction strategy: remove first added (FIFO)
    // In a real app, LRU would be better
    if (_memoryCache.isNotEmpty) {
      final keyToRemove = _memoryCache.keys.first;
      final bytes = _memoryCache.remove(keyToRemove);
      if (bytes != null) {
        _currentCacheSize -= bytes.length;
      }
    }
  }

  void clear() {
    _memoryCache.clear();
    _currentCacheSize = 0;
  }
  
  // Precache common assets
  Future<void> precacheAssets(BuildContext context, List<String> assetPaths) async {
    for (final path in assetPaths) {
      await precacheImage(AssetImage(path), context);
    }
  }
}
