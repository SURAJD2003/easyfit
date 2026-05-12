class SubscriptionRequestStatusModel {
  final String status;
  final String plan;
  final String? expiresAt;

  SubscriptionRequestStatusModel({
    required this.status,
    required this.plan,
    this.expiresAt,
  });

  factory SubscriptionRequestStatusModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionRequestStatusModel(
      status: json['status'] ?? 'unknown',
      plan: json['plan'] ?? '',
      expiresAt: json['expiresAt'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isActive => status == 'active';
}
