import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController{
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initMessaging() {
    var androiInit = const AndroidInitializationSettings('images/logo.png');
    var iosInit = const IOSInitializationSettings();
    var initSetting = InitializationSettings(android: androiInit, iOS: iosInit);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    flutterLocalNotificationsPlugin.initialize(initSetting);
    var androidDetails = const AndroidNotificationDetails('1', 'Default',
        channelDescription: 'Channel Description',
        importance: Importance.high,
        priority: Priority.high);
    var iosDetails = const IOSNotificationDetails();
    var generalNotificationDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      // var android = message.notification.hashCode;
      if (notification != null) {
        flutterLocalNotificationsPlugin.show(notification.hashCode,
            notification.title, notification.body, generalNotificationDetails);
      }
    });
  }

  void initState() {
    initMessaging();
  }
}