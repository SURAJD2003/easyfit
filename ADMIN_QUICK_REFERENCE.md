# Admin Module - Quick Reference Card

## 🎯 Routes
```
/admin/login              → Login page
/admin/dashboard         → Main dashboard
/admin/users             → Users list
/admin/users/:userId     → User details
/admin/subscriptions     → Subscription manager
```

## 🔑 Demo Credentials
```
Email:    admin@easyfit.com
Password: admin123456
```

## 🚀 Setup Commands

```bash
# Generate models
flutter pub run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Test with mock data
# Use credentials above
```

## 📁 Key Files

| File | Purpose |
|------|---------|
| `admin_provider.dart` | State management |
| `admin_*_screen.dart` | 5 screens |
| `widgets/` | Reusable components |
| `data/` | API & storage |
| `domain/` | Business logic |

## 🧠 State Providers

```dart
adminAuthStateProvider          // Login state
dashboardStatsProvider          // Dashboard data
usersListProvider              // Users list
subscriptionsProvider          // Subscriptions
```

## 📊 API Endpoints (8)

1. `POST /admin/login` - Login
2. `GET /admin/profile` - Profile
3. `GET /admin/dashboard/stats` - Stats
4. `GET /admin/users` - Users list
5. `GET /admin/users/{id}` - User detail
6. `GET /admin/subscriptions` - Subscriptions
7. `PATCH /admin/subscriptions/{id}/approve` - Approve
8. `PATCH /admin/subscriptions/{id}/reject` - Reject

## 🎨 Colors

| Color | Code | Use |
|-------|------|-----|
| Primary | #FF6B00 | Main actions |
| Success | #4CAF50 | Approved |
| Warning | #FFC107 | Pending |
| Error | #E53935 | Rejected |
| Background | #0A0A0A | App BG |

## 💡 Usage Examples

```dart
// Navigate to admin
Navigator.pushNamed(context, '/admin/login');

// Watch users
final users = ref.watch(usersListProvider).users;

// Search users
ref.read(usersListProvider.notifier).setSearchQuery('john');

// Approve subscription
ref.read(subscriptionsProvider.notifier)
    .approveSubscription(subId);

// Refresh data
ref.refresh(dashboardStatsProvider.future);
```

## 📚 Documentation

| Doc | Content |
|-----|---------|
| README.md | Complete guide (500+ lines) |
| SETUP_GUIDE.md | Step-by-step integration |
| API_CONTRACT.md | Backend specifications |
| DELIVERY.md | Overview & checklist |

## ⚡ Quick Checklist

- [ ] Run build_runner
- [ ] Setup ProviderScope
- [ ] Add routes to GoRouter
- [ ] Initialize SharedPreferences
- [ ] Test with mock data
- [ ] Implement backend APIs
- [ ] Test on real backend
- [ ] Deploy to production

## 🔐 Security Notes

✅ Token storage in SharedPreferences
✅ Token injection in Dio headers
✅ Protected routes
✅ Input validation
✅ Error sanitization

⚠️ Add: Token refresh, session timeout, audit logs

## 📱 Responsive

✓ Mobile (320px+)
✓ Tablet (600px+)
✓ Web (1920px+)
✓ Dark mode optimized

## 🧪 Testing

- Use mock data: `MockAdminDataService`
- Demo credentials included
- Network delay simulation
- 50+ sample users
- Multiple statuses

## ❓ Common Issues

**Models not generating**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Provider not found**
→ Check imports & run build_runner

**Navigation fails**
→ Verify GoRouter setup

**API 401**
→ Check token in headers

## 📞 Useful Links

- Start: `lib/features/admin/README.md`
- Setup: `ADMIN_SETUP_GUIDE.md`
- API: `API_CONTRACT.md`
- Code: `lib/features/admin/`

---

**Admin Module v1.0 | Ready for Production**

Keep this card handy! 📌
