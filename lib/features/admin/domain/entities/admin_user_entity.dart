class SubscriptionInfo {
  final String plan;
  final String status;
  final DateTime? expiryDate;
  final DateTime? lastRenewalDate;

  const SubscriptionInfo({
    required this.plan,
    required this.status,
    this.expiryDate,
    this.lastRenewalDate,
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
  final String status;

  const AdminUserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.isActive,
    required this.status,
    this.subscriptionPlan,
    this.profileImage,
    this.createdAt,
    this.subscription,
  });
}