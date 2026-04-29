import 'package:flutter/foundation.dart';
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

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  RegisterResponse? get registerResponse => _registerResponse;
  String? get token => _token;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _token != null;

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> fetchProfile() async {
    final result = await _authService.getUserProfile();
    if (result.isSuccess) {
      _userProfile = result.data;
      notifyListeners();
    }
  }

  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _refreshToken = prefs.getString('auth_refresh_token');
    if (_token != null) {
      ApiClient().setToken(_token!);
      _status = AuthStatus.success;
      await fetchProfile(); // fetch profile quietly in background
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
      if (_refreshToken != null) await prefs.setString('auth_refresh_token', _refreshToken!);
      
      await fetchProfile();
    } else {
      _errorMessage = result.error?.message ?? 'Registration failed';
      _status = AuthStatus.error;
    }

    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      LoginRequest(
        email: email,
        password: password,
      ),
    );

    if (result.isSuccess) {
      _token = result.data?.token;
      _refreshToken = result.data?.refreshToken;
      _status = AuthStatus.success;
      
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString('auth_token', _token!);
      if (_refreshToken != null) await prefs.setString('auth_refresh_token', _refreshToken!);
      
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

  void logout() {
    _token = null;
    _refreshToken = null;
    _status = AuthStatus.idle;
    _registerResponse = null;
    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _status = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}