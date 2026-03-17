<p align="center">
  <a href="https://pub.dev/packages/dropdown_kit">
    <img src="https://img.shields.io/pub/v/dropdown_kit?color=blueviolet"/>
  </a>
  <a href="https://pub.dev/packages/dropdown_kit/score">
    <img src="https://img.shields.io/pub/points/dropdown_kit?logo=dart"/>
  </a>
  <a href="https://pub.dev/packages/dropdown_kit/score">
    <img src="https://img.shields.io/pub/likes/dropdown_kit?logo=dart"/>
  </a>
  <img src="https://img.shields.io/badge/Platform-Flutter-blue?logo=flutter"/>
  <a href="https://github.com/ashiqu-ali/dropdown_kit/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/ashiqu-ali/dropdown_kit"/>
  </a>
  <a href="https://github.com/ashiqu-ali/dropdown_kit">
    <img src="https://img.shields.io/github/stars/ashiqu-ali/dropdown_kit?style=social"/>
  </a>
</p>

# dropdown_kit

A complete Flutter dropdown kit — **single-select** and **multi-select** with built-in search, animated chip display, and **three presentation modes** (inline overlay, modal bottom sheet, alert dialog) — all from one widget and one `mode` enum. Zero `setState` inside the package — everything is `ValueNotifier`-driven.

---

## Features

- 🎯 Three modes: `overlay` · `bottomSheet` · `dialog` — one enum controls all
- 🔍 Built-in real-time search with instant filtering
- ✅ Single-select (`KitDropdown`) and multi-select (`KitDropdownMulti`)
- 🏷️ Removable chip display in the field for multi-select
- ⚡ Live checkboxes in bottom-sheet / dialog — updates without parent rebuild
- 📌 Overlay tracks the field while scrolling via `CompositedTransformFollower`
- ⬆️ Auto-flips above the field when there is no space below
- ⌨️ Keyboard-aware — never hides behind the soft keyboard
- 🧭 Root-navigator aware — bottom sheet renders above `BottomNavigationBar`
- 🎨 15+ colour, radius, shadow and padding parameters
- 🔑 Generic key type — `String`, `int`, `enum`, or any `T`
- 📦 Zero external dependencies beyond Flutter itself

---

## Installation

Run this command:

```bash
flutter pub add dropdown_kit
```

Or add manually to `pubspec.yaml`:

```yaml
dependencies:
  dropdown_kit: ^1.0.0
```

Then run `flutter pub get` and import:

```dart
import 'package:dropdown_kit/dropdown_kit.dart';
```

---

## Previews

### 1 · Overlay — Single Select

> Panel opens inline below (or above) the field and tracks it while scrolling.

<p align="center">
  <img src="https://raw.githubusercontent.com/ashiqu-ali/dropdown_kit/refs/heads/main/assets/overlay-single.png"/>
</p>

```dart
String? _country;

KitDropdown<String>(
  items: const [
    DropdownItem(key: 'IN', label: 'India'),
    DropdownItem(key: 'US', label: 'United States'),
    DropdownItem(key: 'UK', label: 'United Kingdom'),
  ],
  value: _country,
  label: 'Country',
  hint: 'Select a country',
  mode: DropdownMode.overlay,
  onChanged: (String key) => setState(() => _country = key),
)
```

---

### 2 · Bottom Sheet — Single Select

> Full-width sheet slides up above the `BottomNavigationBar`.

<p align="center">
  <img src="https://raw.githubusercontent.com/ashiqu-ali/dropdown_kit/refs/heads/main/assets/sheet-single.png"/>
</p>

```dart
KitDropdown<String>(
  items: _countries,
  value: _country,
  label: 'Country',
  mode: DropdownMode.bottomSheet,
  title: 'Choose Country',
  focusBorderColor: const Color(0xFF059669),
  selectedItemColor: const Color(0xFFD1FAE5),
  selectedItemTextColor: const Color(0xFF065F46),
  checkColor: const Color(0xFF059669),
  onChanged: (String key) => setState(() => _country = key),
)
```

