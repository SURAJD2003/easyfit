# 🚀 Admin Module Integration Guide

## Step-by-Step Implementation

This guide walks you through integrating the Admin Module into your existing Easyfit Clinic app.

---

## Step 1: Update `pubspec.yaml` Dependencies

Ensure you have these dependencies (should already be there):

```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  dio: ^5.9.2
  shared_preferences: ^2.5.5
  phosphor_flutter: ^2.1.0
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  google_fonts: ^6.3.3

dev_dependencies:
  build_runner: ^2.5.4
  riverpod_generator: ^2.6.4
  freezed: ^2.5.8
  json_serializable: ^6.9.5
```

Run:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- Freezed models
- JSON serialization
- Riverpod code generation

---

## Step 2: Update `core/api_client.dart`

Add admin token handling to your Dio interceptor:

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  late Dio _dio;
  String? _adminToken;

  Dio get dio => _dio;

  Future<void> initialize() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _adminToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          if (e.response?.statusCode == 401) {
            // Handle token refresh or logout
            _handleUnauthorized();
          }
          return handler.next(e);
        },
      ),
    );
  }

  void setAdminToken(String token) {
    _adminToken = token;
  }

  void clearAdminToken() {
    _adminToken = null;
  }

  void _handleUnauthorized() {
    // Clear local storage and navigate to login
    // Implementation depends on your navigation setup
  }
}
```

---

## Step 3: Update `providers/auth_provider.dart` (if exists)

Add Riverpod provider for SharedPreferences:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderContainer',
  );
});
```

---

## Step 4: Update `main.dart` or `bootstrap.dart`

Initialize SharedPreferences and set up ProviderContainer:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/api_client.dart';
import 'providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Dio
  await ApiClient().initialize();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const EasyFitApp(),
    ),
  );
}
```

---

## Step 5: Setup GoRouter Routes

In `core/router/router.dart` or `app.dart`:

```dart
import 'package:go_router/go_router.dart';
import '../features/admin/presentation/screens/index.dart';
import '../providers/auth_provider.dart';

final adminRoutes = [
  GoRoute(
    path: '/admin/login',
    name: 'adminLogin',
    builder: (context, state) => const AdminLoginScreen(),
    redirect: (context, state) {
      // Redirect to dashboard if already logged in
      // Implementation depends on your state management
      return null;
    },
  ),
  GoRoute(
    path: '/admin/dashboard',
    name: 'adminDashboard',
    builder: (context, state) => const AdminDashboardScreen(),
    redirect: (context, state) {
      // Check if admin is logged in
      // If not, redirect to login
      return null;
    },
  ),
  GoRoute(
    path: '/admin/users',
    name: 'adminUsers',
    builder: (context, state) => const AdminUsersScreen(),
  ),
  GoRoute(
    path: '/admin/users/:userId',
    name: 'adminUserDetail',
    builder: (context, state) {
      final userId = state.pathParameters['userId']!;
      return AdminUserDetailScreen(userId: userId);
    },
  ),
  GoRoute(
    path: '/admin/subscriptions',
    name: 'adminSubscriptions',
    builder: (context, state) => const AdminSubscriptionsScreen(),
  ),
];

// In your main router setup:
final router = GoRouter(
  routes: [
    // ... existing routes
    ...adminRoutes,
  ],
);
```

---

## Step 6: Test with Mock Data (Optional)

To test without a real backend, use `MockAdminDataService`:

```dart
// In your admin_provider.dart, temporarily replace real calls:

import '../data/services/mock_admin_service.dart';

