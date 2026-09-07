import '../../domain/entities/subscription_entity.dart';

class SubscriptionModel extends SubscriptionEntity {
  const SubscriptionModel({
    required super.id,
    required super.userId,
    required super.userName,
    required super.userEmail,
    required super.plan,
    required super.status,
    super.requestedAt,
    super.resolvedAt,
    super.expiryDate,
    super.note,
    super.reason,
    super.history = const [],
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    final rawExpiry = json['expiryDate'] ??
        json['dueDate'] ??
        json['expiresAt'] ??
        json['due_date'] ??
        json['expiry_date'] ??
        json['nextBillingDate'] ??
        json['validUntil'];

    final rawRequested = json['requestedAt'] ??
        json['createdAt'] ??
        json['created_at'] ??
        json['startDate'] ??
        json['start_date'];

    final rawResolved = json['resolvedAt'] ??
        json['updatedAt'] ??
        json['updated_at'] ??
        json['approvedAt'];

    final rawHistory = json['history'];
    final List<SubscriptionHistoryItem> historyList = [];
    if (rawHistory is List) {
      for (final h in rawHistory) {
        if (h is Map<String, dynamic>) {
          historyList.add(SubscriptionHistoryItem.fromJson(h));
        }
      }
    }

    return SubscriptionModel(
      id: json['id']?.toString() ??
          json['_id']?.toString() ??
          json['subscriptionId']?.toString() ??
          json['userId']?.toString() ??
          '',
      userId: json['userId']?.toString() ?? json['_id']?.toString() ?? '',
      userName: json['userName']?.toString() ??
          json['name']?.toString() ??
          json['user_name']?.toString() ??
          json['fullName']?.toString() ??
          'Unknown User',
      userEmail: json['userEmail']?.toString() ??
          json['email']?.toString() ??
          json['user_email']?.toString() ??
          json['userPhone']?.toString() ??
          json['phone']?.toString() ??
          json['mobile']?.toString() ??
          '',
      plan: json['plan']?.toString() ??
          json['planId']?.toString() ??
          json['planName']?.toString() ??
          'free',
      status: json['status']?.toString() ?? 'pending',
      requestedAt: rawRequested != null
          ? DateTime.tryParse(rawRequested.toString())
          : null,
      resolvedAt: rawResolved != null
          ? DateTime.tryParse(rawResolved.toString())
          : null,
      expiryDate:
          rawExpiry != null ? DateTime.tryParse(rawExpiry.toString()) : null,
      note: json['note']?.toString(),
      reason: json['reason']?.toString(),
      history: historyList,
    );
  }
}