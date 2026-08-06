/// Indicates that a write was attempted through a non-persisting demo port.
final class DemoRepositoryWriteException implements Exception {
  /// Creates a typed prohibited-operation error for [operation].
  const DemoRepositoryWriteException(this.operation);

  /// Repository operation that was rejected.
  final String operation;

  @override
  String toString() =>
      'DemoRepositoryWriteException: $operation is prohibited because demo '
      'repositories are read-only and non-persisting.';
}
