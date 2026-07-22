import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../data/models/subscription_model.dart';
import '../../domain/entities/index.dart';
import '../../domain/usecases/index.dart';
import '../../../../services/push_notification_service.dart';

// ─── STATE CLASSES ───────────────────────────────────────────────────────────

class AuthState {
  final String? token;
  final String? adminId;
  final String? adminName;
  final String? adminEmail;
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.token,
    this.adminId,
    this.adminName,
    this.adminEmail,
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    String? token,
    String? adminId,
    String? adminName,
    String? adminEmail,
    bool? isLoggedIn,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      token: token ?? this.token,
      adminId: adminId ?? this.adminId,
      adminName: adminName ?? this.adminName,
      adminEmail: adminEmail ?? this.adminEmail,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UsersState {
  final List<AdminUserEntity> users;
  final AdminUserEntity? selectedUser;
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final String searchQuery;

  const UsersState({
    this.users = const [],
    this.selectedUser,
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.searchQuery = '',
  });

  List<AdminUserEntity> get filteredUsers {
    if (searchQuery.isEmpty) return users;
    return users
        .where((u) =>
            u.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
            u.email.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  UsersState copyWith({
    List<AdminUserEntity>? users,
    AdminUserEntity? selectedUser,
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    String? searchQuery,
    bool clearSelectedUser = false,
    bool clearError = false,
  }) {
    return UsersState(
      users: users ?? this.users,
      selectedUser:
          clearSelectedUser ? null : selectedUser ?? this.selectedUser,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearError ? null : error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class SubscriptionsState {
  final List<SubscriptionEntity> subscriptions;
  final SubscriptionEntity? selectedSubscription;
  final bool isLoading;
  final bool isActionLoading;
  final String? error;
  final String filterStatus;
  final String searchQuery;

  const SubscriptionsState({
    this.subscriptions = const [],
    this.selectedSubscription,
    this.isLoading = false,
    this.isActionLoading = false,
    this.error,
    this.filterStatus = 'all',
    this.searchQuery = '',
  });

  List<SubscriptionEntity> get filteredSubscriptions {
    return getSubscriptionsForTab(filterStatus ?? 'all');
  }

  List<SubscriptionEntity> getSubscriptionsForTab(String tabStatus) {
    var filtered = subscriptions;
    if (tabStatus != 'all') {
      filtered = filtered.where((s) => s.status.toLowerCase() == tabStatus.toLowerCase()).toList();
    }
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        final nameMatches = s.userName.toLowerCase().contains(query);
        final emailMatches = s.userEmail.toLowerCase().contains(query);
        return nameMatches || emailMatches;
      }).toList();
    }
    return filtered;
  }

  SubscriptionsState copyWith({
    List<SubscriptionEntity>? subscriptions,
    SubscriptionEntity? selectedSubscription,
    bool? isLoading,
    bool? isActionLoading,
    String? error,
    String? filterStatus,
    String? searchQuery,
    bool clearSelectedSub = false,
    bool clearError = false,
  }) {
    return SubscriptionsState(
      subscriptions: subscriptions ?? this.subscriptions,
      selectedSubscription: clearSelectedSub
          ? null
          : selectedSubscription ?? this.selectedSubscription,
      isLoading: isLoading ?? this.isLoading,
      isActionLoading: isActionLoading ?? this.isActionLoading,
      error: clearError ? null : error ?? this.error,
      filterStatus: filterStatus ?? this.filterStatus,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AnalyticsState {
  final AnalyticsEntity? analytics;
  final bool isLoading;
  final String? error;

  const AnalyticsState({
    this.analytics,
    this.isLoading = false,
    this.error,
  });

  AnalyticsState copyWith({
    AnalyticsEntity? analytics,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AnalyticsState(
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class NotificationsState {
  final bool isSending;
  final String? error;
  final bool sentSuccess;

  const NotificationsState({
    this.isSending = false,
    this.error,
    this.sentSuccess = false,
  });

  NotificationsState copyWith({
    bool? isSending,
    String? error,
    bool? sentSuccess,
    bool clearError = false,
  }) {
    return NotificationsState(
      isSending: isSending ?? this.isSending,
      error: clearError ? null : error ?? this.error,
      sentSuccess: sentSuccess ?? this.sentSuccess,
    );
  }
}

class ReportsState {
  final ReportEntity? report;
  final bool isLoading;
  final String? error;

  const ReportsState({
    this.report,
    this.isLoading = false,
    this.error,
  });

  ReportsState copyWith({
    ReportEntity? report,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ReportsState(
      report: report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

// ─── MAIN PROVIDER ───────────────────────────────────────────────────────────

class AdminProvider extends ChangeNotifier {
  AuthState _authState = const AuthState();
  UsersState _usersState = const UsersState();
  SubscriptionsState _subscriptionsState = const SubscriptionsState();
  AnalyticsState _analyticsState = const AnalyticsState();
  NotificationsState _notificationsState = const NotificationsState();
  ReportsState _reportsState = const ReportsState();

  AuthState get authState => _authState;
  UsersState get usersState => _usersState;
  SubscriptionsState get subscriptionsState => _subscriptionsState;
  AnalyticsState get analyticsState => _analyticsState;
  NotificationsState get notificationsState => _notificationsState;
  ReportsState get reportsState => _reportsState;

  String get _token => _authState.token ?? '';

  AdminRepositoryImpl _buildRepo() {
    return AdminRepositoryImpl(
      remoteDataSource: AdminRemoteDataSource(client: http.Client()),
      token: _token,
    );
  }

  // ─── AUTH ─────────────────────────────────────────────────────────────────

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    // ✅ Always trim before sending
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      _authState = _authState.copyWith(
        isLoading: false,
        error: 'Email and password are required.',
      );
      notifyListeners();
      return false;
    }

    _authState = _authState.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final datasource = AdminRemoteDataSource(client: http.Client());
      final result = await datasource.login(
        email: cleanEmail,
        password: cleanPassword,
      );

      // ✅ Validate token received
      if (result.token.isEmpty) {
        throw Exception('No token received from server.');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('admin_token', result.token);
      await prefs.setString('admin_id', result.adminId);
      await prefs.setString('admin_name', result.name);
      if (result.email != null) {
        await prefs.setString('admin_email', result.email!);
      }

      _authState = _authState.copyWith(
        token: result.token,
        adminId: result.adminId,
        adminName: result.name,
        adminEmail: result.email,
        isLoggedIn: true,
        isLoading: false,
        error: null,
      );
      
      // Stop activity tracking service if running
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('active_session_id'); // Clear any tracking session

        final service = FlutterBackgroundService();
        if (await service.isRunning()) {
          service.invoke('stopService');
          // Try again after a delay to handle race conditions
          Future.delayed(const Duration(seconds: 2), () async {
            if (await service.isRunning()) {
              service.invoke('stopService');
            }
          });
        }
      } catch (e) {
        debugPrint('Failed to stop background service: $e');
      }
      
      PushNotificationService().registerTokenWithBackend();
      notifyListeners();
      return true;
    } catch (e) {
      _authState = _authState.copyWith(
        isLoading: false,
        isLoggedIn: false,
        error: _parseError(e),
      );
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');
    if (token != null && token.isNotEmpty) {
      _authState = _authState.copyWith(
        token: token,
        adminId: prefs.getString('admin_id'),
        adminName: prefs.getString('admin_name'),
        adminEmail: prefs.getString('admin_email'),
        isLoggedIn: true,
      );
      
      // Stop activity tracking service if running
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('active_session_id'); // Clear any tracking session

        final service = FlutterBackgroundService();
        if (await service.isRunning()) {
          service.invoke('stopService');
          // Try again after a delay to handle race conditions
          Future.delayed(const Duration(seconds: 2), () async {
            if (await service.isRunning()) {
              service.invoke('stopService');
            }
          });
        }
      } catch (e) {
        debugPrint('Failed to stop background service: $e');
      }
      
      PushNotificationService().registerTokenWithBackend();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token');
    await prefs.remove('admin_id');
    await prefs.remove('admin_name');
    await prefs.remove('admin_email');

    _authState = const AuthState();
    _usersState = const UsersState();
    _subscriptionsState = const SubscriptionsState();
    _analyticsState = const AnalyticsState();
    _notificationsState = const NotificationsState();
    _reportsState = const ReportsState();
    notifyListeners();
  }

  // ─── USERS ────────────────────────────────────────────────────────────────

  Future<void> fetchAllUsers() async {
    _usersState = _usersState.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final users = await GetAllUsersUseCase(
        repository: _buildRepo(),
      ).call();
      _usersState = _usersState.copyWith(
        users: users,
        isLoading: false,
        isActionLoading: false,
      );
    } catch (e) {
      _usersState = _usersState.copyWith(
        isLoading: false,
        isActionLoading: false,
        error: _parseError(e),
      );
    }
    notifyListeners();
  }

  Future<void> fetchUserDetail({required String userId}) async {
    _usersState = _usersState.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final user = await GetUserDetailUseCase(
        repository: _buildRepo(),
      ).call(userId: userId);
      _usersState = _usersState.copyWith(
        selectedUser: user,
        isLoading: false,
      );
    } catch (e) {
      _usersState = _usersState.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
    notifyListeners();
  }

  Future<bool> deleteUser({required String userId}) async {
    _usersState =
        _usersState.copyWith(isActionLoading: true, clearError: true);
    notifyListeners();

    try {
      await DeleteUserUseCase(repository: _buildRepo()).call(userId: userId);
      final updated =
          _usersState.users.where((u) => u.id != userId).toList();
      _usersState = _usersState.copyWith(
        users: updated,
        isActionLoading: false,
        clearSelectedUser: true,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _usersState = _usersState.copyWith(
        isActionLoading: false,
        error: _parseError(e),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateUser({required String userId}) async {
    _usersState =
        _usersState.copyWith(isActionLoading: true, clearError: true);
    notifyListeners();

    try {
      await ActivateUserUseCase(repository: _buildRepo())
          .call(userId: userId);
      await fetchAllUsers();
      await fetchUserDetail(userId: userId);
      _usersState = _usersState.copyWith(isActionLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      _usersState = _usersState.copyWith(
        isActionLoading: false,
        error: _parseError(e),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> deactivateUser({required String userId, String? reason}) async {
    _usersState =
        _usersState.copyWith(isActionLoading: true, clearError: true);
    notifyListeners();
    try {
      await DeactivateUserUseCase(repository: _buildRepo())
          .call(userId: userId, reason: reason);
      await fetchAllUsers();
      await fetchUserDetail(userId: userId);
      _usersState = _usersState.copyWith(isActionLoading: false);
      notifyListeners();
      return true;
    } catch (e) {
      _usersState = _usersState.copyWith(
        isActionLoading: false,
        error: _parseError(e),
      );
      notifyListeners();
      return false;
    }
  }

  void searchUsers(String query) {
    _usersState = _usersState.copyWith(searchQuery: query);
    notifyListeners();
  }

  // ─── SUBSCRIPTIONS ────────────────────────────────────────────────────────

  Future<void> fetchSubscriptions() async {
    _subscriptionsState = _subscriptionsState.copyWith(
      isLoading: true,
      clearError: true,
    );
    notifyListeners();

    try {
      final repo = _buildRepo();
      final regular = await repo.getSubscriptions();
      
      List<SubscriptionEntity> combined = List.from(regular);
      
      try {
        final due = await repo.getDueSubscriptions();
        final List<SubscriptionEntity> mappedDue = due.map<SubscriptionEntity>((e) => SubscriptionModel(
          id: e.id,
          userId: e.userId,
          userName: e.userName,
          userEmail: e.userEmail,
          plan: e.plan,
          status: 'due',
          requestedAt: e.requestedAt,
          resolvedAt: e.resolvedAt,
          expiryDate: e.expiryDate,
          note: e.note,
          reason: e.reason,
        )).toList();
        
        combined.addAll(mappedDue);
      } catch (e) {
        debugPrint('Failed to fetch due subscriptions: $e');
      }

      _subscriptionsState = _subscriptionsState.copyWith(
        subscriptions: combined,
        isLoading: false,
      );
    } catch (e) {
      _subscriptionsState = _subscriptionsState.copyWith(
        error: _parseError(e),
        isLoading: false,
      );
    }
    notifyListeners();
  }

  Future<void> fetchSubscriptionDetail({required String subId}) async {
    _subscriptionsState = _subscriptionsState.copyWith(
      isLoading: true,
      clearError: true,
    );
    notifyListeners();

    try {
      final sub = await GetSubscriptionDetailUseCase(
        repository: _buildRepo(),
      ).call(subId: subId);
      _subscriptionsState = _subscriptionsState.copyWith(
        selectedSubscription: sub,
        isLoading: false,
      );
    } catch (e) {
      _subscriptionsState = _subscriptionsState.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
    notifyListeners();
  }

  Future<bool> approveSubscription({required String subId, String? note}) async {
    _subscriptionsState = _subscriptionsState.copyWith(
      isActionLoading: true,
      clearError: true,
    );
    notifyListeners();

    try {
      // First, approve the subscription request
      await ApproveSubscriptionUseCase(repository: _buildRepo())
          .call(subId: subId, note: note);
      
      // Find the subscription to get userId and plan for granting
      final sub = _subscriptionsState.subscriptions
          .firstWhere((s) => s.id == subId, orElse: () => _subscriptionsState.subscriptions.first);
      
      // Also grant the subscription to the user so their status changes from 'free' to 'active'
      try {
        await GrantSubscriptionUseCase(repository: _buildRepo()).call(
          userId: sub.userId,
          planId: sub.plan,
        );
      } catch (_) {
        // Grant may fail if already granted, that's OK
      }

      // ✅ Ensure the user account is also activated so they can access the dashboard
      try {
        await ActivateUserUseCase(repository: _buildRepo()).call(userId: sub.userId);
      } catch (_) {
        // Ignore activation failures
      }
      
      await fetchSubscriptions();
      return true;
    } catch (e) {
      _subscriptionsState = _subscriptionsState.copyWith(error: _parseError(e));
      notifyListeners();
      return false;
    } finally {
      _subscriptionsState = _subscriptionsState.copyWith(isActionLoading: false);
      notifyListeners();
    }
  }

  Future<bool> rejectSubscription({required String subId, String? reason}) async {
    _subscriptionsState = _subscriptionsState.copyWith(
      isActionLoading: true,
      clearError: true,
    );
    notifyListeners();

    try {
      await RejectSubscriptionUseCase(repository: _buildRepo())
          .call(subId: subId, reason: reason);
      await fetchSubscriptions();
      return true;
    } catch (e) {
      _subscriptionsState = _subscriptionsState.copyWith(error: _parseError(e));
      notifyListeners();
      return false;
    } finally {
      _subscriptionsState = _subscriptionsState.copyWith(isActionLoading: false);
      notifyListeners();
    }
  }

  Future<bool> grantSubscription({
    required String userId,
    required String planId,
    String? expiryDate,
    String? reason,
  }) async {
    _usersState = _usersState.copyWith(isActionLoading: true, clearError: true);
    notifyListeners();

    try {
      await GrantSubscriptionUseCase(repository: _buildRepo()).call(
        userId: userId,
        planId: planId,
        expiryDate: expiryDate,
        reason: reason,
      );
      
      // Refresh the specific user's detail
      await fetchUserDetail(userId: userId);
      return true;
    } catch (e) {
      _usersState = _usersState.copyWith(error: _parseError(e));
      notifyListeners();
      return false;
    } finally {
      _usersState = _usersState.copyWith(isActionLoading: false);
      notifyListeners();
    }
  }

  void filterSubscriptions(String status) {
    _subscriptionsState =
        _subscriptionsState.copyWith(filterStatus: status);
    notifyListeners();
  }

  void searchSubscriptions(String query) {
    _subscriptionsState =
        _subscriptionsState.copyWith(searchQuery: query);
    notifyListeners();
  }

  // ─── ANALYTICS ────────────────────────────────────────────────────────────

  Future<void> fetchAnalytics() async {
    _analyticsState = _analyticsState.copyWith(
      isLoading: true,
      clearError: true,
    );
    notifyListeners();

    try {
      final analytics = await GetAnalyticsUseCase(
        repository: _buildRepo(),
      ).call();
      _analyticsState = _analyticsState.copyWith(
        analytics: analytics,
        isLoading: false,
      );
    } catch (e) {
      _analyticsState = _analyticsState.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
    notifyListeners();
  }

  // ─── NOTIFICATIONS ────────────────────────────────────────────────────────

  Future<bool> broadcastNotification({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    _notificationsState = _notificationsState.copyWith(
      isSending: true,
      clearError: true,
      sentSuccess: false,
    );
    notifyListeners();

    try {
      await BroadcastNotificationUseCase(repository: _buildRepo())
          .call(title: title, body: body, imageUrl: imageUrl);
      _notificationsState = _notificationsState.copyWith(
        isSending: false,
        sentSuccess: true,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _notificationsState = _notificationsState.copyWith(
        isSending: false,
        error: _parseError(e),
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> segmentNotification({
    required String title,
    required String body,
    required String segment,
  }) async {
    _notificationsState = _notificationsState.copyWith(
      isSending: true,
      clearError: true,
      sentSuccess: false,
    );
    notifyListeners();

    try {
      await SegmentNotificationUseCase(repository: _buildRepo())
          .call(title: title, body: body, segment: segment);
      _notificationsState = _notificationsState.copyWith(
        isSending: false,
        sentSuccess: true,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _notificationsState = _notificationsState.copyWith(
        isSending: false,
        error: _parseError(e),
      );
      notifyListeners();
      return false;
    }
  }

  void resetNotificationState() {
    _notificationsState = const NotificationsState();
    notifyListeners();
  }

  // ─── REPORTS ──────────────────────────────────────────────────────────────

  Future<void> fetchReports({String? from, String? to}) async {
    _reportsState = _reportsState.copyWith(
      isLoading: true,
      clearError: true,
    );
    notifyListeners();

    try {
      final report = await GetReportsUseCase(
        repository: _buildRepo(),
      ).call(from: from, to: to);
      _reportsState = _reportsState.copyWith(
        report: report,
        isLoading: false,
      );
    } catch (e) {
      _reportsState = _reportsState.copyWith(
        isLoading: false,
        error: _parseError(e),
      );
    }
    notifyListeners();
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  // ✅ FIXED — now handles all real API error formats
  String _parseError(dynamic e) {
    final msg = e.toString().replaceAll('Exception: ', '').trim();

    if (msg.contains('401') ||
        msg.toLowerCase().contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    }
    if (msg.toLowerCase().contains('invalid')) {
      return 'Invalid email or password.';
    }
    if (msg.contains('403')) return 'Access denied.';
    if (msg.contains('404')) return 'Resource not found.';
    if (msg.contains('500')) return 'Server error. Please try again.';
    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Network is unreachable')) {
      return 'No internet connection.';
    }
    if (msg.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    }
    if (msg.isEmpty) return 'Something went wrong.';
    return msg;
  }
}