class SubscriptionInfo {
  final String plan;
  final String status;
  final DateTime? expiryDate;

  const SubscriptionInfo({
    required this.plan,
    required this.status,
    this.expiryDate,
  });
}

class AdminUserEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final bool isActive;
  final String? subscriptionPlan;
  final String? profileImage;
  final DateTime? createdAt;
  final SubscriptionInfo? subscription;

  const AdminUserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
    this.subscriptionPlan,
    this.profileImage,
    this.createdAt,
    this.subscription,
  });
}