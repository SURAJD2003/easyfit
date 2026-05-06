class NotificationEntity {
  final String title;
  final String body;
  final String? segment; // all, free, premium

  const NotificationEntity({
    required this.title,
    required this.body,
    this.segment,
  });
}