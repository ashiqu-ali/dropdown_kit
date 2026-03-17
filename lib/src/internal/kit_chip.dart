import 'package:flutter/material.dart';

/// A small removable chip displayed inside [KitDropdownMulti]'s trigger field
/// for each currently selected item.
///
/// Tapping the × icon calls [onRemove] — the parent handles list mutation.
class KitChip extends StatelessWidget {
  const KitChip({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
    required this.onRemove,
  });

  /// Display text inside the chip.
  final String label;

  /// Chip background colour.
  final Color color;

  /// Label text and remove-icon colour.
  final Color textColor;

  /// Called when the user taps the × icon to deselect this item.
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 13, color: textColor),
          ),
        ],
      ),
    );
  }
}
