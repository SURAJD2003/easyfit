import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import 'admin_main_screen.dart';
import '../widgets/subscription_card.dart';
import '../widgets/index.dart';

class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() =>
      _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState
    extends State<AdminSubscriptionsScreen> {
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _bg = Color(0xFF0F0F0F);

  final List<Map<String, String>> _tabs = [
    {'label': 'All', 'value': 'all'},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Approved', 'value': 'approved'},
    {'label': 'Rejected', 'value': 'rejected'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchSubscriptions();
    });
  }

  void _showRejectDialog(BuildContext context, String subId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Reject Subscription',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter reason for rejection...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            enabledBorder: UnderlineInputBorder(
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _accent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a reason')),
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<AdminProvider>().rejectSubscription(
                    subId: subId,
                    reason: reason,
                  );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => AdminMainScreen.scaffoldKey.currentState?.openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.menu_rounded, color: _accent, size: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Subscriptions',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Consumer<AdminProvider>(
              builder: (context, provider, _) {
                final currentFilter =
                    provider.subscriptionsState.filterStatus;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: _tabs.map((tab) {
                      final isSelected =
                          currentFilter == tab['value'];
                      return GestureDetector(
                        onTap: () => provider.filterSubscriptions(
                            tab['value']!),
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _accent
                                : const Color(0xFF1A1A1A),
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? _accent
                                  : Colors.white
                                      .withOpacity(0.08),
                            ),
                          ),
                          child: Text(
                            tab['label']!,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white54,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Consumer<AdminProvider>(
                builder: (context, provider, _) {
                  final state = provider.subscriptionsState;

                  if (state.isLoading &&
                      state.subscriptions.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: _accent),
                    );
                  }

                  if (state.error != null &&
                      state.subscriptions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: Colors.white38, size: 44),
                          const SizedBox(height: 12),
                          Text(state.error!,
                              style: const TextStyle(
                                  color: Colors.white54)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                provider.fetchSubscriptions(),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                foregroundColor: Colors.white),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final subs = state.filteredSubscriptions;

                  if (subs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No subscriptions found',
                        style: TextStyle(color: Colors.white38),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: _accent,
                    backgroundColor: const Color(0xFF1A1A1A),
                    onRefresh: () => provider.fetchSubscriptions(),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          20, 0, 20, 24),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: subs.length,
                      itemBuilder: (context, index) {
                        final sub = subs[index];
                        return SubscriptionCard(
                          subscription: sub,
                          onApprove: sub.status == 'pending'
                              ? () => provider.approveSubscription(
                                  subId: sub.id)
                              : null,
                          onReject: sub.status == 'pending'
                              ? () => _showRejectDialog(context, sub.id)
                              : null,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}