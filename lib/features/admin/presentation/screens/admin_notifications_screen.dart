import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/admin_provider.dart';
import 'admin_main_screen.dart';
import '../widgets/notification_form.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState
    extends State<AdminNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const Color _accent = Color(0xFFFF6B00);
  static const Color _bg = Color(0xFF0F0F0F);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
                    'Notifications',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white38,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: const [
                    Tab(text: 'Broadcast'),
                    Tab(text: 'Segment'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<AdminProvider>(
                builder: (context, provider, _) {
                  final state = provider.notificationsState;

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      // Broadcast Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                            20, 0, 20, 24),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.08),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                    color:
                                        _accent.withOpacity(0.2)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Color(0xFFFF6B00),
                                      size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Send a notification to ALL users.',
                                      style: TextStyle(
                                        color: Color(0xFFFF6B00),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (state.sentSuccess)
                              _SuccessBanner(
                                onDismiss: () => provider
                                    .resetNotificationState(),
                              ),
                            if (state.error != null)
                              _ErrorBanner(message: state.error!),
                            const SizedBox(height: 8),
                            NotificationForm(
                              isSegmented: false,
                              isSending: state.isSending,
                              onSend: ({
                                required title,
                                required body,
                                imageUrl,
                                segment,
                              }) async {
                                await provider.broadcastNotification(
                                  title: title,
                                  body: body,
                                  imageUrl: imageUrl,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      // Segment Tab
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                            20, 0, 20, 24),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: _accent.withOpacity(0.08),
                                borderRadius:
                                    BorderRadius.circular(14),
                                border: Border.all(
                                    color:
                                        _accent.withOpacity(0.2)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Color(0xFFFF6B00),
                                      size: 18),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Target Free, Premium, or All users.',
                                      style: TextStyle(
                                        color: Color(0xFFFF6B00),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (state.sentSuccess)
                              _SuccessBanner(
                                onDismiss: () => provider
                                    .resetNotificationState(),
                              ),
                            if (state.error != null)
                              _ErrorBanner(message: state.error!),
                            const SizedBox(height: 8),
                            NotificationForm(
                              isSegmented: true,
                              isSending: state.isSending,
                              onSend: ({
                                required title,
                                required body,
                                imageUrl,
                                segment,
                              }) async {
                                await provider.segmentNotification(
                                  title: title,
                                  body: body,
                                  segment: segment ?? 'free',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
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

class _SuccessBanner extends StatelessWidget {
  final VoidCallback onDismiss;

  const _SuccessBanner({required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline,
              color: Colors.greenAccent, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Notification sent successfully!',
              style:
                  TextStyle(color: Colors.greenAccent, fontSize: 13),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close,
                color: Colors.greenAccent, size: 16),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline,
              color: Colors.redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                  color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}