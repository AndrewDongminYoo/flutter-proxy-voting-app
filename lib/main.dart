import 'dart:io';
import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

// import 'utils/firebase.dart';
// import 'utils/appsflyer.dart';
import 'firebase_options.dart';
import 'routes.dart' show routes;
import 'package:bside/auth/auth.controller.dart';
import 'package:bside/vote/vote.controller.dart';

clearPref() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
}

void main() async {
  // runZonedGuarded<Future<void>>(() async {
  // Keep splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };

  // NOTE: 디버깅용
  // await clearPref();

  // initialize app
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();
  final firstTime = prefs.getBool('firstTime') ?? true;
  print('[main] firstTime: $firstTime');
  final initialLink = await setupFirebase();
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  runApp(MyApp(initialLink: initialLink, firstTime: firstTime));
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
  final bool firstTime;
  final PendingDynamicLinkData? initialLink;
  const MyApp({Key? key, this.initialLink, required this.firstTime})
      : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String initialRoute = '/';

  @override
  void initState() {
    super.initState();
    initDynamicLinks();
    // setupAppsFlyer();

    // Remove splash screen
    FlutterNativeSplash.remove();
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
    initialRoute = widget.firstTime ? '/onboarding' : initialRoute;

    // TODO: 최상단 에러 핸들러 필요, 에러 발생시 팝업 필요
    return GetMaterialApp(
      title: 'Bside',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Nanum',
      ),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      defaultTransition: Transition.cupertino,
      initialRoute: initialRoute,
      getPages: routes(),
      initialBinding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
        Get.lazyPut<VoteController>(() => VoteController());
      }),
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
