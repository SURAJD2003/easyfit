import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/router/route_names.dart';
import '../../data/models/app_notification.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationProvider()..fetchNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Announcements',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: provider.isLoading
                ? null
                : () =>
                      context.read<NotificationProvider>().fetchNotifications(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFF6B2B),
        backgroundColor: const Color(0xFF141414),
        onRefresh: () =>
            context.read<NotificationProvider>().fetchNotifications(),
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationProvider provider) {
    if (provider.isLoading && provider.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B2B)),
      );
    }

    if (provider.errorMessage != null && provider.notifications.isEmpty) {
      final isSessionExpired = provider.errorMessage!
              .toLowerCase()
              .contains('session expired') ||
          provider.errorMessage!.toLowerCase().contains('sign in') ||
          provider.errorMessage!.toLowerCase().contains('unauthorized');

      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          Icon(
            isSessionExpired
                ? Icons.lock_clock_outlined
                : Icons.notifications_off_outlined,
            color: Colors.white.withValues(alpha: 0.45),
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          if (isSessionExpired)
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.go(RouteNames.login),
                icon: const Icon(Icons.login_rounded, size: 18),
                label: Text('Log In Again', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B2B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            )
          else
            Center(
              child: ElevatedButton.icon(
                onPressed: () => context.read<NotificationProvider>().fetchNotifications(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('Try Again', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6B2B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
        ],
      );
    }

    if (provider.notifications.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 100),
          Icon(
            Icons.campaign_outlined,
            color: Colors.white.withValues(alpha: 0.4),
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No announcements yet',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Announcements from EasyFit Clinics will appear here.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => context.read<NotificationProvider>().fetchNotifications(),
              icon: const Icon(Icons.refresh_rounded, size: 18, color: Color(0xFFFF6B2B)),
              label: Text(
                'Refresh',
                style: GoogleFonts.inter(
                  color: const Color(0xFFFF6B2B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFFF6B2B)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: provider.notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _NotificationTile(notification: provider.notifications[index]);
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final dateText = notification.createdAt == null
        ? ''
        : DateFormat('MMM d, yyyy - h:mm a').format(notification.createdAt!);

    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          context.read<NotificationProvider>().markAsRead(notification.id);
        }
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isRead
                ? Colors.white.withValues(alpha: 0.08)
                : const Color(0xFFFF6B2B).withValues(alpha: 0.4),
            width: notification.isRead ? 1 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFFF6B2B).withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification.isRead
                        ? Icons.notifications_none_rounded
                        : Icons.campaign_rounded,
                    color: notification.isRead
                        ? Colors.white54
                        : const Color(0xFFFF6B2B),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFF6B2B),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (dateText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          dateText,
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (notification.body.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                notification.body,
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
            if (notification.imageUrl != null &&
                notification.imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  notification.imageUrl!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
