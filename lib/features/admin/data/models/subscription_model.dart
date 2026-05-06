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
    super.approvedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['userName']?.toString() ??
          json['name']?.toString() ??
          'Unknown User',
      userEmail: json['userEmail']?.toString() ??
          json['email']?.toString() ??
          '',
      plan: json['plan']?.toString() ?? 'free',
      status: json['status']?.toString() ?? 'pending',
      requestedAt: json['requestedAt'] != null
          ? DateTime.tryParse(json['requestedAt'].toString())
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null,
    );
  }
}