import 'package:flutter/material.dart';
import '../core/dropdown_item.dart';
import '../core/dropdown_mode.dart';
import '../internal/picker_panel.dart';
import '../internal/sheet_dialog_wrapper.dart';
import '../internal/stateful_picker.dart';

// Default drop-shadow used when no custom [dropdownShadow] is provided.
const _kDefaultShadow = [
  BoxShadow(color: Color(0x1C000000), blurRadius: 20, offset: Offset(0, 6)),
  BoxShadow(color: Color(0x0D000000), blurRadius: 5,  offset: Offset(0, 2)),
];

/// A single-select dropdown field that supports three presentation modes.
///
/// The currently selected value is represented purely by its key [T] —
/// labels are resolved internally.  Your state only ever holds a `T?`.
///
/// ## Basic usage
///
/// ```dart
/// String? _country;
///
/// KitDropdown<String>(
///   items: const [
///     DropdownItem(key: 'IN', label: 'India'),
///     DropdownItem(key: 'US', label: 'United States'),
///   ],
///   value: _country,
///   onChanged: (String key) => setState(() => _country = key),
/// )
/// ```
///
/// ## Switching mode
///
/// ```dart
/// KitDropdown<String>(
///   mode: DropdownMode.bottomSheet,  // or .overlay (default) / .dialog
///   ...
/// )
/// ```
///
/// ## Using an enum key
///
/// ```dart
/// enum Role { admin, editor, viewer }
///
/// Role? _role;
///
/// KitDropdown<Role>(
///   items: const [
///     DropdownItem(key: Role.admin,  label: 'Admin'),
///     DropdownItem(key: Role.editor, label: 'Editor'),
///   ],
///   value: _role,
///   onChanged: (Role key) => setState(() => _role = key),
/// )
/// ```
class KitDropdown<T> extends StatefulWidget {
  const KitDropdown({
    super.key,
    required this.items,
    required this.onChanged,
    this.value,
    this.mode = DropdownMode.overlay,
    this.hint = 'Select an option',
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
    this.borderWidth = 1.5,
    this.dropdownShadow,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 14,
    ),
    this.animationDuration = const Duration(milliseconds: 220),
  });

  // ── Data ──────────────────────────────────────────────────────────────────

  /// All selectable options.
  final List<DropdownItem<T>> items;

  /// Currently selected key. Pass `null` to show the [hint].
  final T? value;

  /// Called with the newly selected key whenever the user picks an item.
  final void Function(T key) onChanged;

  // ── Behaviour ─────────────────────────────────────────────────────────────

  /// How the picker is presented. Defaults to [DropdownMode.overlay].
  final DropdownMode mode;

  /// Placeholder text shown in the field when [value] is null.
  final String hint;

  /// Optional label shown above the field. Turns accent colour when open.
  final String? label;

  /// Title shown in the bottom-sheet / dialog header.
  /// Falls back to [label] then [hint] if not provided.
  final String? title;

  /// Whether the built-in search field is shown. Defaults to `true`.
  final bool searchEnabled;

  /// Placeholder inside the search field.
  final String searchHint;

  // ── Shape ─────────────────────────────────────────────────────────────────

  /// Corner radius of the trigger field.
  final BorderRadius borderRadius;

  /// Corner radius of the inline overlay panel.
  final BorderRadius dropdownBorderRadius;

  /// Corner radius of the bottom-sheet / dialog container.
  final BorderRadius panelBorderRadius;

  // ── Sizing ────────────────────────────────────────────────────────────────

  /// Maximum number of items visible before the list becomes scrollable.
  final int maxVisibleItems;

  /// Height of each row in the picker list.
  final double itemHeight;

  /// Minimum height of the trigger field.
  final double fieldHeight;

  // ── Colours ───────────────────────────────────────────────────────────────

  /// Trigger field background.
  final Color fieldColor;

  /// Picker panel background.
  final Color panelColor;

  /// Row background colour when selected.
  final Color selectedItemColor;

  /// Row text colour when selected.
  final Color selectedItemTextColor;

  /// Trailing tick colour (single) or checkbox fill (multi).
  final Color checkColor;

  /// Hint / placeholder text colour.
  final Color hintColor;

  /// Label text colour when the dropdown is closed.
  final Color labelColor;

  /// Chevron icon colour when the dropdown is closed.
  final Color iconColor;

  /// Field border colour when closed.
  final Color borderColor;

  /// Field border colour + accent colour when open.
  final Color focusBorderColor;

  /// Default item text colour.
  final Color textColor;

  /// Field border stroke width.
  final double borderWidth;

  /// Custom shadow for the overlay panel.
  /// Defaults to a subtle two-layer drop shadow.
  final List<BoxShadow>? dropdownShadow;

  // ── Misc ──────────────────────────────────────────────────────────────────

  /// Padding inside the trigger field.
  final EdgeInsetsGeometry contentPadding;

  /// Duration of the field border animation and the overlay open/close.
  final Duration animationDuration;

  @override
  State<KitDropdown<T>> createState() => _KitDropdownState<T>();
}

class _KitDropdownState<T> extends State<KitDropdown<T>>
    with SingleTickerProviderStateMixin {
  // ── Animation ─────────────────────────────────────────────────────────────
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _chevronAnim;

  // ── Overlay state ─────────────────────────────────────────────────────────
  final _fieldKey   = GlobalKey();
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  OverlayEntry? _overlayEntry;

  // ValueNotifiers — zero setState
  final _isOpen   = ValueNotifier<bool>(false);
  final _filtered = ValueNotifier<List<DropdownItem<T>>>([]);

  // Resolves display label from the current key.
  String get _selectedLabel {
    if (widget.value == null) return widget.hint;
    return widget.items
        .firstWhere(
          (e) => e.key == widget.value,
          orElse: () =>
              DropdownItem<T>(key: widget.value as T, label: widget.hint),
        )
        .label;
  }

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
  void didUpdateWidget(KitDropdown<T> old) {
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

  // ── Overlay helpers ───────────────────────────────────────────────────────

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
      final rect     = _fieldRect();
      final screenH  = MediaQuery.of(ctx).size.height;
      final below    = screenH - rect.bottom - 8;
      final above    = rect.top - 8;
      final totalH   = widget.itemHeight * widget.maxVisibleItems +
          (widget.searchEnabled ? 60.0 : 0.0) + 12;
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
                      selectedKey: widget.value,
                      onPick: _pickSingle,
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
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,   // renders above BottomNavigationBar
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
          selectedKey: widget.value,
          onPick: _pickSingle,
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
        ),
      ),
    ).whenComplete(() => _isOpen.value = false);
  }

  // ── Dialog ────────────────────────────────────────────────────────────────

  void _openDialog() {
    _isOpen.value = true;
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
          selectedKey: widget.value,
          onPick: _pickSingle,
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
        ),
      ),
    ).whenComplete(() => _isOpen.value = false);
  }

  // ── Common ────────────────────────────────────────────────────────────────

  void _pickSingle(T key) {
    widget.onChanged(key);
    switch (widget.mode) {
      case DropdownMode.overlay:     _closeOverlay();
      case DropdownMode.bottomSheet:
      case DropdownMode.dialog:
        Navigator.of(context, rootNavigator: true).pop();
    }
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
              height: widget.fieldHeight,
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
                    child: Text(
                      _selectedLabel,
                      style: TextStyle(
                        fontSize: 15,
                        color: widget.value == null
                            ? widget.hintColor
                            : widget.textColor,
                        fontWeight: widget.value == null
                            ? FontWeight.w400
                            : FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
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
