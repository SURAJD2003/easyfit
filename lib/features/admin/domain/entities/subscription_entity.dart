class SubscriptionHistoryItem {
  final String planId;
  final String planName;
  final String status;
  final DateTime? startDate;
  final DateTime? endDate;

  const SubscriptionHistoryItem({
    required this.planId,
    required this.planName,
    required this.status,
    this.startDate,
    this.endDate,
  });

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryItem(
      planId: json['planId']?.toString() ?? '',
      planName: json['planName']?.toString() ?? json['plan']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
    );
  }
}

class SubscriptionEntity {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String plan;       
  final String status;     
  final DateTime? requestedAt;
  final DateTime? resolvedAt;
  final DateTime? expiryDate;
  final String? note;
  final String? reason;
  final List<SubscriptionHistoryItem> history;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.plan,
    required this.status,
    this.requestedAt,
    this.resolvedAt,
    this.expiryDate,
    this.note,
    this.reason,
    this.history = const [],
  });
}