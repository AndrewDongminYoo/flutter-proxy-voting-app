// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// 🌎 Project imports:
import 'auth/auth.controller.dart';
import 'notificaition/notificaitionpage_controller.dart';
import 'utils/firebase_options.dart';
import 'routes.dart' show routes;
import 'vote/vote.controller.dart';
// import 'utils/firebase.dart';
// import 'utils/appsflyer.dart';

clearPref() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('Handling a background message: ${message.messageId}');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runZonedGuarded<Future<void>>(
    () async {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
      debugPrint('[main] firstTime: $firstTime');
      final initialLink = await setupFirebase();
      timeago.setLocaleMessages('ko', timeago.KoMessages());
      runApp(MyApp(initialLink: initialLink, firstTime: firstTime));
    },
    (error, stack) => {
      debugPrint(error.toString()),
      debugPrintStack(stackTrace: stack),
      // FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
    },
  );
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
//   debugPrint("Handling a background message: ${message.messageId}");
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
  String initialRoute = '/checkvotenum';
  NotificationController notificaitionCtrl =
      Get.isRegistered<NotificationController>()
          ? Get.find()
          : Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    notificaitionCtrl.initMessaging();
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
  //     debugPrint("onAppOpenAttribution res: $res");
  //   });
  //   appsflyerSdk.onInstallConversionData((res) {
  //     debugPrint("onInstallConversionData res: $res");
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
    // initialRoute = widget.firstTime ? '/result' : initialRoute;
    initialRoute = widget.firstTime ? '/onboarding' : initialRoute;
    // TODO: 최상단 에러 핸들러 필요, 에러 발생시 팝업 필요
    return GetMaterialApp(
      title: 'Bside',
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          fontFamily: 'Nanum',
          useMaterial3: true),
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
