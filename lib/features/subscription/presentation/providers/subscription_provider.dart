import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/push_notification_service.dart';
import '../../data/datasources/subscription_remote_datasource.dart';
import '../../data/models/subscription_plan_model.dart';
import '../../data/models/user_subscription_status_model.dart';
import '../../data/models/subscription_request_status_model.dart';

final subscriptionRemoteDataSourceProvider = Provider((ref) {
  return SubscriptionRemoteDataSource();
});

final subscriptionPlansProvider = FutureProvider<List<SubscriptionPlanModel>>((ref) async {
  final dataSource = ref.read(subscriptionRemoteDataSourceProvider);
  return dataSource.getSubscriptionPlans();
});

final subscriptionStatusProvider = FutureProvider<UserSubscriptionStatusModel>((ref) async {
  final dataSource = ref.read(subscriptionRemoteDataSourceProvider);
  return dataSource.getSubscriptionStatus();
});

// New provider for manual request status
final subscriptionRequestStatusProvider = FutureProvider<SubscriptionRequestStatusModel>((ref) async {
  final dataSource = ref.read(subscriptionRemoteDataSourceProvider);
  return dataSource.getRequestStatus();
});

class SubscriptionState {
  final bool isLoading;
  final String? error;
  final String? message;
  final UserSubscriptionStatusModel? status;
  final SubscriptionRequestStatusModel? requestStatus;

  SubscriptionState({
    this.isLoading = false,
    this.error,
    this.message,
    this.status,
    this.requestStatus,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    String? error,
    String? message,
    UserSubscriptionStatusModel? status,
    SubscriptionRequestStatusModel? requestStatus,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      message: message,
      status: status ?? this.status,
      requestStatus: requestStatus ?? this.requestStatus,
    );
  }
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final SubscriptionRemoteDataSource _dataSource;
  final Ref _ref;

  SubscriptionNotifier(this._dataSource, this._ref) : super(SubscriptionState()) {
    fetchStatus();
    fetchRequestStatus();
  }

  Future<void> fetchStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final status = await _dataSource.getSubscriptionStatus();
      state = state.copyWith(isLoading: false, status: status);
      _ref.invalidate(subscriptionStatusProvider);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchRequestStatus() async {
    try {
      final requestStatus = await _dataSource.getRequestStatus();
      state = state.copyWith(requestStatus: requestStatus);
      _ref.invalidate(subscriptionRequestStatusProvider);
    } catch (_) {}
  }

  Future<bool> verify({
    required String platform,
    required String receiptData,
    required String planId,
  }) async {
    state = state.copyWith(isLoading: true, message: null);
    try {
      final res = await _dataSource.verifySubscription(
        platform: platform,
        receiptData: receiptData,
        planId: planId,
      );
      state = state.copyWith(message: res['message']);
      await fetchStatus();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> cancel() async {
    state = state.copyWith(isLoading: true, message: null);
    try {
      final res = await _dataSource.cancelSubscription();
      state = state.copyWith(message: res['message']);
      await fetchStatus();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> restore({
    required String platform,
    required String receiptData,
  }) async {
    state = state.copyWith(isLoading: true, message: null);
    try {
      final res = await _dataSource.restoreSubscription(
        platform: platform,
        receiptData: receiptData,
      );
      state = state.copyWith(message: res['message']);
      await fetchStatus();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // ── Manual Request Logic ──

  Future<bool> submitRequest({
    required String planId,
    required String planName,
  }) async {
    state = state.copyWith(isLoading: true, message: null);
    try {
      final res = await _dataSource.requestSubscription(
        planId: planId,
        planName: planName,
      );
      PushNotificationService().registerTokenWithBackend(isAdmin: false);
      state = state.copyWith(isLoading: false, message: res['message']);
      await fetchRequestStatus();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final dataSource = ref.read(subscriptionRemoteDataSourceProvider);
  return SubscriptionNotifier(dataSource, ref);
});
