class PerformanceMonitor {
  static final List<PerformanceMetric> _metrics = [];
  static bool enabled = true;

  static Future<T> measure<T>(
    String operation,
    Future<T> Function() task,
  ) async {
    if (!enabled) return await task();

    final stopwatch = Stopwatch()..start();
    try {
      final result = await task();
      stopwatch.stop();
      _logMetric(operation, stopwatch.elapsedMilliseconds, true);
      return result;
    } catch (e) {
      stopwatch.stop();
      _logMetric(operation, stopwatch.elapsedMilliseconds, false);
      rethrow;
    }
  }

  static void _logMetric(String operation, int ms, bool success) {
    final metric = PerformanceMetric(
      operation: operation,
      durationMs: ms,
      success: success,
      timestamp: DateTime.now(),
    );
    _metrics.add(metric);

    // Console logging with performance indicators
    final status = success ? 'SUCCESS' : 'FAILED';

    if (ms > 300) {
      print(
        '[PERF WARNING] $operation took ${ms}ms - EXCEEDS 300ms requirement [$status]',
      );
    } else if (ms > 200) {
      print('[PERF SLOW] $operation took ${ms}ms [$status]');
    } else if (ms > 100) {
      print('[PERF OK] $operation took ${ms}ms [$status]');
    } else {
      print('[PERF FAST] $operation took ${ms}ms [$status]');
    }
  }

  static Map<String, dynamic> getSummary() {
    if (_metrics.isEmpty) {
      return {
        'total_operations': 0,
        'average_duration_ms': 0,
        'operations_under_300ms': 0,
        'operations_over_300ms': 0,
        'success_rate': 0.0,
        'requirement_met': false,
      };
    }

    final totalOps = _metrics.length;
    final avgDuration =
        _metrics.map((m) => m.durationMs).reduce((a, b) => a + b) / totalOps;
    final under300 = _metrics.where((m) => m.durationMs < 300).length;
    final over300 = _metrics.where((m) => m.durationMs >= 300).length;
    final successCount = _metrics.where((m) => m.success).length;
    final successRate = successCount / totalOps;

    return {
      'total_operations': totalOps,
      'average_duration_ms': avgDuration.round(),
      'operations_under_300ms': under300,
      'operations_over_300ms': over300,
      'success_rate': (successRate * 100).toStringAsFixed(1) + '%',
      'requirement_met': over300 == 0,
    };
  }

  static void printSummary() {
    print('\n' + '=' * 50);
    print('PERFORMANCE MONITORING SUMMARY');
    print('=' * 50);

    final summary = getSummary();
    summary.forEach((key, value) {
      print('$key: $value');
    });

    print('=' * 50 + '\n');
  }

  static List<PerformanceMetric> getMetrics() => List.unmodifiable(_metrics);

  static void clear() => _metrics.clear();
}

class PerformanceMetric {
  final String operation;
  final int durationMs;
  final bool success;
  final DateTime timestamp;

  PerformanceMetric({
    required this.operation,
    required this.durationMs,
    required this.success,
    required this.timestamp,
  });

  @override
  String toString() {
    final status = success ? 'SUCCESS' : 'FAILED';
    return '$operation: ${durationMs}ms [$status]';
  }
}
