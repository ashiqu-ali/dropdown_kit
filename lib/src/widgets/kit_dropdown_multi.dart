import 'package:flutter/material.dart';
import '../core/dropdown_item.dart';
import '../core/dropdown_mode.dart';
import '../internal/kit_chip.dart';
import '../internal/picker_panel.dart';
import '../internal/sheet_dialog_wrapper.dart';
import '../internal/stateful_picker.dart';

const _kDefaultShadow = [
  BoxShadow(color: Color(0x1C000000), blurRadius: 20, offset: Offset(0, 6)),
  BoxShadow(color: Color(0x0D000000), blurRadius: 5,  offset: Offset(0, 2)),
];

/// A multi-select dropdown field that supports three presentation modes.
///
/// Selected items are displayed as removable chips inside the trigger field.
/// The value you work with is simply `List<T>` — labels are resolved internally.
///
/// ## Basic usage
///
/// ```dart
/// List<String> _tags = [];
///
/// KitDropdownMulti<String>(
///   items: const [
///     DropdownItem(key: 'flutter', label: 'Flutter'),
///     DropdownItem(key: 'dart',    label: 'Dart'),
///   ],
///   value: _tags,
///   onChanged: (List<String> keys) => setState(() => _tags = keys),
/// )
/// ```
///
/// ## Live checkboxes in bottom-sheet / dialog
///
/// Checkboxes update **instantly** as the user taps — without waiting for the
/// parent to rebuild. This works via a local [ValueNotifier] that lives for the
/// lifetime of the sheet / dialog session.  The parent's `onChanged` is called
/// only when the user taps **Done**.
///
/// ## Switching mode
///
/// ```dart
/// KitDropdownMulti<String>(
///   mode: DropdownMode.bottomSheet,
///   title: 'Select Tags',
///   ...
/// )
/// ```
class KitDropdownMulti<T> extends StatefulWidget {
  const KitDropdownMulti({
    super.key,
    required this.items,
    required this.onChanged,
    this.value = const [],
    this.mode = DropdownMode.overlay,
    this.hint = 'Select options',
    this.label,
    this.title,
    this.searchEnabled = true,
    this.searchHint = 'Search...',
    // ── Field shape ──────────────────────────────────────────────────────────
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    // ── Overlay panel shape ──────────────────────────────────────────────────
    this.dropdownBorderRadius = const BorderRadius.all(Radius.circular(14)),
    // ── Bottom-sheet / dialog shape ──────────────────────────────────────────
    this.panelBorderRadius = const BorderRadius.all(Radius.circular(20)),
    // ── Sizing ───────────────────────────────────────────────────────────────
    this.maxVisibleItems = 5,
    this.itemHeight = 48.0,
    this.fieldHeight = 52.0,
    // ── Colours ──────────────────────────────────────────────────────────────
    this.fieldColor = Colors.white,
    this.panelColor = Colors.white,
    this.selectedItemColor = const Color(0xFFEEF2FF),
    this.selectedItemTextColor = const Color(0xFF6366F1),
    this.checkColor = const Color(0xFF6366F1),
    this.hintColor = const Color(0xFF9CA3AF),
    this.labelColor = const Color(0xFF374151),
    this.iconColor = const Color(0xFF6B7280),
    this.borderColor = const Color(0xFFD1D5DB),
    this.focusBorderColor = const Color(0xFF6366F1),
    this.textColor = const Color(0xFF111827),
    this.chipColor = const Color(0xFFEEF2FF),
    this.chipTextColor = const Color(0xFF6366F1),
    this.borderWidth = 1.5,
    this.dropdownShadow,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 10,
    ),
    this.animationDuration = const Duration(milliseconds: 220),
  });

  // ── Data ──────────────────────────────────────────────────────────────────

  /// All selectable options.
  final List<DropdownItem<T>> items;

  /// Currently selected keys. Pass `[]` to start empty.
  final List<T> value;

  /// Called with the updated list of selected keys whenever the selection changes.
  ///
  /// - In **overlay** mode: called on every individual tap.
  /// - In **bottomSheet / dialog** mode: called once when the user taps **Done**.
  final void Function(List<T> keys) onChanged;

  // ── Behaviour ─────────────────────────────────────────────────────────────

  /// How the picker is presented. Defaults to [DropdownMode.overlay].
  final DropdownMode mode;

  /// Placeholder shown when no items are selected.
  final String hint;

  /// Optional label above the field.
  final String? label;

  /// Header title in bottom-sheet / dialog. Falls back to [label] then [hint].
  final String? title;

  /// Whether the built-in search field is shown.
  final bool searchEnabled;

  /// Placeholder inside the search field.
  final String searchHint;

  // ── Shape ─────────────────────────────────────────────────────────────────

  final BorderRadius borderRadius;
  final BorderRadius dropdownBorderRadius;
  final BorderRadius panelBorderRadius;

  // ── Sizing ────────────────────────────────────────────────────────────────

  final int maxVisibleItems;
  final double itemHeight;
  final double fieldHeight;

  // ── Colours ───────────────────────────────────────────────────────────────

  final Color fieldColor;
  final Color panelColor;
  final Color selectedItemColor;
  final Color selectedItemTextColor;
  final Color checkColor;
  final Color hintColor;
  final Color labelColor;
  final Color iconColor;
  final Color borderColor;
  final Color focusBorderColor;
  final Color textColor;

  /// Background colour of the chips displayed in the field.
  final Color chipColor;

  /// Text + remove-icon colour of the chips in the field.
  final Color chipTextColor;

  final double borderWidth;
  final List<BoxShadow>? dropdownShadow;
  final EdgeInsetsGeometry contentPadding;
  final Duration animationDuration;

  @override
  State<KitDropdownMulti<T>> createState() => _KitDropdownMultiState<T>();
}