// For testing:
final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final mockService = MockAdminDataService();
  
  // Create mock datasources
  // Return repository with mock data
});
```

For demo credentials:
- **Email**: `admin@easyfit.com`
- **Password**: `admin123456`

---

## Step 7: Verify File Structure

Ensure all files are created:

```
✅ lib/features/admin/
   ├── data/
   │   ├── datasources/
   │   │   ├── admin_remote_datasource.dart
   │   │   └── admin_local_datasource.dart
   │   ├── models/
   │   │   ├── admin_login_model.dart
   │   │   ├── admin_user_model.dart
   │   │   ├── subscription_request_model.dart
   │   │   └── index.dart
   │   ├── repositories/
   │   │   └── admin_repository.dart
   │   └── services/
   │       └── mock_admin_service.dart
   ├── domain/
   │   ├── entities/
   │   │   ├── admin_entity.dart
   │   │   ├── admin_user_entity.dart
   │   │   ├── subscription_request_entity.dart
   │   │   └── index.dart
   │   └── usecases/
   │       ├── admin_login_usecase.dart
   │       ├── get_dashboard_stats_usecase.dart
   │       ├── get_all_users_usecase.dart
   │       ├── get_user_details_usecase.dart
   │       ├── get_subscriptions_usecase.dart
   │       ├── approve_subscription_usecase.dart
   │       ├── reject_subscription_usecase.dart
   │       ├── admin_logout_usecase.dart
   │       └── index.dart
   └── presentation/
       ├── providers/
       │   └── admin_provider.dart
       ├── screens/
       │   ├── admin_login_screen.dart
       │   ├── admin_dashboard_screen.dart
       │   ├── admin_users_screen.dart
       │   ├── admin_user_detail_screen.dart
       │   ├── admin_subscriptions_screen.dart
       │   └── index.dart
       └── widgets/
           ├── admin_stat_card.dart
           ├── status_badge.dart
           ├── subscription_card.dart
           ├── user_list_item.dart
           ├── dialogs.dart
           └── index.dart
```

---

## Step 8: Run Build Runner (Important!)

Generate Freezed models and JSON serialization:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Expected output**:
```
[INFO] Building new asset graph completed, took 1234ms
[INFO] ✨ Build succeeded! Generated 12 files.
```

---

## Step 9: Test the Module

### Option A: Test with Real Backend

1. Ensure backend APIs are running at `https://parkmitra.com/api`
2. Launch app and navigate to `/admin/login`
3. Use real admin credentials
4. Verify all screens load correctly

### Option B: Test with Mock Data

1. Keep `MockAdminDataService` connected
2. Use demo credentials:
   - Email: `admin@easyfit.com`
   - Password: `admin123456`

---

## Step 10: Connect to Backend APIs

Update your backend to implement these endpoints:

<details>
<summary><b>Click to expand Backend API Specifications</b></summary>

### 1. Admin Login
```
POST /admin/login
Request:
{
  "email": "admin@easyfit.com",
  "password": "admin123456"
}

Response (200):
{
  "adminId": "admin_001",
  "name": "Sarah Johnson",
  "email": "admin@easyfit.com",
  "role": "admin",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "refresh_token_123...",
  "profileImage": null,
  "permissions": ["view_users", "approve_subscriptions", ...]
}
```

### 2. Dashboard Stats
```
GET /admin/dashboard/stats
Headers: Authorization: Bearer {token}

Response (200):
{
  "totalUsers": 2847,
  "pendingRequests": 34,
  "approvedSubscriptions": 1923,
  "rejectedSubscriptions": 156,
  "activeSubscriptions": 1834,
  "totalRevenue": 145678.50,
  "recentRequests": [...]
}
```

### 3. Get All Users
```
GET /admin/users?page=1&limit=20&search=john&status=active
Headers: Authorization: Bearer {token}

Response (200):
[
  {
    "userId": "user_123",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+1234567890",
    "subscriptionStatus": "active",
    "createdAt": "2024-01-15T10:30:00Z",
    "lastLogin": "2024-04-20T15:45:00Z",
    "isActive": true,
    "profileImage": null
  },
  ...
]
```

### 4. Get User Details
```
GET /admin/users/{userId}
Headers: Authorization: Bearer {token}

Response (200):
{
  "userId": "user_123",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+1234567890",
  "address": "123 Main St",
  "city": "San Francisco",
  "country": "USA",
  "subscriptionStatus": "active",
  "createdAt": "2024-01-15T10:30:00Z",
  "totalSessions": 127,
  "totalSteps": 2453000,
  "totalCalories": 89500,
  "subscriptionHistory": [...]
}
```

