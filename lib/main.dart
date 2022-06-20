import 'package:flutter/material.dart';
import 'package:get/route_manager.dart'
    show Get, GetMaterialApp, GetNavigation, Transition;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'utils/firebase.dart';
import 'firebase_options.dart';
import 'routes.dart' show routes;

void main() async {
  // Keep splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // initialize app
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  // Remove splash screen
  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      initialRoute: '/onboarding',
      getPages: routes(),
      navigatorKey: Get.key,
      navigatorObservers: [FirebaseAnalyticsObserver(analytics: analytics)],
    );
  }
}
