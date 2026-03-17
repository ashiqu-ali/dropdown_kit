import 'package:flutter/material.dart';
import '../core/dropdown_mode.dart';

/// Adds the header chrome (drag handle, title, close button) around the picker
/// content when presenting in [DropdownMode.bottomSheet] or [DropdownMode.dialog].
///
/// - Bottom-sheet: shows a drag handle pill above the title.
/// - Dialog: no drag handle; uses the same title + close layout.
///
/// Safe-area padding is applied at the bottom to respect the home indicator
/// on iPhone and the system navigation bar on Android.
class SheetDialogWrapper extends StatelessWidget {
  const SheetDialogWrapper({
    super.key,
    required this.mode,
    required this.borderRadius,
    required this.bgColor,
    required this.accentColor,
    required this.title,
    required this.child,
  });

  /// Determines whether a drag handle is shown.
  final DropdownMode mode;

  /// Corner radius of the wrapping container / dialog.
  final BorderRadius borderRadius;

  /// Background colour of the panel.
  final Color bgColor;

  /// Accent colour used for the focused border inside [child].
  final Color accentColor;

  /// Title shown in the header row.
  final String title;

  /// The picker content — typically a [StatefulPicker].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset  = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Drag handle (bottom-sheet only) ──────────────────────────────────
        if (mode == DropdownMode.bottomSheet) ...[
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
        ] else
          const SizedBox(height: 20),

        // ── Title row ─────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              // Close button
              GestureDetector(
                onTap: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

        // ── Picker content ────────────────────────────────────────────────────
        child,

        // ── Safe-area bottom padding ──────────────────────────────────────────
        // Uses keyboard inset when the keyboard is open, otherwise uses the
        // device's safe-area padding (home indicator / nav bar).
        SizedBox(height: bottomInset > 0 ? bottomInset : bottomPadding),
      ],
    );

    if (mode == DropdownMode.bottomSheet) {
      return Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
        ),
        child: content,
      );
    }

    // ── Dialog ─────────────────────────────────────────────────────────────
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      backgroundColor: bgColor,
      child: content,
    );
  }
}
