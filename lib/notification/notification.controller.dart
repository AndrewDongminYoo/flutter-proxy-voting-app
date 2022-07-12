// 🎯 Dart imports:
import 'dart:convert' show json;
import 'dart:io' show Platform;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import '../utils/shared_prefs.dart';
import 'notification.data.dart';

class NotificationController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  List<Notificaition> notifications = [];
  List<String> encodedPushAlrams = [];
  late String token;

  void listenFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if (Platform.isAndroid) {
        await androidLocalNotification(message, notification);
      }
      Notificaition data = Notificaition.fromFireMessage(message);
      encodedPushAlrams
          .add(json.encode(data.toJson(), toEncodable: encodeDateTime));
      setNotifications(encodedPushAlrams);
      update();
    });
  }

  Future<void> androidLocalNotification(
      RemoteMessage message, RemoteNotification? notification) async {
    AndroidNotificationChannel channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
      enableVibration: true,
    );

    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null && !kIsWeb) {
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            icon: 'launch_background',
          ),
        ),
      );
    }
  }

  void getNotificationsLocal() async {
    notifications.clear();
    List<String> result = await getNotifications();
    // ignore: avoid_function_literals_in_foreach_calls
    result.forEach((message) {
      if (!notifications
          .contains(Notificaition.fromJson(decodeJson(message)))) {
        notifications.add(Notificaition.fromJson(decodeJson(message)));
      }
    });
  }

  void removeNotification(int index) async {
    List<String> encodedPushAlrams = await getNotifications();
    encodedPushAlrams.removeAt(index);
    setNotifications(encodedPushAlrams);
  }

  dynamic encodeDateTime(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  Map<String, dynamic> decodeJson(String message) {
    return json.decode(message,
        reviver: (key, value) => reviverDateTime(key, value));
  }

  reviverDateTime(key, value) {
    if (key == 'createdAt') {
      return DateTime.parse(value as String);
    }
    return value;
  }

  String currentTime(time) {
    return DateFormat('MM월 dd일', 'ko_KR').format(time);
  }

  void requestPermission() async {
    await messaging.setAutoInitEnabled(true);
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> getToken() async {
    await messaging.getToken().then((value) => {
      token = value!
    });
  }
  
}
