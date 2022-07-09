import 'dart:io';

import 'package:bside/notificaition/notificaition_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationController extends GetxController {
  late Notificaition notificaitions;
  late AndroidNotificationChannel channel;

  List<Notificaition> pushAlram = [];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // void initMessaging() {
  //   var androiInit = const AndroidInitializationSettings('images/logo.png');
  //   var iosInit = const IOSInitializationSettings();
  //   var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);
  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   flutterLocalNotificationsPlugin.initialize(initSetting);
  //   var androidDetails = const AndroidNotificationDetails('1', 'Default',
  //       channelDescription: 'Channel Description',
  //       importance: Importance.high,
  //       priority: Priority.high);
  //   var iosDetails = const IOSNotificationDetails();
  //   var generalNotificationDetails =
  //       NotificationDetails(android: androidDetails, iOS: iosDetails);
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     RemoteNotification? notification = message.notification;
  //     // var android = message.notification.hashCode;
  //     if (notification != null) {
  //       flutterLocalNotificationsPlugin.show(notification.hashCode,
  //           notification.title, notification.body, generalNotificationDetails);
  //     }
  //   });
  // }

  void listenFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (Platform.isAndroid) {
        AndroidNotification? android = message.notification?.android;
        if (notification != null && android != null && !kIsWeb) {
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
          pushAlram.add(Notificaition.fromFireMessage(message));
        }
      } else {
        IOSNotificationDetails;
      }
      update();
    });
  }

  currentTime(time) {
    return DateFormat('MM월 dd일', 'ko_KR').format(time);
  }

  void loadFCM() async {
    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        enableVibration: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
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
}
