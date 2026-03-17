/// A single item in a [KitDropdown] or [KitDropdownMulti] picker.
///
/// [T] is the type of the key — use `String`, `int`, an `enum`, or any
/// other comparable type. The [label] is displayed in the field and list;
/// the [key] is what your code receives via `onChanged`.
///
/// ```dart
/// // String key
/// const DropdownItem(key: 'IN', label: 'India')
///
/// // int key
/// const DropdownItem(key: 1, label: 'Administrator')
///
/// // enum key
/// enum Priority { low, medium, high }
/// const DropdownItem(key: Priority.high, label: 'High')
/// ```
class DropdownItem<T> {
  const DropdownItem({
    required this.key,
    required this.label,
  });

  /// The value returned to your code via `onChanged`.
  ///
  /// This can be any type — `String`, `int`, `enum`, etc.
  /// Equality is compared on this field only.
  final T key;

  /// Text shown inside the dropdown field and picker list.
  final String label;

  @override
  bool operator ==(Object other) =>
      other is DropdownItem<T> && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'DropdownItem(key: $key, label: $label)';
}
