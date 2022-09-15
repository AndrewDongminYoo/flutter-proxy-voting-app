// 📦 Package imports:
import 'package:firebase_messaging/firebase_messaging.dart' show RemoteMessage;

class Notification {
  String title = '';
  String body = '';
  DateTime createdAt = DateTime.now();
  Notification({
    required this.title,
    required this.body,
    required this.createdAt,
  });

  Notification.fromFireMessage(RemoteMessage message) {
    title = message.notification!.title!;
    body = message.notification!.body!;
    createdAt = message.sentTime!;
  }

  Notification.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    body = json['body'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'createdAt': createdAt,
      };
}
