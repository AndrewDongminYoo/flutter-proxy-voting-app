// 📦 Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';

class Notificaition {
    String title = '';
    String body = '';
    DateTime createdAt = DateTime.now();

  Notificaition.fromFireMessage(RemoteMessage message) {
    title = message.notification!.title!;
    body = message.notification!.body!;
    createdAt = message.sentTime!;
  }

  Notificaition.fromJson(Map<String, dynamic> json){
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