### 5. Get Subscriptions
```
GET /admin/subscriptions?status=pending&page=1&limit=20
Headers: Authorization: Bearer {token}

Response (200):
[
  {
    "subscriptionId": "sub_456",
    "userId": "user_123",
    "userName": "John Doe",
    "userEmail": "john@example.com",
    "plan": "monthly",
    "status": "pending",
    "requestedDate": "2024-04-18T08:20:00Z",
    "price": 29.99,
    "billingCycle": "monthly"
  },
  ...
]
```

### 6. Approve Subscription
```
PATCH /admin/subscriptions/{subscriptionId}/approve
Headers: Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "note": "Approved for premium access"
}

Response (200):
{
  "subscriptionId": "sub_456",
  "status": "approved",
  "approvedBy": "admin@easyfit.com",
  "approvedDate": "2024-04-20T10:15:00Z",
  ...
}
```

### 7. Reject Subscription
```
PATCH /admin/subscriptions/{subscriptionId}/reject
Headers: Authorization: Bearer {token}
Content-Type: application/json

Request:
{
  "reason": "Age requirement not met"
}

Response (200):
{
  "subscriptionId": "sub_456",
  "status": "rejected",
  "rejectedBy": "admin@easyfit.com",
  "rejectionReason": "Age requirement not met",
  "rejectedDate": "2024-04-20T10:15:00Z",
  ...
}
```

</details>

---

## Troubleshooting

### Issue: "sharedPreferencesProvider must be overridden"

**Solution**: Add override in `main.dart`:
```dart
ProviderScope(
  overrides: [
    sharedPreferencesProvider.overrideWithValue(sharedPreferences),
  ],
  child: const EasyFitApp(),
)
```

### Issue: Freezed models not generating

**Solution**: Run build runner:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Admin login screen appears blank

**Solution**: Ensure `GradientScaffold` widget exists in `core/widgets/`

### Issue: Riverpod providers throwing "not found" error

**Solution**: Verify all imports are correct and run:
```bash
flutter pub get
flutter pub run build_runner build
```

---

## Next Steps

1. ✅ Implement backend APIs
2. ✅ Test all screens and flows
3. ✅ Add error handling UI
4. ✅ Implement pagination for large lists
5. ✅ Add real-time refresh with pull-to-refresh
6. ✅ Implement admin roles and permissions
7. ✅ Add activity logging
8. ✅ Write unit and widget tests
9. ✅ Deploy to production

---

## Performance Optimization Tips

1. **Paginate Lists**: 
   ```dart
   // Load 20 items at a time
   await getUsers(page: 1, limit: 20);
   ```

2. **Cache Data**:
   ```dart
   // Use Riverpod's caching
   final usersCacheProvider = FutureProvider.autoDispose((ref) async {
     return await userService.getUsers();
   });
   ```

3. **Debounce Search**:
   ```dart
   // Wait 500ms after user stops typing
   Timer? _debounce;
   onChanged: (query) {
     _debounce?.cancel();
     _debounce = Timer(Duration(milliseconds: 500), () {
       ref.read(usersListProvider.notifier).setSearchQuery(query);
     });
   }
   ```

4. **Lazy Load Images**:
   ```dart
   // Use CachedNetworkImage for profile pictures
   CachedNetworkImage(
     imageUrl: profileImage,
     placeholder: (_,__) => CircleAvatar(child: Icon(Icons.person)),
   )
   ```

---

## Security Checklist

- [ ] Validate all user inputs
- [ ] Sanitize API responses
- [ ] Implement token refresh
- [ ] Add request signing
- [ ] Use HTTPS only
- [ ] Implement rate limiting
- [ ] Add audit logging
- [ ] Validate admin permissions
- [ ] Encrypt sensitive data
- [ ] Implement session timeout

---

## Completed! 🎉

Your Admin Module is now fully integrated and ready to use. 

**Next**: Start the app and navigate to `/admin/login` to access the admin panel!

---

**Need Help?** Check the main [README.md](./README.md) for detailed documentation.
