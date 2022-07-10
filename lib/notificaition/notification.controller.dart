// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io' show Platform;

// 📦 Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'notification.data.dart';

class NotificationController extends GetxController {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  List<Notificaition> notifications = [];
  List<String> encodedPushAlrams = [];

  void listenFCM() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      if(Platform.isAndroid){
        await androidNotification(message, notification);
      }
      Notificaition data = Notificaition.fromFireMessage(message);
      encodedPushAlrams.add(json.encode(data.toJson(), toEncodable: encodeDateTime));
      setNotificationsLocal(encodedPushAlrams);
      update();
    });
  }

  Future<void> androidNotification(RemoteMessage message, RemoteNotification? notification) async {
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

  void setNotificationsLocal(messages) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notification', messages);
  }

  void getNotificationsLocal() async {
    notifications.clear();
    final prefs = await SharedPreferences.getInstance();
    List<String> result = prefs.getStringList('notification') ?? [''];
    // ignore: avoid_function_literals_in_foreach_calls
    result.forEach((message) {
      if (!notifications
          .contains(Notificaition.fromJson(decodeJson(message)))) {
        notifications.add(Notificaition.fromJson(decodeJson(message)));
      }
    });
  }

  void removeNotification(int index) async {
    final prefs = await SharedPreferences.getInstance();
    encodedPushAlrams = prefs.getStringList('notification') ?? [''];
    encodedPushAlrams.removeAt(index);
    setNotificationsLocal(encodedPushAlrams);
    getNotificationsLocal();
  }

  dynamic encodeDateTime(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }

  Map<String, dynamic> decodeJson(String message) {
    return json.decode(message, reviver: (key, value) => reviverDateTime(key, value));
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

  // 기기의 토큰을 얻고 싶은 경우 main init에 getToken 주석해제
  // void getToken() async {
  //   await messaging.getToken().then((value) => {
  //         print('--------------------------------'),
  //         print(value),
  //         print('--------------------------------')
  //       });
  // }
}
