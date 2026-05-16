import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/router/route_names.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userProfile;
    final sub = auth.subscriptionRequest;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // ── User Header ──
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B2B), Color(0xFFFF9A3C)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B2B).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        (user?['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?['name'] ?? 'User Name',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?['email'] ?? 'email@example.com',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // ── Subscription Card ──
            _buildSubscriptionCard(context, auth),

            const SizedBox(height: 32),

            // ── Menu Items ──
            _buildMenuTile(
              icon: Icons.person_outline_rounded,
              title: 'Edit Profile',
              onTap: () => context.push(RouteNames.editProfile),
            ),
            _buildMenuTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.security_rounded,
              title: 'Privacy & Security',
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.help_outline_rounded,
              title: 'Help & Support',
              onTap: () {},
            ),
            const SizedBox(height: 16),
            _buildMenuTile(
              icon: Icons.logout_rounded,
              title: 'Sign Out',
              color: Colors.redAccent,
              onTap: () async {
                await auth.logout();
                if (context.mounted) context.go(RouteNames.login);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, AuthProvider auth) {
    final sub = auth.subscriptionRequest;
    final isPremium = auth.isApproved;
    final isPending = auth.isPending;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPremium ? const Color(0xFFFF6B2B).withOpacity(0.5) : Colors.white10,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Membership',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                  letterSpacing: 0.5,
                ),
              ),
              if (isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B2B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'PREMIUM',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFFF6B2B),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isPremium 
                ? '${sub?.plan.toUpperCase() ?? 'PREMIUM'} PLAN'
                : (isPending ? 'APPROVAL PENDING' : 'FREE PLAN'),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (isPremium && sub?.expiryDate != null)
            Text(
              'Expires on ${DateFormat('MMM dd, yyyy').format(sub!.expiryDate!)}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white60,
              ),
            )
          else if (!isPremium && !isPending)
            Text(
              'Unlock personalized diet plans and tracking features.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white60,
              ),
            ),
          const SizedBox(height: 20),
          if (!isPremium && !isPending)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(RouteNames.subscription),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B2B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
                child: Text(
                  'Upgrade Now',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            )
          else if (isPremium)
             Text(
                'Enjoy your premium access!',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF30D158),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color.withOpacity(0.7), size: 22),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
