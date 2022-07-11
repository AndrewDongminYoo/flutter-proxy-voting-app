// 🎯 Dart imports:
import 'dart:async' show Future, runZonedGuarded;
import 'dart:io' show exit;

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
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

// 🌎 Project imports:
import 'auth/auth.controller.dart';

import 'notification/notification.dart';
import 'routes.dart' show routes;
import 'utils/firebase_options.dart';
import 'vote/vote.controller.dart';

clearPref() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep splash screen
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };

  // await clearPref(); // NOTE: 디버깅용

  // initialize app
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();
  final firstTime = prefs.getBool('firstTime') ?? true;
  debugPrint('[main] firstTime: $firstTime');
  final initialLink = await setupFirebase();
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  runZonedGuarded(() {
    runApp(MyApp(initialLink: initialLink, firstTime: firstTime));
  }, (Object e, StackTrace s) {});
}

Future<PendingDynamicLinkData?> setupFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();
  return initialLink;
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Handling a background message: ${message.messageId}');
}

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
  NotificationController notificaitionCtrl =
      Get.isRegistered<NotificationController>()
          ? Get.find()
          : Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    // notificaitionCtrl.loadFCM();
    notificaitionCtrl.listenFCM();
    notificaitionCtrl.requestPermission();
    // notificaitionCtrl.getToken();
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
        useMaterial3: true,
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
    );
  }
}
