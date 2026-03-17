import 'package:flutter/material.dart';
import '../core/dropdown_item.dart';

/// A single row inside the picker list.
///
/// Handles its own hover state via [ValueNotifier] (no setState).
/// Shows an animated checkbox in multi-select mode, or a trailing
/// check icon in single-select mode.
class ItemTile<T> extends StatefulWidget {
  const ItemTile({
    super.key,
    required this.item,
    required this.isSelected,
    required this.height,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.checkColor,
    required this.textColor,
    required this.multiSelect,
    required this.onTap,
  });

  /// The item this row represents.
  final DropdownItem<T> item;

  /// Whether this row is currently selected.
  final bool isSelected;

  /// Row height — matches [PickerPanel.itemHeight].
  final double height;

  /// Row background colour when [isSelected] is true.
  final Color selectedColor;

  /// Label text colour when [isSelected] is true.
  final Color selectedTextColor;

  /// Checkbox fill / trailing tick colour when [isSelected] is true.
  final Color checkColor;

  /// Label text colour when not selected.
  final Color textColor;

  /// When true, renders an animated checkbox on the leading side.
  /// When false, renders a trailing tick icon for the selected row.
  final bool multiSelect;

  /// Called when the user taps this row.
  final VoidCallback onTap;

  @override
  State<ItemTile<T>> createState() => _ItemTileState<T>();
}

class _ItemTileState<T> extends State<ItemTile<T>> {
  // Hover state for desktop / web — purely cosmetic, uses ValueNotifier.
  final _hovered = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _hovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _hovered,
      // ignore: unnecessary_underscores
      builder: (_, hovered, _) {
        final bg = widget.isSelected
            ? widget.selectedColor
            : hovered
            ? const Color(0xFFF9FAFB)
            : Colors.transparent;

        return MouseRegion(
          onEnter: (_) => _hovered.value = true,
          onExit: (_) => _hovered.value = false,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 110),
              height: widget.height,
              color: bg,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // ── Multi: animated checkbox ──────────────────────────────
                  if (widget.multiSelect) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: widget.isSelected
                            ? widget.checkColor
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: widget.isSelected
                              ? widget.checkColor
                              : const Color(0xFFD1D5DB),
                          width: 1.5,
                        ),
                      ),
                      child: widget.isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                  ],

                  // ── Label ─────────────────────────────────────────────────
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: widget.isSelected
                            ? widget.selectedTextColor
                            : widget.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // ── Single: trailing tick ─────────────────────────────────
                  if (!widget.multiSelect && widget.isSelected)
                    Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: widget.checkColor,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
