// 📦 Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';

class Notificaition {
  final String title;
  final String body;
  final DateTime createdAt;

  Notificaition({
    required this.title,
    required this.body,
    required this.createdAt,
  });

  factory Notificaition.fromFireMessage(RemoteMessage message) {
    return Notificaition(
      title: message.notification!.title!,
      body: message.notification!.body!,
      createdAt: message.sentTime!,
    );
  }
}
