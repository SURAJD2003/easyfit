import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/index.dart';
import '../providers/admin_provider.dart';
import '../widgets/status_badge.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final String userId;

  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() =>
      _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _bg = Color(0xFF0F0F0F);
  static const Color _cardColor = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AdminProvider>()
          .fetchUserDetail(userId: widget.userId);
    });
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete User',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Are you sure you want to delete this user? This action cannot be undone.',
          style: TextStyle(color: Colors.white60),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final success = await context
          .read<AdminProvider>()
          .deleteUser(userId: widget.userId);
      if (success && mounted) Navigator.pop(context);
    }
  }

  Future<void> _showAdminSnackBar(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF121212),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleDeactivate() async {
    final reasonController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deactivate User', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please provide a reason for deactivation.',
              style: TextStyle(color: Colors.white60, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., Policy violation...',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final success = await context.read<AdminProvider>().deactivateUser(
            userId: widget.userId,
            reason: result.trim(),
          );
      if (success) {
        await _showAdminSnackBar('Account deactivated successfully.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, _) {
          final state = provider.usersState;

          if (state.isLoading && state.selectedUser == null) {
            return const Center(
              child: CircularProgressIndicator(color: _accent),
            );
          }

          final user = state.selectedUser;
          if (user == null) {
            return const Center(
              child: Text('User not found',
                  style: TextStyle(color: Colors.white54)),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── PROFILE HEADER ──
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _accent.withOpacity(0.3), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: _accent.withOpacity(0.1),
                          backgroundImage: user.profileImage != null
                              ? NetworkImage(user.profileImage!)
                              : null,
                          child: user.profileImage == null
                              ? Text(
                                  user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    color: _accent,
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatusBadge(
                        type: user.isActive ? BadgeType.active : BadgeType.inactive,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ── SUBSCRIPTION DETAILS ──
                const _SectionTitle(title: 'Subscription Status'),
                const SizedBox(height: 12),
                _SubscriptionCard(info: user.subscription),
                const SizedBox(height: 24),

                // ── ACCOUNT DETAILS ──
                const _SectionTitle(title: 'Account Information'),
                const SizedBox(height: 12),
                _InfoCard(children: [
                  _InfoRow(
                      icon: Icons.phone_rounded,
                      label: 'Phone',
                      value: user.phone ?? 'Not linked'),
                  _InfoRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'User ID',
                      value: user.id.substring(0, 13) + '...'),
                  if (user.createdAt != null)
                    _InfoRow(
                      icon: Icons.calendar_month_rounded,
                      label: 'Joined On',
                      value: DateFormat('MMM dd, yyyy').format(user.createdAt!),
                    ),
                ]),
                const SizedBox(height: 32),

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.2)),
                      ),
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                // ── ACTIONS ──
                Row(
                  children: [
                    if (user.subscription?.plan.toLowerCase() == 'free' || user.subscription == null)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _ActionButton(
                            label: 'Grant Premium',
                            icon: Icons.workspace_premium_rounded,
                            color: const Color(0xFFFF6B00),
                            isLoading: state.isActionLoading,
                            onTap: () async {
                              final reasonController = TextEditingController();
                              String? selectedDate;
                              
                              final plan = await showDialog<String>(
                                context: context,
                                builder: (context) => SimpleDialog(
                                  backgroundColor: _cardColor,
                                  title: const Text('Select Plan to Grant', style: TextStyle(color: Colors.white)),
                                  children: [
                                    SimpleDialogOption(
                                      onPressed: () => Navigator.pop(context, 'plan-monthly'),
                                      child: const Text('Monthly Plan', style: TextStyle(color: Colors.white70)),
                                    ),
                                    SimpleDialogOption(
                                      onPressed: () => Navigator.pop(context, 'plan-yearly'),
                                      child: const Text('Yearly Plan', style: TextStyle(color: Colors.white70)),
                                    ),
                                  ],
                                ),
                              );

                              if (plan != null && mounted) {
                                // Step 2: Ask for Expiry Date and Reason
                                final details = await showDialog<Map<String, String>>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: _cardColor,
                                    title: const Text('Grant Details', style: TextStyle(color: Colors.white)),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: TextEditingController(text: '2026-06-01'), // Default for testing
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(
                                            labelText: 'Expiry Date (YYYY-MM-DD)',
                                            labelStyle: TextStyle(color: Colors.white38),
                                          ),
                                          onChanged: (val) => selectedDate = val,
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: reasonController,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: const InputDecoration(
                                            labelText: 'Reason',
                                            labelStyle: TextStyle(color: Colors.white38),
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, {
                                          'date': selectedDate ?? '2026-06-01',
                                          'reason': reasonController.text
                                        }), 
                                        child: const Text('Grant')
                                      ),
                                    ],
                                  ),
                                );

                                if (details != null && mounted) {
                                  provider.grantSubscription(
                                    userId: widget.userId, 
                                    planId: plan,
                                    expiryDate: details['date'],
                                    reason: details['reason'],
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    Expanded(
                      child: _ActionButton(
                        label: user.isActive ? 'Suspend Access' : 'Activate User',
                        icon: user.isActive ? Icons.block_flipped : Icons.check_circle_rounded,
                        color: user.isActive ? Colors.redAccent : const Color(0xFF10B981),
                        isLoading: state.isActionLoading,
                        onTap: () async {
                          if (user.isActive) {
                            await _handleDeactivate();
                          } else {
                            final success = await provider.activateUser(userId: widget.userId);
                            if (success) {
                              await _showAdminSnackBar('Account activated successfully.');
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: Colors.white.withOpacity(0.35),
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final SubscriptionInfo? info;
  const _SubscriptionCard({this.info});

  @override
  Widget build(BuildContext context) {
    final isFree = info?.plan.toLowerCase() == 'free' || info == null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isFree ? Colors.white10 : const Color(0xFFFF6B00).withOpacity(0.2),
        ),
        gradient: isFree
            ? null
            : LinearGradient(
                colors: [
                  const Color(0xFFFF6B00).withOpacity(0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isFree ? Colors.white.withOpacity(0.05) : const Color(0xFFFF6B00).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isFree ? Icons.person_outline_rounded : Icons.workspace_premium_rounded,
                  color: isFree ? Colors.white38 : const Color(0xFFFF6B00),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info?.plan ?? 'Free Plan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Status: ${info?.status ?? 'active'}',
                      style: TextStyle(
                        color: isFree ? Colors.white38 : const Color(0xFFFF6B00).withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isFree && info?.expiryDate != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    DateFormat('MMM dd').format(info!.expiryDate!),
                    style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;

  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 18),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: Colors.white54, fontSize: 14)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: color.withOpacity(0.4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}