---

### 3 · Dialog — Single Select

> Centred modal with built-in search. Auto-scrolls above the keyboard.

<p align="center">
  <img src="https://raw.githubusercontent.com/ashiqu-ali/dropdown_kit/refs/heads/main/assets/dialog-single.png"/>
</p>

```dart
KitDropdown<String>(
  items: _countries,
  value: _selected,
  label: 'Priority',
  mode: DropdownMode.dialog,
  title: 'Set Priority',
  searchEnabled: false,
  focusBorderColor: const Color(0xFFF59E0B),
  selectedItemColor: const Color(0xFFFEF3C7),
  selectedItemTextColor: const Color(0xFF92400E),
  checkColor: const Color(0xFFF59E0B),
  onChanged: (Priority key) => setState(() => _priority = key),
)
```

---

### 4 · Overlay — Multi Select

> Animated checkboxes with removable chips in the field. Done button commits the selection.

<p align="center">
  <img src="https://raw.githubusercontent.com/ashiqu-ali/dropdown_kit/refs/heads/main/assets/overlay-multi.png"/>
</p>

```dart

KitDropdownMulti<String>(
  items: _countries,
  value: _selected,
  label: 'Tech Stack',
  mode: DropdownMode.overlay,
  onChanged: (List<String> keys) => setState(() => _tags = keys),
)
```

---

### 5 · Bottom Sheet — Multi Select

> Live checkboxes update instantly. Parent only receives keys on Done.

<p align="center">
  <img src="https://raw.githubusercontent.com/ashiqu-ali/dropdown_kit/refs/heads/main/assets/sheet-multi.png"/>
</p>

```dart
KitDropdownMulti<String>(
  items: _countries,
  value: _selected,
  label: 'Countries',
  mode: DropdownMode.bottomSheet,
  title: 'Select Countries',
  chipColor: const Color(0xFFD1FAE5),
  chipTextColor: const Color(0xFF065F46),
  focusBorderColor: const Color(0xFF059669),
  checkColor: const Color(0xFF059669),
  onChanged: (List<String> keys) => setState(() => _selected = keys),
)
```

---

### 6 · Dialog — Multi Select

> Same live-checkbox behaviour as bottom sheet, presented as a centred modal.

<p align="center">
  <img src="https://raw.githubusercontent.com/ashiqu-ali/dropdown_kit/refs/heads/main/assets/dialog-multi.png"/>
</p>

```dart
KitDropdownMulti<String>(
  items: _countries,
  value: _selected,
  label: 'Countries',
  mode: DropdownMode.dialog,
  title: 'Select Countries',
  panelBorderRadius: BorderRadius.circular(16),
  chipColor: const Color(0xFFFEF3C7),
  chipTextColor: const Color(0xFF92400E),
  focusBorderColor: const Color(0xFFF59E0B),
  checkColor: const Color(0xFFF59E0B),
  onChanged: (List<String> keys) => setState(() => _selected = keys),
)
```

---

## DropdownItem

`DropdownItem<T>` is the only model you interact with. Your state holds only the raw key — never a `DropdownItem`.

```dart
// String key
const DropdownItem(key: 'IN', label: 'India')

// int key
const DropdownItem(key: 1, label: 'Administrator')

// enum key
enum Priority { low, medium, high }
const DropdownItem(key: Priority.high, label: 'High')
```

---

## DropdownMode

```dart
enum DropdownMode { overlay, bottomSheet, dialog }
```

| Mode | Behaviour |
|---|---|
| `overlay` | Panel anchors to the field, scrolls with it, auto-flips above if near bottom of screen |
| `bottomSheet` | Slides up from bottom via `showModalBottomSheet`. Renders above `BottomNavigationBar` |
| `dialog` | Centred modal via `showDialog`. Scrolls content above keyboard |

---

## API Reference

### KitDropdown\<T\> — Single Select

