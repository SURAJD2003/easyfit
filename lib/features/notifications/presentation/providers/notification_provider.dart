import 'package:flutter/foundation.dart';

import '../../data/models/app_notification.dart';
import '../../data/services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider({NotificationService? service})
    : _service = service ?? NotificationService();

  final NotificationService _service;

  bool _isLoading = false;
  String? _errorMessage;
  List<AppNotification> _notifications = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.getNotifications();
    if (result.isSuccess) {
      _notifications = result.data ?? [];
    } else {
      _errorMessage = result.error?.message ?? 'Failed to fetch notifications';
    }

    _isLoading = false;
    notifyListeners();
  }
}
