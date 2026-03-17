import 'package:flutter/material.dart';
import 'package:dropdown_kit/dropdown_kit.dart';

// ── Sample data ──────────────────────────────────────────────────────────────

const _countries = [
  DropdownItem(key: 'IN', label: 'India'),
  DropdownItem(key: 'US', label: 'United States'),
  DropdownItem(key: 'UK', label: 'United Kingdom'),
  DropdownItem(key: 'AU', label: 'Australia'),
  DropdownItem(key: 'CA', label: 'Canada'),
  DropdownItem(key: 'DE', label: 'Germany'),
  DropdownItem(key: 'JP', label: 'Japan'),
  DropdownItem(key: 'FR', label: 'France'),
  DropdownItem(key: 'BR', label: 'Brazil'),
  DropdownItem(key: 'SG', label: 'Singapore'),
];

const _techTags = [
  DropdownItem(key: 'flutter',   label: 'Flutter'),
  DropdownItem(key: 'dart',      label: 'Dart'),
  DropdownItem(key: 'firebase',  label: 'Firebase'),
  DropdownItem(key: 'supabase',  label: 'Supabase'),
  DropdownItem(key: 'riverpod',  label: 'Riverpod'),
  DropdownItem(key: 'bloc',      label: 'BLoC'),
  DropdownItem(key: 'getx',      label: 'GetX'),
  DropdownItem(key: 'go_router', label: 'GoRouter'),
];

// ── Screen ───────────────────────────────────────────────────────────────────

/// Demonstrates [KitDropdownMulti] in all three [DropdownMode]s.
///
/// Key behaviours shown:
///  - Overlay    → chips update live as the user taps
///  - BottomSheet → checkboxes tick live; parent updates only on Done
///  - Dialog     → same as bottom sheet, different chrome
class MultiSelectScreen extends StatefulWidget {
  const MultiSelectScreen({super.key});

  @override
  State<MultiSelectScreen> createState() => _MultiSelectScreenState();
}

class _MultiSelectScreenState extends State<MultiSelectScreen> {
  // ── State — List<T> of raw keys ───────────────────────────────────────────
  List<String> _overlayKeys    = [];   // overlay
  List<String> _sheetKeys      = [];   // bottom sheet
  List<String> _dialogKeys     = [];   // dialog
  List<String> _techKeys       = [];   // tech tags demo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multi Select')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 1. Overlay ───────────────────────────────────────────────────
            _SectionHeader(
              mode: 'Overlay',
              description: 'Checkboxes update and chips appear instantly '
                  'as the user taps each item.',
            ),
            KitDropdownMulti<String>(
              items: _countries,
              value: _overlayKeys,
              label: 'Countries',
              hint: 'Select countries',
              mode: DropdownMode.overlay,
              onChanged: (List<String> keys) =>
                  setState(() => _overlayKeys = keys),
            ),
            _ValueRow(
              'Keys',
              _overlayKeys.isEmpty ? '—' : _overlayKeys.join(', '),
            ),

            const SizedBox(height: 28),

            // ── 2. Bottom sheet ──────────────────────────────────────────────
            _SectionHeader(
              mode: 'Bottom Sheet',
              description: 'Checkboxes update live via a local '
                  'ValueNotifier. Parent receives keys only on Done.',
            ),
            KitDropdownMulti<String>(
              items: _countries,
              value: _sheetKeys,
              label: 'Countries',
              hint: 'Select countries',
              mode: DropdownMode.bottomSheet,
              title: 'Select Countries',
              // Custom green accent
              focusBorderColor: const Color(0xFF059669),
              selectedItemColor: const Color(0xFFD1FAE5),
              selectedItemTextColor: const Color(0xFF065F46),
              checkColor: const Color(0xFF059669),
              chipColor: const Color(0xFFD1FAE5),
              chipTextColor: const Color(0xFF065F46),
              onChanged: (List<String> keys) =>
                  setState(() => _sheetKeys = keys),
            ),
            _ValueRow(
              'Keys',
              _sheetKeys.isEmpty ? '—' : _sheetKeys.join(', '),
            ),

            const SizedBox(height: 28),

            // ── 3. Dialog ────────────────────────────────────────────────────
            _SectionHeader(
              mode: 'Dialog',
              description: 'Same live-checkbox behaviour as the bottom '
                  'sheet, presented as a centred modal.',
            ),
            KitDropdownMulti<String>(
              items: _countries,
              value: _dialogKeys,
              label: 'Countries',
              hint: 'Select countries',
              mode: DropdownMode.dialog,
              title: 'Select Countries',
              panelBorderRadius: BorderRadius.circular(16),
              // Custom amber accent
              focusBorderColor: const Color(0xFFF59E0B),
              selectedItemColor: const Color(0xFFFEF3C7),
              selectedItemTextColor: const Color(0xFF92400E),
              checkColor: const Color(0xFFF59E0B),
              chipColor: const Color(0xFFFEF3C7),
              chipTextColor: const Color(0xFF92400E),
              onChanged: (List<String> keys) =>
                  setState(() => _dialogKeys = keys),
            ),
            _ValueRow(
              'Keys',
              _dialogKeys.isEmpty ? '—' : _dialogKeys.join(', '),
            ),

            const SizedBox(height: 28),

            // ── 4. Different items — tech tags ────────────────────────────────
            _SectionHeader(
              mode: 'Different Items',
              description:
                  'The key type, items, colours, and shape are all '
                  'independent per widget instance.',
            ),
            KitDropdownMulti<String>(
              items: _techTags,
              value: _techKeys,
              label: 'Tech Stack',
              hint: 'Select technologies',
              mode: DropdownMode.overlay,
              borderRadius: BorderRadius.circular(10),
              dropdownBorderRadius: BorderRadius.circular(12),
              focusBorderColor: const Color(0xFF8B5CF6),
              selectedItemColor: const Color(0xFFF3E8FF),
              selectedItemTextColor: const Color(0xFF6D28D9),
              checkColor: const Color(0xFF8B5CF6),
              chipColor: const Color(0xFFF3E8FF),
              chipTextColor: const Color(0xFF6D28D9),
              onChanged: (List<String> keys) =>
                  setState(() => _techKeys = keys),
            ),
            _ValueRow(
              'Keys',
              _techKeys.isEmpty ? '—' : _techKeys.join(', '),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.mode,
    required this.description,
  });

  final String mode;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              mode,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF6366F1),
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
