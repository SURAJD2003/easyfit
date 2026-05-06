import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.title,
    required super.body,
    super.segment,
  });

  Map<String, dynamic> toBroadcastJson() {
    return {
      'title': title,
      'body': body,
    };
  }

  Map<String, dynamic> toSegmentJson() {
    return {
      'title': title,
      'body': body,
      'segment': segment,
    };
  }
}