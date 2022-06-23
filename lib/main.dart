import 'dart:async';

// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

// import 'utils/firebase.dart';
// import 'utils/appsflyer.dart';
import 'firebase_options.dart';
import 'routes.dart' show routes;

void main() async {
  // runZonedGuarded<Future<void>>(() async {
  // Keep splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // initialize app
  await dotenv.load(fileName: '.env');
  final initialLink = await setupFirebase();

  // Remove splash screen
  FlutterNativeSplash.remove();
  runApp(MyApp(initialLink: initialLink));
  // },
  //     (error, stack) =>
  //         FirebaseCrashlytics.instance.recordError(error, stack, fatal: true));
}

Future<PendingDynamicLinkData?> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  return initialLink;
}

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print("Handling a background message: ${message.messageId}");
// }

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.initialLink}) : super(key: key);
  final PendingDynamicLinkData? initialLink;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String initialRoute = '/checkvoteNum';
  // ignore: unused_field
  Map? _gcd;

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    // setupAppsFlyer();
  }

  initDynamicLinks() {
    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink!.link;
      initialRoute = deepLink.path;
    }
  }

  // setupAppsFlyer() {
  //   appsflyerSdk.onAppOpenAttribution((res) {
  //     print("onAppOpenAttribution res: $res");
  //   });
  //   appsflyerSdk.onInstallConversionData((res) {
  //     print("onInstallConversionData res: $res");
  //     setState(() {
  //       _gcd = res;
  //     });
  //   });
  //   appsflyerSdk.initSdk(
  //       registerConversionDataCallback: true,
  //       registerOnAppOpenAttributionCallback: true,
  //       registerOnDeepLinkingCallback: false);
  // }

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
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
      // navigatorObservers: [
      //   FirebaseAnalyticsObserver(
      //     analytics: analytics,
      //   ),
      // ],
    );
  }
}
