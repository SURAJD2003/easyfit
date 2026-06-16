import '../../domain/entities/index.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;
  final String token;

  AdminRepositoryImpl({
    required this.remoteDataSource,
    required this.token,
  });

  @override
  Future<String> login({
    required String email,
    required String password,
  }) async {
    final result = await remoteDataSource.login(
      email: email,
      password: password,
    );
    return result.token;
  }

  @override
  Future<void> logout() async {}

  @override
  Future<List<AdminUserEntity>> getAllUsers() async {
    return await remoteDataSource.getAllUsers(token: token);
  }

  @override
  Future<AdminUserEntity> getUserDetail({required String userId}) async {
    return await remoteDataSource.getUserDetail(token: token, userId: userId);
  }

  @override
  Future<void> deleteUser({required String userId}) async {
    await remoteDataSource.deleteUser(token: token, userId: userId);
  }

  @override
  Future<void> activateUser({required String userId}) async {
    await remoteDataSource.activateUser(token: token, userId: userId);
  }

  @override
  Future<void> deactivateUser({required String userId, String? reason}) async {
    await remoteDataSource.deactivateUser(
        token: token, userId: userId, reason: reason);
  }

  @override
  Future<List<SubscriptionEntity>> getSubscriptions() async {
    return await remoteDataSource.getSubscriptions(token: token);
  }

  @override
  Future<List<SubscriptionEntity>> getDueSubscriptions() async {
    return await remoteDataSource.getDueSubscriptions(token: token);
  }

  @override
  Future<SubscriptionEntity> getSubscriptionDetail({
    required String subId,
  }) async {
    return await remoteDataSource.getSubscriptionDetail(
      token: token,
      subId: subId,
    );
  }

  @override
  Future<void> approveSubscription({required String subId, String? note}) async {
    await remoteDataSource.approveSubscription(token: token, subId: subId, note: note);
  }

  @override
  Future<void> rejectSubscription({required String subId, String? reason}) async {
    await remoteDataSource.rejectSubscription(token: token, subId: subId, reason: reason);
  }

  @override
  Future<void> updateSubscription({
    required String subId,
    required Map<String, dynamic> data,
  }) async {
    await remoteDataSource.updateSubscription(
      token: token,
      subId: subId,
      data: data,
    );
  }

  @override
  Future<void> grantSubscription({
    required String userId,
    required String planId,
    String? expiryDate,
    String? reason,
  }) async {
    await remoteDataSource.grantSubscription(
      token: token,
      userId: userId,
      planId: planId,
      expiryDate: expiryDate,
      reason: reason,
    );
  }

  @override
  Future<AnalyticsEntity> getAnalytics() async {
    return await remoteDataSource.getAnalytics(token: token);
  }

  @override
  Future<void> broadcastNotification({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    await remoteDataSource.broadcastNotification(
      token: token,
      title: title,
      body: body,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<void> segmentNotification({
    required String title,
    required String body,
    required String segment,
  }) async {
    await remoteDataSource.segmentNotification(
      token: token,
      title: title,
      body: body,
      segment: segment,
    );
  }

  @override
  Future<ReportEntity> getReports({String? from, String? to}) async {
    return await remoteDataSource.getReports(token: token, from: from, to: to);
  }
}