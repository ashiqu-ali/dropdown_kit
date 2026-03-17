/// Controls how the picker panel is presented when the user taps the field.
///
/// Pass this to the `mode` parameter of [KitDropdown] or [KitDropdownMulti].
///
/// ```dart
/// KitDropdown<String>(
///   mode: DropdownMode.bottomSheet,  // or .overlay / .dialog
///   ...
/// )
/// ```
enum DropdownMode {
  /// Picker opens as an animated panel directly below (or above) the field,
  /// anchored to the field's position on screen.
  ///
  /// Best for forms where the dropdown is surrounded by other widgets
  /// and you want the picker to feel inline.
  overlay,

  /// Picker slides up as a modal bottom sheet via [showModalBottomSheet].
  ///
  /// Uses `useRootNavigator: true` so it renders above any
  /// [BottomNavigationBar]. Safe-area padding is applied automatically
  /// for home-indicator devices.
  ///
  /// Best for mobile-first UIs where a full-width bottom sheet feels natural.
  bottomSheet,

  /// Picker appears as a centred [AlertDialog]-style modal via [showDialog].
  ///
  /// Best for tablet layouts or when you want a focused, dismissible overlay
  /// that greys out the rest of the screen.
  dialog,
}
