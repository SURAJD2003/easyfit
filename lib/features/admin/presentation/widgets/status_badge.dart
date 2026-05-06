import 'package:flutter/material.dart';

enum BadgeType { active, inactive, pending, approved, rejected, free, premium }

class StatusBadge extends StatelessWidget {
  final BadgeType type;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.type,
    this.customLabel,
  });

  factory StatusBadge.fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const StatusBadge(type: BadgeType.active);
      case 'inactive':
        return const StatusBadge(type: BadgeType.inactive);
      case 'pending':
        return const StatusBadge(type: BadgeType.pending);
      case 'approved':
        return const StatusBadge(type: BadgeType.approved);
      case 'rejected':
        return const StatusBadge(type: BadgeType.rejected);
      case 'free':
        return const StatusBadge(type: BadgeType.free);
      case 'premium':
        return const StatusBadge(type: BadgeType.premium);
      default:
        return StatusBadge(
          type: BadgeType.inactive,
          customLabel: status,
        );
    }
  }

  Color get _bgColor {
    switch (type) {
      case BadgeType.active:
      case BadgeType.approved:
        return const Color(0xFF1A3A1A);
      case BadgeType.inactive:
      case BadgeType.rejected:
        return const Color(0xFF3A1A1A);
      case BadgeType.pending:
        return const Color(0xFF3A2A0A);
      case BadgeType.premium:
        return const Color(0xFF2A1A3A);
      case BadgeType.free:
        return const Color(0xFF1A2A3A);
    }
  }

  Color get _textColor {
    switch (type) {
      case BadgeType.active:
      case BadgeType.approved:
        return const Color(0xFF4CAF50);
      case BadgeType.inactive:
      case BadgeType.rejected:
        return const Color(0xFFFF5252);
      case BadgeType.pending:
        return const Color(0xFFFF6B00);
      case BadgeType.premium:
        return const Color(0xFFAB7EFF);
      case BadgeType.free:
        return const Color(0xFF4FC3F7);
    }
  }

  String get _label {
    if (customLabel != null) return customLabel!;
    switch (type) {
      case BadgeType.active:
        return 'Active';
      case BadgeType.inactive:
        return 'Inactive';
      case BadgeType.pending:
        return 'Pending';
      case BadgeType.approved:
        return 'Approved';
      case BadgeType.rejected:
        return 'Rejected';
      case BadgeType.free:
        return 'Free';
      case BadgeType.premium:
        return 'Premium';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _textColor.withOpacity(0.3)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}