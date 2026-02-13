// Add this somewhere global, e.g., utils/extensions.dart
extension NullableExtension<T> on T? {
  void let(void Function(T value) block) {
    final value = this;
    if (value != null) block(value);
  }
}