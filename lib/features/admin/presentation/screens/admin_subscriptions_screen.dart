import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import 'admin_main_screen.dart';
import '../widgets/subscription_card.dart';

class AdminSubscriptionsScreen extends StatefulWidget {
  const AdminSubscriptionsScreen({super.key});

  @override
  State<AdminSubscriptionsScreen> createState() => _AdminSubscriptionsScreenState();
}

class _AdminSubscriptionsScreenState extends State<AdminSubscriptionsScreen>
    with SingleTickerProviderStateMixin {
  static const Color _accent = Color(0xFFFF6B00);
  static const Color _bg = Color(0xFF0F0F0F);

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _statuses = ['all', 'due', 'expired', 'pending', 'approved', 'rejected'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    
    // Sync tab changes with provider filter
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<AdminProvider>().filterSubscriptions(_statuses[_tabController.index]);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchSubscriptions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: _accent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, String tabStatus) {
    return Consumer<AdminProvider>(
      builder: (context, provider, _) {
        final state = provider.subscriptionsState;

        if (state.isLoading && state.subscriptions.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: _accent),
          );
        }

        if (state.error != null && state.subscriptions.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: Colors.white38, size: 44),
                const SizedBox(height: 12),
                Text(state.error!, style: const TextStyle(color: Colors.white54)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchSubscriptions(),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: _accent, foregroundColor: Colors.white),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final subs = provider.subscriptionsState.getSubscriptionsForTab(tabStatus);

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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];
              return SubscriptionCard(
                subscription: sub,
                onTap: () => _showHistoryBottomSheet(context, sub),
                onApprove: sub.status == 'pending'
                    ? () => provider.approveSubscription(subId: sub.id)
                    : null,
                onReject: sub.status == 'pending'
                    ? () => _showRejectDialog(context, sub.id)
                    : null,
              );
            },
          ),
        );
      },
    );
  }

  void _showHistoryBottomSheet(BuildContext context, dynamic sub) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A1A),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Renewal History: ${sub.userName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // TODO: Fetch and display actual history from API.
              // For now, displaying a placeholder or the current subscription.
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.plan.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Current Plan',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                        ),
                      ],
                    ),
                    Text(
                      sub.status.toUpperCase(),
                      style: TextStyle(
                        color: sub.status == 'approved' ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Past renewal data not yet available from server.',
                  style: TextStyle(color: Colors.white38, fontSize: 13),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
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
            const SizedBox(height: 16),
            
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (val) {
                  context.read<AdminProvider>().searchSubscriptions(val);
                },
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tab Bar
            TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: _accent,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Due'),
                Tab(text: 'Expired'),
                Tab(text: 'Pending'),
                Tab(text: 'Approved'),
                Tab(text: 'Rejected'),
              ],
            ),
            
            // Tab View (Slides)
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(context, 'all'),
                  _buildList(context, 'due'),
                  _buildList(context, 'expired'),
                  _buildList(context, 'pending'),
                  _buildList(context, 'approved'),
                  _buildList(context, 'rejected'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}