class SubscriptionEntity {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String plan;       // free / premium
  final String status;     // pending / approved / rejected
  final DateTime? requestedAt;
  final DateTime? approvedAt;

  const SubscriptionEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.plan,
    required this.status,
    this.requestedAt,
    this.approvedAt,
  });
}