class _KitDropdownMultiState<T> extends State<KitDropdownMulti<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _chevronAnim;

  final _fieldKey    = GlobalKey();
  final _searchCtrl  = TextEditingController();
  final _searchFocus = FocusNode();
  OverlayEntry? _overlayEntry;

  final _isOpen   = ValueNotifier<bool>(false);
  final _filtered = ValueNotifier<List<DropdownItem<T>>>([]);

  // Resolves chip labels from current keys.
  List<String> get _selectedLabels => widget.value
      .map((key) => widget.items
          .firstWhere(
            (e) => e.key == key,
            orElse: () => DropdownItem<T>(key: key, label: key.toString()),
          )
          .label)
      .toList();

  @override
  void initState() {
    super.initState();
    _filtered.value = widget.items;
    _animCtrl  = AnimationController(vsync: this, duration: widget.animationDuration);
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.93, end: 1.0).animate(
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _chevronAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(KitDropdownMulti<T> old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) _filtered.value = widget.items;
    _safeRebuildOverlay();
  }

  @override
  void dispose() {
    _forceCloseOverlay();
    _animCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _isOpen.dispose();
    _filtered.dispose();
    super.dispose();
  }

  void _safeRebuildOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _overlayEntry?.markNeedsBuild();
    });
  }

  Rect _fieldRect() {
    final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Rect.zero;
    final pos = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(pos.dx, pos.dy, box.size.width, box.size.height);
  }

  // ── Open dispatcher ───────────────────────────────────────────────────────

  void _open() {
    _filtered.value = widget.items;
    _searchCtrl.clear();
    switch (widget.mode) {
      case DropdownMode.overlay:     _openOverlay();
      case DropdownMode.bottomSheet: _openBottomSheet();
      case DropdownMode.dialog:      _openDialog();
    }
  }

  void _toggle() {
    if (widget.mode == DropdownMode.overlay) {
      _isOpen.value ? _closeOverlay() : _open();
    } else {
      _open();
    }
  }

  // ── Overlay ───────────────────────────────────────────────────────────────

  void _openOverlay() {
    if (_isOpen.value) return;
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
    _animCtrl.forward();
    _isOpen.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.searchEnabled && mounted) _searchFocus.requestFocus();
    });
  }

  void _closeOverlay() {
    if (!_isOpen.value) return;
    _isOpen.value = false;
    _animCtrl.reverse().then((_) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _forceCloseOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isOpen.value = false;
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(builder: (ctx) {
      final rect    = _fieldRect();
      final screenH = MediaQuery.of(ctx).size.height;
      final below   = screenH - rect.bottom - 8;
      final above   = rect.top - 8;
      final totalH  = widget.itemHeight * widget.maxVisibleItems +
          (widget.searchEnabled ? 60.0 : 0.0) + 64;
      final openBelow = below >= totalH || below >= above;

      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeOverlay,
        child: Stack(children: [
          Positioned(
            left:   rect.left,
            top:    openBelow ? rect.bottom + 6 : null,
            bottom: openBelow ? null : screenH - rect.top + 6,
            width:  rect.width,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                alignment: openBelow
                    ? Alignment.topCenter
                    : Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {},
                  child: ValueListenableBuilder<List<DropdownItem<T>>>(
                    valueListenable: _filtered,
                    builder: (_, filtered, __) => PickerPanel<T>(
                      filtered: filtered,
                      selectedKeys: widget.value,
                      onPick: _toggleKey,
                      searchCtrl: _searchCtrl,
                      searchFocus: _searchFocus,
                      searchEnabled: widget.searchEnabled,
                      searchHint: widget.searchHint,
                      onSearch: _onSearch,
                      itemHeight: widget.itemHeight,
                      maxVisibleItems: widget.maxVisibleItems,
                      borderRadius: widget.dropdownBorderRadius,
                      bgColor: widget.panelColor,
                      selectedItemColor: widget.selectedItemColor,
                      selectedItemTextColor: widget.selectedItemTextColor,
                      checkColor: widget.checkColor,
                      textColor: widget.textColor,
                      accentColor: widget.focusBorderColor,
                      shadow: widget.dropdownShadow ?? _kDefaultShadow,
                      multiSelect: true,
                      onDone: _closeOverlay,
                      selectedCount: widget.value.length,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      );
    });
  }

  // ── Bottom-sheet ──────────────────────────────────────────────────────────

  void _openBottomSheet() {
    _isOpen.value = true;
    // Local notifier seeded with current selection — owned by this session.
    final localSelected =
        ValueNotifier<List<T>>(List<T>.from(widget.value));

    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SheetDialogWrapper(
        mode: DropdownMode.bottomSheet,
        borderRadius: widget.panelBorderRadius,
        bgColor: widget.panelColor,
        accentColor: widget.focusBorderColor,
        title: widget.title ?? widget.label ?? widget.hint,
        child: StatefulPicker<T>(
          items: widget.items,
          selectedKeysNotifier: localSelected,
          onPick: (key) => _toggleLocalKey(localSelected, key),
          onDone: () {
            widget.onChanged(localSelected.value);
            Navigator.of(context, rootNavigator: true).pop();
          },
          searchEnabled: widget.searchEnabled,
          searchHint: widget.searchHint,
          itemHeight: widget.itemHeight,
          maxVisibleItems: widget.maxVisibleItems,
          selectedItemColor: widget.selectedItemColor,
          selectedItemTextColor: widget.selectedItemTextColor,
          checkColor: widget.checkColor,
          textColor: widget.textColor,
          accentColor: widget.focusBorderColor,
          bgColor: widget.panelColor,
          multiSelect: true,
        ),
      ),
    ).whenComplete(() {
      localSelected.dispose();
      _isOpen.value = false;
    });
  }

  // ── Dialog ────────────────────────────────────────────────────────────────

  void _openDialog() {
    _isOpen.value = true;
    final localSelected =
        ValueNotifier<List<T>>(List<T>.from(widget.value));

    showDialog(
      context: context,
      builder: (_) => SheetDialogWrapper(
        mode: DropdownMode.dialog,
        borderRadius: widget.panelBorderRadius,
        bgColor: widget.panelColor,
        accentColor: widget.focusBorderColor,
        title: widget.title ?? widget.label ?? widget.hint,
        child: StatefulPicker<T>(
          items: widget.items,
          selectedKeysNotifier: localSelected,
          onPick: (key) => _toggleLocalKey(localSelected, key),
          onDone: () {
            widget.onChanged(localSelected.value);
            Navigator.of(context, rootNavigator: true).pop();
          },
          searchEnabled: widget.searchEnabled,
          searchHint: widget.searchHint,
          itemHeight: widget.itemHeight,
          maxVisibleItems: widget.maxVisibleItems,
          selectedItemColor: widget.selectedItemColor,
          selectedItemTextColor: widget.selectedItemTextColor,
          checkColor: widget.checkColor,
          textColor: widget.textColor,
          accentColor: widget.focusBorderColor,
          bgColor: widget.panelColor,
          multiSelect: true,
        ),
      ),
    ).whenComplete(() {
      localSelected.dispose();
      _isOpen.value = false;
    });
  }

  // ── Common ────────────────────────────────────────────────────────────────

  /// Toggles a key inside a local session notifier (bottom-sheet / dialog).
  void _toggleLocalKey(ValueNotifier<List<T>> notifier, T key) {
    final current = List<T>.from(notifier.value);
    final idx = current.indexOf(key);
    if (idx >= 0) {
      current.removeAt(idx);
    } else {
      current.add(key);
    }
    notifier.value = current;
  }

  /// Toggles a key directly in the overlay (calls onChanged immediately).
  void _toggleKey(T key) {
    final current = List<T>.from(widget.value);
    final idx = current.indexOf(key);
    if (idx >= 0) {
      current.removeAt(idx);
    } else {
      current.add(key);
    }
    widget.onChanged(current);
    _safeRebuildOverlay();
  }

  void _onSearch(String query) {
    _filtered.value = query.isEmpty
        ? widget.items
        : widget.items
            .where((e) =>
                e.label.toLowerCase().contains(query.toLowerCase()) ||
                e.key.toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
    _safeRebuildOverlay();
  }

  // ── Field ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final labels = _selectedLabels;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional label
        if (widget.label != null)
          ValueListenableBuilder<bool>(
            valueListenable: _isOpen,
            builder: (_, open, __) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                widget.label!,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: open ? widget.focusBorderColor : widget.labelColor,
                ),
              ),
            ),
          ),

        // Trigger field
        GestureDetector(
          key: _fieldKey,
          onTap: _toggle,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isOpen,
            builder: (_, open, __) => AnimatedContainer(
              duration: widget.animationDuration,
              constraints:
                  BoxConstraints(minHeight: widget.fieldHeight),
              decoration: BoxDecoration(
                color: widget.fieldColor,
                borderRadius: widget.borderRadius,
                border: Border.all(
                  color: open ? widget.focusBorderColor : widget.borderColor,
                  width: widget.borderWidth,
                ),
              ),
              child: Padding(
                padding: widget.contentPadding,
                child: Row(children: [
                  Expanded(
                    child: widget.value.isEmpty
                        ? Text(
                            widget.hint,
                            style: TextStyle(
                              fontSize: 15,
                              color: widget.hintColor,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: List.generate(
                              widget.value.length,
                              (i) => KitChip(
                                label: labels[i],
                                color: widget.chipColor,
                                textColor: widget.chipTextColor,
                                onRemove: () {
                                  final updated =
                                      List<T>.from(widget.value)
                                        ..removeAt(i);
                                  widget.onChanged(updated);
                                },
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: Tween<double>(begin: 0, end: 0.5)
                        .animate(_chevronAnim),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: open
                          ? widget.focusBorderColor
                          : widget.iconColor,
                      size: 22,
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
