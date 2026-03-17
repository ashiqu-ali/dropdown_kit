## 0.0.1

* Initial release.
* `KitDropdown<T>` — single-select with overlay, bottom-sheet, and dialog modes.
* `KitDropdownMulti<T>` — multi-select with live chip display and live checkbox updates inside bottom-sheet / dialog.
* `DropdownItem<T>` — generic key/label model; key can be `String`, `int`, `enum`, or any type.
* `DropdownMode` enum — `overlay | bottomSheet | dialog`.
* Built-in search field with real-time filtering.
* ValueNotifier-driven state — zero `setState` in the widget internals.
* Overlay uses `CompositedTransformFollower` — panel tracks field while scrolling.
* Auto-flips above field when space below is insufficient.
* Keyboard-aware open direction — never hides behind soft keyboard.
* `useRootNavigator: true` on bottom-sheet — renders above `BottomNavigationBar`.
* Safe-area aware bottom padding for home-indicator devices.
* Live checkboxes in bottom-sheet / dialog via local `ValueNotifier` — no parent rebuild needed.
* `onChanged` fires on every tap in overlay mode; fires once on Done in sheet/dialog mode.
* `ClampingScrollPhysics` on list — no scroll conflict with parent scroll views.
