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
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'Unknown User',
      userEmail: json['userEmail']?.toString() ?? '',
      plan: json['plan']?.toString() ?? 'free',
      status: json['status']?.toString() ?? 'pending',
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString())
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'].toString())
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'].toString())
          : null,
      note: json['note']?.toString(),
      reason: json['reason']?.toString(),
    );
  }
}