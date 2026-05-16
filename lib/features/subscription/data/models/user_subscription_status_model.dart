class UserSubscriptionStatusModel {
  final String plan;
  final String status;
  final String expiryDate;
  final bool autoRenew;

  UserSubscriptionStatusModel({
    required this.plan,
    required this.status,
    required this.expiryDate,
    required this.autoRenew,
  });

  factory UserSubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    return UserSubscriptionStatusModel(
      plan: json['plan'] ?? 'Free',
      status: json['status'] ?? 'inactive',
      expiryDate: json['expiryDate'] ?? '',
      autoRenew: json['autoRenew'] ?? false,
    );
  }

  bool get isActive => status == 'active';
  bool get isPremium => isActive && plan != 'Free';
}
