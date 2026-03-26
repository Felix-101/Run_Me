class NetworkRetry {
  final int maxRetries;
  final Duration delay;

  NetworkRetry({
    this.maxRetries = 2,
    this.delay = const Duration(milliseconds: 400),
  });

  Future<T> networkRetry<T>(Future<T> Function() call) async {
    Object? lastError;
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        return await call();
      } catch (e) {
        lastError = e;
        if (attempt == maxRetries) rethrow;
        await Future<void>.delayed(delay);
      }
    }
    throw lastError ?? Exception('networkRetry');
  }
}
