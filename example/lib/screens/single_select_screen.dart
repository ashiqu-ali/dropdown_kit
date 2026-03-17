import 'package:flutter/material.dart';
import 'package:dropdown_kit/dropdown_kit.dart';

// ── Sample data ──────────────────────────────────────────────────────────────

/// Simple enum used to show that KitDropdown works with any key type.
enum Priority { low, medium, high, critical }

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

const _roles = [
  DropdownItem(key: 1, label: 'Administrator'),
  DropdownItem(key: 2, label: 'Editor'),
  DropdownItem(key: 3, label: 'Viewer'),
  DropdownItem(key: 4, label: 'Guest'),
];

const _priorities = [
  DropdownItem(key: Priority.low,      label: 'Low'),
  DropdownItem(key: Priority.medium,   label: 'Medium'),
  DropdownItem(key: Priority.high,     label: 'High'),
  DropdownItem(key: Priority.critical, label: 'Critical'),
];

// ── Screen ───────────────────────────────────────────────────────────────────

/// Demonstrates [KitDropdown] in all three [DropdownMode]s.
///
/// Each section shows a different key type:
///  - Overlay   → String key  (country code)
///  - BottomSheet → int key   (role id)
///  - Dialog    → enum key    (priority level)
class SingleSelectScreen extends StatefulWidget {
  const SingleSelectScreen({super.key});

  @override
  State<SingleSelectScreen> createState() => _SingleSelectScreenState();
}

class _SingleSelectScreenState extends State<SingleSelectScreen> {
  // ── State — just plain keys, nothing else ─────────────────────────────────
  String?   _countryKey;   // overlay   — String key
  int?      _roleKey;      // sheet     — int key
  Priority? _priorityKey;  // dialog    — enum key

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single Select')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 1. Overlay (default) ─────────────────────────────────────────
            _SectionHeader(
              mode: 'Overlay',
              description: 'Panel anchors below the field, auto-flips '
                  'above if near the bottom of the screen.',
            ),
            KitDropdown<String>(
              items: _countries,
              value: _countryKey,
              label: 'Country',
              hint: 'Select a country',
              mode: DropdownMode.overlay,               // ← default
              onChanged: (String key) =>
                  setState(() => _countryKey = key),
            ),
            _ValueRow('Selected key', _countryKey ?? '—'),

            const SizedBox(height: 28),

            // ── 2. Bottom sheet ──────────────────────────────────────────────
            _SectionHeader(
              mode: 'Bottom Sheet',
              description: 'Full-width sheet slides up above the '
                  'BottomNavigationBar via useRootNavigator.',
            ),
            KitDropdown<int>(
              items: _roles,
              value: _roleKey,
              label: 'Role',
              hint: 'Assign a role',
              mode: DropdownMode.bottomSheet,
              title: 'Choose Role',
              // Custom green accent
              focusBorderColor: const Color(0xFF059669),
              selectedItemColor: const Color(0xFFD1FAE5),
              selectedItemTextColor: const Color(0xFF065F46),
              checkColor: const Color(0xFF059669),
              onChanged: (int key) =>
                  setState(() => _roleKey = key),
            ),
            _ValueRow('Selected key', _roleKey?.toString() ?? '—'),

            const SizedBox(height: 28),

            // ── 3. Dialog ────────────────────────────────────────────────────
            _SectionHeader(
              mode: 'Dialog',
              description: 'Centred modal — great for tablets or when '
                  'you want a focused, dismissible overlay.',
            ),
            KitDropdown<Priority>(
              items: _priorities,
              value: _priorityKey,
              label: 'Priority',
              hint: 'Choose priority',
              mode: DropdownMode.dialog,
              title: 'Set Priority',
              searchEnabled: false,       // no search needed for 4 items
              maxVisibleItems: 4,
              // Custom amber accent
              focusBorderColor: const Color(0xFFF59E0B),
              selectedItemColor: const Color(0xFFFEF3C7),
              selectedItemTextColor: const Color(0xFF92400E),
              checkColor: const Color(0xFFF59E0B),
              onChanged: (Priority key) =>
                  setState(() => _priorityKey = key),
            ),
            _ValueRow('Selected key', _priorityKey?.name ?? '—'),

            const SizedBox(height: 28),

            // ── 4. Pill shape demo ───────────────────────────────────────────
            _SectionHeader(
              mode: 'Custom Shape',
              description: 'Pass any BorderRadius — here a pill field '
                  'with a rounded overlay panel.',
            ),
            KitDropdown<String>(
              items: _countries,
              value: _countryKey,
              hint: 'Pill-shaped field',
              borderRadius: BorderRadius.circular(999),
              dropdownBorderRadius: BorderRadius.circular(16),
              focusBorderColor: const Color(0xFF8B5CF6),
              selectedItemColor: const Color(0xFFF3E8FF),
              selectedItemTextColor: const Color(0xFF6D28D9),
              checkColor: const Color(0xFF8B5CF6),
              onChanged: (String key) =>
                  setState(() => _countryKey = key),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
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
            ],
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
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9CA3AF),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }
}
