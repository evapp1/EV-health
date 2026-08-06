/// Returns an immutable snapshot of [values].
List<T> immutableList<T>(Iterable<T> values) => List<T>.unmodifiable(values);

/// Compares lists by value and order.
bool domainListEquals<T>(List<T> left, List<T> right) {
  if (identical(left, right)) {
    return true;
  }
  if (left.length != right.length) {
    return false;
  }
  for (var index = 0; index < left.length; index += 1) {
    if (left[index] != right[index]) {
      return false;
    }
  }
  return true;
}

/// Validates a required, trimmed string.
String requireText(String value, String name) {
  if (value.isEmpty || value.trim() != value) {
    throw ArgumentError.value(value, name, 'must be non-empty and trimmed');
  }
  return value;
}

/// Validates an optional, trimmed string.
String? requireOptionalText(String? value, String name) {
  if (value == null) {
    return null;
  }
  return requireText(value, name);
}

/// Validates a UTC timestamp.
DateTime requireUtc(DateTime value, String name) {
  if (!value.isUtc) {
    throw ArgumentError.value(value, name, 'must be UTC');
  }
  return value;
}

/// Validates that [earlier] does not occur after [later].
void requireOrdered(
  DateTime earlier,
  String earlierName,
  DateTime later,
  String laterName,
) {
  if (earlier.isAfter(later)) {
    throw ArgumentError('$earlierName must not be after $laterName');
  }
}

/// Validates that a list contains no duplicate values.
List<T> requireUnique<T>(Iterable<T> values, String name) {
  final snapshot = immutableList(values);
  if (snapshot.toSet().length != snapshot.length) {
    throw ArgumentError.value(values, name, 'must not contain duplicates');
  }
  return snapshot;
}
