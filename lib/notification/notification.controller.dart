// 🎯 Dart imports:
import 'dart:convert' show json;
import 'dart:io' show Platform;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import '../utils/shared_prefs.dart';
import 'notification.model.dart';

class NotiController extends GetxController {
  static NotiController get() => Get.isRegistered<NotiController>()
      ? Get.find<NotiController>()
      : Get.put(NotiController());

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  List<Notification> notifications = [];
  List<String> encodedPushAlrams = [];
  String? _token;

  String get token {
    if (_token != null) {
      return _token!;
    } else {
      getToken();
    }
    return _token ?? '';
  }

  set token(String token) {
    _token = token;
  }

  void listenFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if (Platform.isAndroid) {
        await _androidLocalNotification(message, notification);
      }
      Notification data = Notification.fromFireMessage(message);
      encodedPushAlrams
          .add(json.encode(data.toJson(), toEncodable: _encodeDateTime));
      Storage.setNotifications(encodedPushAlrams);
      update();
    });
  }

  Future<void> _androidLocalNotification(
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
    List<String> result = await Storage.getNotifications();
    for (String message in result) {
      if (message.length > 1 &&
          !notifications.contains(Notification.fromJson(decodeJson(message)))) {
        notifications.add(Notification.fromJson(decodeJson(message)));
      }
    }
  }

  Future<void> removeNotification(int index) async {
    encodedPushAlrams.removeAt(index);
    Storage.setNotifications(encodedPushAlrams);
  }

  String _encodeDateTime(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  Map<String, dynamic> decodeJson(String message) {
    return json.decode(message,
        reviver: (key, value) => reviverDateTime(key, value));
  }

  dynamic reviverDateTime(key, value) {
    if (key == 'createdAt') {
      return DateTime.parse(value as String);
    }
    return value;
  }

  String currentTime(time) {
    return DateFormat('MM월 dd일', 'ko_KR').format(time);
  }

  Future<void> requestPermission() async {
    await _messaging.setAutoInitEnabled(true);
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> getToken() async {
    await _messaging.getToken().then((value) => {token = value!});
    print('==========NotiController.getToken()===========');
    print('token: ${token.substring(0, 36)}...');
    print('==========NotiController.getToken()===========');
  }
}
