import 'package:flutter/material.dart';
import '../core/dropdown_item.dart';
import 'item_tile.dart';

/// The inner search + list panel shared by all three presentation modes.
///
/// When [shadow] is non-empty it wraps itself in a decorated [Container]
/// (used by the overlay).  When [shadow] is empty it renders as a plain
/// [Column] (used inside bottom-sheet / dialog, which supply their own chrome).
///
/// This widget is stateless — all mutable state ([filtered], [selectedKey],
/// [selectedKeys]) is owned by the caller and passed in.
class PickerPanel<T> extends StatelessWidget {
  const PickerPanel({
    super.key,
    required this.filtered,
    this.selectedKey,
    this.selectedKeys = const [],
    required this.onPick,
    required this.searchCtrl,
    required this.searchFocus,
    required this.searchEnabled,
    required this.searchHint,
    required this.onSearch,
    required this.itemHeight,
    required this.maxVisibleItems,
    required this.borderRadius,
    required this.bgColor,
    required this.selectedItemColor,
    required this.selectedItemTextColor,
    required this.checkColor,
    required this.textColor,
    required this.accentColor,
    required this.shadow,
    this.multiSelect = false,
    this.onDone,
    this.selectedCount = 0,
  });

  /// Filtered subset of items currently shown in the list.
  final List<DropdownItem<T>> filtered;

  /// Selected key for single-select mode (null = nothing selected).
  final T? selectedKey;

  /// Selected keys for multi-select mode.
  final List<T> selectedKeys;

  /// Called when a row is tapped — passes the item's key.
  final void Function(T key) onPick;

  final TextEditingController searchCtrl;
  final FocusNode searchFocus;

  /// When false the search field is hidden entirely.
  final bool searchEnabled;

  final String searchHint;

  /// Called on every keystroke with the current query string.
  final void Function(String query) onSearch;

  final double itemHeight;
  final int maxVisibleItems;
  final BorderRadius borderRadius;
  final Color bgColor;
  final Color selectedItemColor;
  final Color selectedItemTextColor;
  final Color checkColor;
  final Color textColor;

  /// Used for the search field focused border and Done button colour.
  final Color accentColor;

  /// Box shadows applied to the outer container (overlay only).
  /// Pass `const []` for bottom-sheet / dialog usage.
  final List<BoxShadow> shadow;

  /// When true renders animated checkboxes instead of a trailing tick.
  final bool multiSelect;

  /// Callback for the "Done" button in multi-select mode.
  /// If null the Done footer is hidden.
  final VoidCallback? onDone;

  /// Number shown in the "N selected" label next to Done.
  final int selectedCount;

  @override
  Widget build(BuildContext context) {
    final listMaxH = itemHeight * maxVisibleItems;

    final panel = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Search field ────────────────────────────────────────────────────
        if (searchEnabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              controller: searchCtrl,
              focusNode: searchFocus,
              onChanged: onSearch,
              style: TextStyle(fontSize: 14, color: textColor),
              decoration: InputDecoration(
                hintText: searchHint,
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: Color(0xFF9CA3AF),
                ),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: accentColor, width: 1.5),
                ),
              ),
            ),
          ),
          _divider(),
        ],

        // ── Empty state ─────────────────────────────────────────────────────
        if (filtered.isEmpty)
          SizedBox(
            height: itemHeight,
            child: const Center(
              child: Text(
                'No results found',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
              ),
            ),
          )
        else
          // ── Item list ─────────────────────────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: listMaxH),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: filtered.length,
              itemExtent: itemHeight,
              itemBuilder: (_, i) {
                final item = filtered[i];
                final isSelected = multiSelect
                    ? selectedKeys.contains(item.key)
                    : selectedKey == item.key;

                return ItemTile<T>(
                  item: item,
                  isSelected: isSelected,
                  height: itemHeight,
                  selectedColor: selectedItemColor,
                  selectedTextColor: selectedItemTextColor,
                  checkColor: checkColor,
                  textColor: textColor,
                  multiSelect: multiSelect,
                  onTap: () => onPick(item.key),
                );
              },
            ),
          ),

        // ── Done footer (multi-select only) ──────────────────────────────────
        if (multiSelect && onDone != null) ...[
          _divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$selectedCount selected',
                  style: TextStyle(
                    fontSize: 12,
                    color: accentColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: onDone,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );

    // Overlay mode wraps in a decorated container with shadow.
    // Sheet / dialog mode returns the bare column.
    if (shadow.isEmpty) return panel;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border: Border.all(
            color: accentColor.withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: shadow,
        ),
        child: ClipRRect(borderRadius: borderRadius, child: panel),
      ),
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 1,
    color: Colors.grey.withValues(alpha: 0.1),
  );
}
