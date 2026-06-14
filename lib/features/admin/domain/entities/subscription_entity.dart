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
  });
}