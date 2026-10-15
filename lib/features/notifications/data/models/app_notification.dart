class AppNotification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final DateTime? createdAt;
  final String? imageUrl;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.imageUrl,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawDate = json['createdAt'] ??
        json['CreatedAt'] ??
        json['created_at'] ??
        json['timestamp'] ??
        json['date'] ??
        json['sentAt'];

    final rawImage = json['imageUrl'] ??
        json['ImageUrl'] ??
        json['image_url'] ??
        json['image'] ??
        json['Image'];

    return AppNotification(
      id: json['id']?.toString() ??
          json['Id']?.toString() ??
          json['notificationId']?.toString() ??
          json['NotificationId']?.toString() ??
          json['_id']?.toString() ??
          '',
      title: json['title']?.toString() ??
          json['Title']?.toString() ??
          'Announcement',
      body: json['body']?.toString() ??
          json['Body']?.toString() ??
          json['message']?.toString() ??
          json['Message']?.toString() ??
          json['content']?.toString() ??
          '',
      isRead: json['isRead'] == true ||
          json['IsRead'] == true ||
          json['read'] == true,
      createdAt: rawDate != null ? DateTime.tryParse(rawDate.toString()) : null,
      imageUrl: (rawImage != null && rawImage.toString().trim().isNotEmpty)
          ? rawImage.toString().trim()
          : null,
    );
  }

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    bool? isRead,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
