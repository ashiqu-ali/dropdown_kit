import 'package:flutter/material.dart';
import '../core/dropdown_item.dart';
import 'picker_panel.dart';

/// A self-contained picker widget used inside bottom-sheet and dialog routes.
///
/// Because the sheet / dialog lives in a **separate route**, it cannot receive
/// rebuilds from the parent widget tree.  For multi-select this widget accepts
/// a [ValueNotifier<List<T>>] ([selectedKeysNotifier]) so checkboxes update
/// live as the user taps — no parent rebuild required.
///
/// This widget owns its own search [TextEditingController] and filtered list
/// [ValueNotifier] so each sheet / dialog session starts with a clean search.
class StatefulPicker<T> extends StatefulWidget {
  const StatefulPicker({
    super.key,
    required this.items,
    required this.onPick,
    this.selectedKey,
    this.selectedKeysNotifier,
    this.onDone,
    required this.searchEnabled,
    required this.searchHint,
    required this.itemHeight,
    required this.maxVisibleItems,
    required this.selectedItemColor,
    required this.selectedItemTextColor,
    required this.checkColor,
    required this.textColor,
    required this.accentColor,
    required this.bgColor,
    this.multiSelect = false,
  });

  /// Full list of items to pick from.
  final List<DropdownItem<T>> items;

  /// Called when a row is tapped — passes the item's key.
  final void Function(T key) onPick;

  /// Currently selected key for single-select mode.
  final T? selectedKey;

  /// Live selection notifier for multi-select mode.
  ///
  /// This notifier is owned by the parent ([KitDropdownMulti]) and is
  /// mutated directly inside [onPick] so checkboxes update instantly
  /// without any parent rebuild.
  final ValueNotifier<List<T>>? selectedKeysNotifier;

  /// Called when the user taps "Done" in multi-select mode.
  final VoidCallback? onDone;

  final bool searchEnabled;
  final String searchHint;
  final double itemHeight;
  final int maxVisibleItems;
  final Color selectedItemColor;
  final Color selectedItemTextColor;
  final Color checkColor;
  final Color textColor;
  final Color accentColor;
  final Color bgColor;

  /// When true the panel shows animated checkboxes.
  final bool multiSelect;

  @override
  State<StatefulPicker<T>> createState() => _StatefulPickerState<T>();
}

class _StatefulPickerState<T> extends State<StatefulPicker<T>> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();

  // Filtered item list — updated on every search keystroke.
  final _filtered = ValueNotifier<List<DropdownItem<T>>>([]);

  @override
  void initState() {
    super.initState();
    _filtered.value = widget.items;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    _filtered.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    _filtered.value = query.isEmpty
        ? widget.items
        : widget.items
            .where(
              (e) =>
                  e.label
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  e.key
                      .toString()
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList();
  }

  @override
  Widget build(BuildContext context) {
    // ── Multi mode — wraps PickerPanel in a ValueListenableBuilder on the
    //   notifier so checkboxes rebuild live on every tap. ──────────────────
    if (widget.multiSelect && widget.selectedKeysNotifier != null) {
      return ValueListenableBuilder<List<T>>(
        valueListenable: widget.selectedKeysNotifier!,
        builder: (_, selectedKeys, __) {
          return ValueListenableBuilder<List<DropdownItem<T>>>(
            valueListenable: _filtered,
            builder: (_, filtered, __) => PickerPanel<T>(
              filtered: filtered,
              selectedKeys: selectedKeys,
              onPick: widget.onPick,
              searchCtrl: _searchCtrl,
              searchFocus: _searchFocus,
              searchEnabled: widget.searchEnabled,
              searchHint: widget.searchHint,
              onSearch: _onSearch,
              itemHeight: widget.itemHeight,
              maxVisibleItems: widget.maxVisibleItems,
              borderRadius: BorderRadius.zero,
              bgColor: widget.bgColor,
              selectedItemColor: widget.selectedItemColor,
              selectedItemTextColor: widget.selectedItemTextColor,
              checkColor: widget.checkColor,
              textColor: widget.textColor,
              accentColor: widget.accentColor,
              shadow: const [], // sheet/dialog supplies its own chrome
              multiSelect: true,
              onDone: widget.onDone,
              selectedCount: selectedKeys.length,
            ),
          );
        },
      );
    }

    // ── Single mode ───────────────────────────────────────────────────────
    return ValueListenableBuilder<List<DropdownItem<T>>>(
      valueListenable: _filtered,
      builder: (_, filtered, __) => PickerPanel<T>(
        filtered: filtered,
        selectedKey: widget.selectedKey,
        onPick: widget.onPick,
        searchCtrl: _searchCtrl,
        searchFocus: _searchFocus,
        searchEnabled: widget.searchEnabled,
        searchHint: widget.searchHint,
        onSearch: _onSearch,
        itemHeight: widget.itemHeight,
        maxVisibleItems: widget.maxVisibleItems,
        borderRadius: BorderRadius.zero,
        bgColor: widget.bgColor,
        selectedItemColor: widget.selectedItemColor,
        selectedItemTextColor: widget.selectedItemTextColor,
        checkColor: widget.checkColor,
        textColor: widget.textColor,
        accentColor: widget.accentColor,
        shadow: const [],
      ),
    );
  }
}
