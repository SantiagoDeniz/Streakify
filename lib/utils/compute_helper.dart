import 'package:flutter/foundation.dart';

class ComputeHelper {
  /// Runs a computation in a separate isolate to avoid blocking the UI thread.
  /// 
  /// [callback] is the function to run in the isolate.
  /// [message] is the argument to pass to the callback.
  static Future<R> run<Q, R>(ComputeCallback<Q, R> callback, Q message) async {
    return await compute(callback, message);
  }
  
  /// Helper to process a large list of items in chunks
  static Future<List<R>> processListInChunks<T, R>({
    required List<T> items,
    required R Function(List<T>) processor,
    int chunkSize = 100,
  }) async {
    final results = <R>[];
    
    for (var i = 0; i < items.length; i += chunkSize) {
      final end = (i + chunkSize < items.length) ? i + chunkSize : items.length;
      final chunk = items.sublist(i, end);
      
      // Run each chunk processing in an isolate
      final result = await compute(processor, chunk);
      results.add(result);
    }
    
    return results;
  }
}
