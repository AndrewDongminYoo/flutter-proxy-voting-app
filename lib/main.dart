import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart'
    show Get, GetMaterialApp, GetNavigation, Transition;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'utils/firebase.dart';
import 'firebase_options.dart';
import 'routes.dart' show routes;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  runZonedGuarded<Future<void>>(() async {
    // Keep splash screen
    WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

    // initialize app
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    // Remove splash screen
    FlutterNativeSplash.remove();
    runApp(MyApp(initialLink: initialLink));
  },
      (error, stack) =>
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.initialLink}) : super(key: key);
  final PendingDynamicLinkData? initialLink;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String initialRoute = '/onboarding';

  @override
  void initState() {
    super.initState();
    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink!.link;
      initialRoute = deepLink.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bside',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Nanum',
      ),
      locale: Get.deviceLocale,
      defaultTransition: Transition.cupertino,
      initialRoute: initialRoute,
      getPages: routes(),
      navigatorKey: Get.key,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }
}
