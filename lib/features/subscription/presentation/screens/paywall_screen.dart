import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/screens/approval_pending_screen.dart';
import '../providers/subscription_provider.dart';
import '../../data/models/subscription_plan_model.dart';

class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(subscriptionPlansProvider);
    final subState = ref.watch(subscriptionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 32),
                  if (subState.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: CircularProgressIndicator(color: Color(0xFFFF6B2B)),
                      ),
                    )
                  else ...[
                    plansAsync.when(
                      data: (plans) => _buildPlansList(plans),
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: Color(0xFFFF6B2B)),
                      ),
                      error: (err, stack) => Center(
                        child: Text(
                          'Error loading plans: $err',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildStatusInfo(subState),
                    if (subState.status?.isPremium == true) _buildCancelSection(context, ref, subState),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded, color: Colors.white70),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(subscriptionProvider.notifier).restore(platform: "Android", receiptData: "ok");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Restore request sent...'), backgroundColor: Color(0xFF1C1C1C))
            );
          },
          child: Text(
            'Restore',
            style: GoogleFonts.inter(
              color: const Color(0xFFFF6B2B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
      pinned: true,
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Go Premium',
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Unlock all features and reach your fitness goals faster.',
          style: GoogleFonts.inter(
            fontSize: 16,
            color: Colors.white60,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPlansList(List<SubscriptionPlanModel> plans) {
    // Only show Free plan for now per client request
    final freePlans = plans.where((p) => p.price == 0 || p.planId.toLowerCase().contains('free')).toList();
    
    return Column(
      children: freePlans.map((plan) => _PlanCard(plan: plan)).toList(),
    );
  }

  Widget _buildStatusInfo(SubscriptionState state) {
    final status = state.status;
    if (status == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            status.isPremium ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: status.isPremium ? const Color(0xFF30D158) : Colors.white60,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status.isPremium 
                ? 'Your ${status.plan.split('-').last} plan is active until ${status.expiryDate}.'
                : 'You are currently on the Free plan.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelSection(BuildContext context, WidgetRef ref, SubscriptionState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: TextButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1A1A1A),
                title: const Text('Cancel Subscription?', style: TextStyle(color: Colors.white)),
                content: const Text(
                  'Your premium access will continue until the end of your current billing period.',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep It')),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true), 
                    child: const Text('Cancel Now', style: TextStyle(color: Colors.redAccent))
                  ),
                ],
              ),
            );

            if (confirm == true) {
              ref.read(subscriptionProvider.notifier).cancel();
            }
          },
          child: Text(
            'Cancel Subscription',
            style: GoogleFonts.inter(
              color: Colors.redAccent.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ),
    );
  }
}

class _PlanCard extends ConsumerWidget {
  final SubscriptionPlanModel plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isYearly = plan.duration == 'yearly';
    final subState = ref.watch(subscriptionProvider);
    final isCurrent = subState.status?.plan == plan.planId;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCurrent 
            ? const Color(0xFF30D158) 
            : (isYearly ? const Color(0xFFFF6B2B) : const Color(0xFF252525)),
          width: (isYearly || isCurrent) ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                plan.name,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF30D158).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF30D158), width: 1),
                  ),
                  child: Text(
                    'CURRENT',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF30D158),
                    ),
                  ),
                )
              else if (isYearly)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B2B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'BEST VALUE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${plan.price.toInt()}',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                ' / ${plan.duration}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white60,
                  height: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF252525)),
          const SizedBox(height: 20),
          ...plan.features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFFFF6B2B), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feature,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isCurrent ? null : () async {
                // IMPORTANT: Capture navigator BEFORE the async call
                // because Riverpod rebuilds this widget when state changes,
                // which disposes the old context and makes context.mounted = false
                final navigator = Navigator.of(context);
                
                // Submit subscription request (don't care if it fails,
                // we still move to the pending screen)
                try {
                  await ref.read(subscriptionProvider.notifier).submitRequest(
                    planId: plan.planId,
                    planName: plan.duration,
                  );
                } catch (_) {
                  // Even if API fails, still navigate to pending screen
                }
                
                // Navigate using the captured navigator reference
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const ApprovalPendingScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent 
                  ? Colors.white.withOpacity(0.05) 
                  : (isYearly ? const Color(0xFFFF6B2B) : Colors.white10),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                isCurrent ? 'Current Plan' : 'Subscribe Now',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
