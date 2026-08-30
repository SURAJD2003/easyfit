import 'package:flutter/material.dart';
import '../../domain/entities/subscription_entity.dart';
import 'status_badge.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionEntity subscription;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onTap;

  const SubscriptionCard({
    super.key,
    required this.subscription,
    this.onApprove,
    this.onReject,
    this.onTap,
  });

  static const Color _cardColor = Color(0xFF1A1A1A);
  static const Color _accent = Color(0xFFFF6B00);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isExpired = subscription.status == 'expired' ||
        (subscription.expiryDate != null &&
            subscription.expiryDate!.isBefore(today));
    final isDue = !isExpired &&
        (subscription.status == 'due' ||
            (subscription.expiryDate != null &&
                subscription.expiryDate!.difference(today).inDays <= 30));

    final badgeStatus = isExpired
        ? 'expired'
        : (isDue ? 'due' : subscription.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isExpired
                ? Colors.redAccent.withOpacity(0.3)
                : isDue
                    ? const Color(0xFFFFB300).withOpacity(0.3)
                    : Colors.white.withOpacity(0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subscription.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subscription.userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                StatusBadge.fromString(badgeStatus),
              ],
            ),
            const SizedBox(height: 12),
            // Plan and dates row
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    label: 'Plan',
                    value: subscription.plan.toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoChip(
                    label: 'Requested',
                    value: subscription.requestedAt != null
                        ? _formatDate(subscription.requestedAt!)
                        : 'N/A',
                  ),
                ),
                if (subscription.expiryDate != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoChip(
                      label: isExpired ? 'Expired On' : 'Due Date',
                      value: _formatDate(subscription.expiryDate!),
                      highlight: isExpired || isDue,
                      highlightColor: isExpired
                          ? Colors.redAccent
                          : (isDue ? const Color(0xFFFFB300) : null),
                    ),
                  ),
                ] else if (subscription.resolvedAt != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoChip(
                      label: subscription.status == 'approved'
                          ? 'Approved'
                          : 'Resolved',
                      value: _formatDate(subscription.resolvedAt!),
                    ),
                  ),
                ],
              ],
            ),
          // Action buttons for pending subscriptions
          if (subscription.status == 'pending' &&
              (onApprove != null || onReject != null))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  if (onReject != null)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5252),
                          side: const BorderSide(
                            color: Color(0xFF3A1A1A),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Reject',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (onApprove != null) const SizedBox(width: 12),
                  if (onApprove != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    ));
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Helper widget for displaying subscription info
class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final Color? highlightColor;

  const _InfoChip({
    required this.label,
    required this.value,
    this.highlight = false,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlightColor ?? Colors.redAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? color.withOpacity(0.12)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlight
              ? color.withOpacity(0.5)
              : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: highlight
                  ? color.withOpacity(0.9)
                  : Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: highlight ? color : Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
