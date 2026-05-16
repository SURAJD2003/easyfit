import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../core/router/route_names.dart';

class ApprovalPendingScreen extends StatelessWidget {
  const ApprovalPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isRejected = auth.isRejected;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium Icon/Illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isRejected ? Colors.red : const Color(0xFFFF7A00)).withOpacity(0.1),
                  border: Border.all(
                    color: (isRejected ? Colors.red : const Color(0xFFFF7A00)).withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: Icon(
                  isRejected ? Icons.error_outline : Icons.verified_user_outlined,
                  size: 60,
                  color: isRejected ? Colors.red : const Color(0xFFFF7A00),
                ),
              ),
              const SizedBox(height: 48),
              
              // Title
              Text(
                isRejected ? 'Request Rejected' : 'Approval Pending',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Description
              Text(
                isRejected 
                    ? 'Your subscription request has been rejected. Please try again or contact our support team for more information.'
                    : 'Your account has been successfully created. For security reasons, our administrators need to approve your account before you can access the dashboard.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Instructions
              if (!isRejected)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.timer_outlined, 'Usually takes less than 24 hours'),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.mail_outline, 'You will receive an email once approved'),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.1),
                    ),
                  ),
                  child: _buildInfoRow(Icons.info_outline, 'Status: Rejected. Please try again.'),
                ),
              const SizedBox(height: 48),
              
              // Refresh/Check Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final authProvider = context.read<AuthProvider>();
                    await authProvider.fetchSubscriptionStatus();
                    await authProvider.fetchProfile();
                    
                    if (!context.mounted) return;

                    if (authProvider.isApproved) {
                      context.go(RouteNames.dashboard);
                    } else if (authProvider.isRejected) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your request was rejected. Please try again.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account still pending approval'),
                          backgroundColor: Color(0xFF1A1A1A),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRejected ? Colors.red : const Color(0xFFFF7A00),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isRejected ? 'Check Status Again' : 'Check Approval Status',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              
              if (isRejected) ...[
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    context.go(RouteNames.subscription);
                  },
                  child: Text(
                    'Try Again / Change Plan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFF7A00),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 16),
              
              // Sign Out Option
              TextButton(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) context.go(RouteNames.login);
                },
                child: Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFFFF7A00)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}
