// 📦 Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';

class Notification {
  String title = '';
  String body = '';
  DateTime createdAt = DateTime.now();
  Notification({title, body, createdAt});

  factory Notification.fromFireMessage(RemoteMessage message) {
    return Notification(
      title: message.notification!.title!,
      body: message.notification!.body!,
      createdAt: message.sentTime!,
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      title: json['title'],
      body: json['body'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'createdAt': createdAt,
      };
}
