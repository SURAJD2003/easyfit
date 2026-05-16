import '../entities/index.dart';

abstract class AdminRepository {
  // Auth
  Future<String> login({required String email, required String password});
  Future<void> logout();

  // Users
  Future<List<AdminUserEntity>> getAllUsers();
  Future<AdminUserEntity> getUserDetail({required String userId});
  Future<void> deleteUser({required String userId});
  Future<void> activateUser({required String userId});
  Future<void> deactivateUser({required String userId, String? reason});

  // Subscriptions
  Future<List<SubscriptionEntity>> getSubscriptions();
  Future<SubscriptionEntity> getSubscriptionDetail({required String subId});
  Future<void> approveSubscription({required String subId, String? note});
  Future<void> rejectSubscription({required String subId, String? reason});
  Future<void> updateSubscription({required String subId, required Map<String, dynamic> data});
  Future<void> grantSubscription({required String userId, required String planId, String? expiryDate, String? reason});

  // Analytics
  Future<AnalyticsEntity> getAnalytics();

  // Notifications
  Future<void> broadcastNotification({required String title, required String body, String? imageUrl});
  Future<void> segmentNotification({required String title, required String body, required String segment});

  // Reports
  Future<ReportEntity> getReports({String? from, String? to});
}