| Parameter | Type | Default | Description |
|---|---|---|---|
| `items` | `List<DropdownItem<T>>` | required | All selectable options |
| `value` | `T?` | `null` | Currently selected key. `null` shows hint |
| `onChanged` | `void Function(T key)` | required | Returns only the selected key |
| `mode` | `DropdownMode` | `overlay` | Presentation mode |
| `hint` | `String` | `'Select an option'` | Placeholder when nothing selected |
| `label` | `String?` | `null` | Label above the field |
| `title` | `String?` | `null` | Header in bottom-sheet / dialog |
| `searchEnabled` | `bool` | `true` | Show / hide search field |
| `searchHint` | `String` | `'Search...'` | Search field placeholder |
| `maxVisibleItems` | `int` | `5` | Rows before list scrolls |
| `itemHeight` | `double` | `48.0` | Row height |
| `fieldHeight` | `double` | `52.0` | Trigger field height |
| `borderRadius` | `BorderRadius` | `circular(12)` | Field corner radius |
| `dropdownBorderRadius` | `BorderRadius` | `circular(14)` | Overlay panel corner radius |
| `panelBorderRadius` | `BorderRadius` | `circular(20)` | Sheet / dialog corner radius |
| `fieldColor` | `Color` | `white` | Field background |
| `panelColor` | `Color` | `white` | Panel background |
| `borderColor` | `Color` | `#D1D5DB` | Field border when closed |
| `focusBorderColor` | `Color` | `#6366F1` | Field border + accent when open |
| `borderWidth` | `double` | `1.5` | Field border thickness |
| `selectedItemColor` | `Color` | `#EEF2FF` | Row background when selected |
| `selectedItemTextColor` | `Color` | `#6366F1` | Row text when selected |
| `checkColor` | `Color` | `#6366F1` | Tick icon colour |
| `textColor` | `Color` | `#111827` | Default item text colour |
| `hintColor` | `Color` | `#9CA3AF` | Hint text colour |
| `labelColor` | `Color` | `#374151` | Label text colour |
| `iconColor` | `Color` | `#6B7280` | Chevron colour |
| `dropdownShadow` | `List<BoxShadow>?` | built-in | Custom overlay shadow |
| `contentPadding` | `EdgeInsetsGeometry` | `h16 v14` | Padding inside field |
| `animationDuration` | `Duration` | `220ms` | Open/close animation speed |

### KitDropdownMulti\<T\> — Multi Select

All parameters from `KitDropdown` plus:

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `List<T>` | `[]` | Currently selected keys |
| `onChanged` | `void Function(List<T> keys)` | required | Returns all selected keys |
| `chipColor` | `Color` | `#EEF2FF` | Chip background in field |
| `chipTextColor` | `Color` | `#6366F1` | Chip label + remove icon colour |

> **Note:** In `overlay` mode `onChanged` is called on every tap. In `bottomSheet` / `dialog` mode it is called once when the user taps **Done**.

---

## ☕ Support

<p align="center">
  <a href="https://www.buymeacoffee.com/ashiqu.ali">
    <img src="https://img.buymeacoffee.com/button-api/?text=Buy%20me%20a%20coffee&emoji=%E2%98%95&slug=ashiqu.ali&button_colour=FFDD00&font_colour=000000&font_family=Lato&outline_colour=000000&coffee_colour=ffffff"/>
  </a>
</p>

---

## 🌐 Connect

<p align="center">
  <a href="https://www.linkedin.com/in/ashiqu-ali">
    <img src="https://cdn-icons-png.flaticon.com/512/174/174857.png" width="30"/>
  </a>
  &nbsp;&nbsp;
  <a href="https://ashiqu-ali.medium.com/">
    <img src="https://cdn-icons-png.flaticon.com/512/5968/5968906.png" width="30"/>
  </a>
  &nbsp;&nbsp;
  <a href="https://www.instagram.com/ashiqu_ali_">
    <img src="https://cdn-icons-png.flaticon.com/512/174/174855.png" width="30"/>
  </a>
  &nbsp;&nbsp;
  <a href="https://x.com/ashiquali007">
    <img src="https://cdn-icons-png.flaticon.com/512/733/733579.png" width="30"/>
  </a>
</p>
