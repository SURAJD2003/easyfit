import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../services/auth_service.dart';
import '../models/auth/register_request.dart';
import '../models/auth/register_response.dart';
import '../models/auth/login_request.dart';
import '../models/auth/login_response.dart';
import '../models/auth/logout_request.dart';
import '../models/auth/forgot_password_request.dart';
import '../models/api_result.dart';

enum AuthStatus { idle, loading, success, error }

class AuthProvider extends ChangeNotifier {
  final _authService = AuthService();

  AuthStatus _status = AuthStatus.idle;
  String? _errorMessage;
  RegisterResponse? _registerResponse;
  String? _token;
  String? _refreshToken;
  Map<String, dynamic>? _userProfile;
  Future<void>? _authCheckFuture;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  RegisterResponse? get registerResponse => _registerResponse;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _token != null;
  
  // Subscription approval status (fetched from /subscriptions/status)
  String? _subscriptionStatus;
  
  bool get isApproved {
    final subStatus = _subscriptionStatus?.toLowerCase();
    
    // Check profile status safely
    String? profileStatus;
    if (_userProfile != null && _userProfile!.containsKey('status')) {
      profileStatus = _userProfile!['status']?.toString().toLowerCase();
    }
    
    print('DEBUG: isApproved check — subStatus: "$subStatus", profileStatus: "$profileStatus"');
    
    // Approved if subscription is active/approved/premium OR if account itself is active
    return subStatus == 'active' || 
           subStatus == 'approved' || 
           subStatus == 'premium' || 
           profileStatus == 'active';
  }

  bool get isRejected {
    if (_subscriptionStatus == null) return false;
    final s = _subscriptionStatus!.toLowerCase();
    return s == 'rejected';
  }

  bool get isPending {
    // If authenticated but we don't have status yet, assume pending
    if (_subscriptionStatus == null && _userProfile == null) return true;
    
    // If explicitly approved or rejected, it's not pending anymore
    if (isApproved || isRejected) return false;
    
    // Otherwise, if status is 'pending' or 'free', it's pending approval
    final s = _subscriptionStatus?.toLowerCase() ?? '';
    return s == 'pending' || s == 'free' || s == '';
  }

  AuthProvider() {
    unawaited(checkAuthStatus());
  }

  Future<void> fetchProfile() async {
    final result = await _authService.getUserProfile();
    if (result.isSuccess) {
      _userProfile = result.data;
      print('DEBUG PROFILE: $_userProfile');
      notifyListeners();
    } else {
      print('DEBUG PROFILE FETCH FAILED');
    }
  }

  /// Fetches subscription status from both singular and plural endpoints.
  /// /subscription/status (singular) is for automated payments.
  /// /subscriptions/status (plural) is for manual admin-approved requests.
  Future<void> fetchSubscriptionStatus() async {
    try {
      final dio = ApiClient().dio;
      
      // 1. Fetch singular status (automated/paid)
      final responseSingular = await dio.get('/subscription/status');
      if (responseSingular.statusCode == 200) {
        final data = responseSingular.data;
        print('DEBUG SINGULAR STATUS: $data');
        if (data is Map<String, dynamic> && data['status'] != null && data['status'] != 'free') {
          _subscriptionStatus = data['status']?.toString();
        }
      }

      // 2. Fetch plural status (manual approval)
      // We use a temporary Dio to bypass the /api prefix if needed, or just use full URL
      final responsePlural = await dio.get('https://api.theeasyfitclinics.com/subscriptions/status');
      if (responsePlural.statusCode == 200) {
        final data = responsePlural.data;
        print('DEBUG PLURAL STATUS: $data');
        if (data is Map<String, dynamic> && data['status'] != null) {
          final pluralStatus = data['status']?.toString();
          // If we already have an active/premium status from singular, don't overwrite with 'pending'
          if (_subscriptionStatus == null || _subscriptionStatus == 'free' || pluralStatus == 'approved') {
            _subscriptionStatus = pluralStatus;
          }
        }
      }
      
      print('DEBUG FINAL SUBSCRIPTION STATUS: $_subscriptionStatus');
    } catch (e) {
      print('DEBUG SUBSCRIPTION STATUS FETCH FAILED: $e');
    }
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    final existingCheck = _authCheckFuture;
    if (existingCheck != null) {
      await existingCheck;
      return;
    }

    _authCheckFuture = _checkAuthStatus();
    try {
      await _authCheckFuture;
    } finally {
      _authCheckFuture = null;
    }
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _refreshToken = prefs.getString('auth_refresh_token');
    if (_token != null) {
      ApiClient().setToken(_token!);
      _status = AuthStatus.success;
      unawaited(fetchProfile()); // fetch profile quietly in background
    }
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      RegisterRequest(
        name: name,
        email: email,
        password: password,
        phone: phone,
      ),
    );

    if (result.isSuccess) {
      _registerResponse = result.data;
      _token = result.data?.token;
      _refreshToken = result.data?.refreshToken;
      _status = AuthStatus.success;

      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString('auth_token', _token!);
      if (_refreshToken != null)
        await prefs.setString('auth_refresh_token', _refreshToken!);

      await fetchProfile();
    } else {
      _errorMessage = result.error?.message ?? 'Registration failed';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      LoginRequest(email: email, password: password),
    );

    if (result.isSuccess) {
      _token = result.data?.token;
      _refreshToken = result.data?.refreshToken;
      _status = AuthStatus.success;

      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString('auth_token', _token!);
      if (_refreshToken != null)
        await prefs.setString('auth_refresh_token', _refreshToken!);

      await fetchProfile();
    } else {
      _errorMessage = result.error?.message ?? 'Login failed';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  void setToken(String token) {
    _token = token;
    notifyListeners();
  }

  Future<void> logoutApi() async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Check if we have refreshToken
    if (_refreshToken == null) {
      // If no refresh token, just logout locally
      _token = null;
      _refreshToken = null;
      _status = AuthStatus.success;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_refresh_token');

      notifyListeners();
      return;
    }

    final result = await _authService.logout(
      LogoutRequest(refreshToken: _refreshToken!),
    );

    if (result.isSuccess) {
      _token = null;
      _refreshToken = null;
      _status = AuthStatus.success;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('auth_refresh_token');
    } else {
      _errorMessage = result.error?.message ?? 'Logout failed';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  Future<void> forgotPassword({required String email}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.forgotPassword(
      ForgotPasswordRequest(email: email),
    );

    if (result.isSuccess) {
      _status = AuthStatus.success;
    } else {
      _errorMessage = result.error?.message ?? 'Failed to send reset link';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _refreshToken = null;
    _userProfile = null;
    _subscriptionStatus = null;
    _status = AuthStatus.idle;
    _registerResponse = null;
    _errorMessage = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_refresh_token');
    ApiClient().clearToken();
    
    notifyListeners();
  }

  void reset() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
