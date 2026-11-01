import 'dart:async';

import 'package:flutter/foundation.dart';

/// Utility class for safe async operations
class SafeAsync {
  /// Debounce function calls
  static Timer? _debounceTimer;

  /// Cancel any pending debounced operations
  static void cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Execute an async operation with timeout and error handling
  static Future<T?> execute<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
    T? defaultValue,
    bool logErrors = true,
    String? operationName,
  }) async {
    try {
      final result = await operation().timeout(timeout);
      return result;
    } on TimeoutException catch (e) {
      if (logErrors && kDebugMode) {
        debugPrint('Timeout in ${operationName ?? 'operation'}: $e');
      }
      return defaultValue;
    } catch (e) {
      if (logErrors && kDebugMode) {
        debugPrint('Error in ${operationName ?? 'operation'}: $e');
      }
      return defaultValue;
    }
  }

  /// Execute multiple async operations concurrently with error handling
  static Future<List<T?>> executeAll<T>(
    List<Future<T> Function()> operations, {
    Duration timeout = const Duration(seconds: 30),
    bool logErrors = true,
  }) async {
    final futures = operations.map(
      (op) => execute(op, timeout: timeout, logErrors: logErrors),
    );

    return await Future.wait(futures);
  }
}
