// 🎯 Dart imports:
import 'dart:async' show Future, runZonedGuarded;
import 'dart:io' show exit;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

// 🌎 Project imports:
import '../services.dart';
import 'routes.dart' show routes;
import 'auth/auth.controller.dart';
import 'notification/notification.dart';
import 'utils/firebase_options.dart';
import 'vote/vote.controller.dart';

clearPref() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.clear();
}

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MainService service = MainService();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) exit(1);
  };

  // await clearPref(); // NOTE: 디버깅용

  // initialize app
  await dotenv.load(fileName: '.env');
  final prefs = await SharedPreferences.getInstance();
  final firstTime = prefs.getBool('firstTime') ?? true;
  final initialLink = await setupFirebase();
  debugPrint('[main] firstTime: $firstTime');
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  runZonedGuarded(() {
    service.logAppVersion();
    runApp(MyApp(initialLink: initialLink, firstTime: firstTime));
  }, (Object error, StackTrace trace) {
    service.reportUncaughtError(error, trace);
  });
}

setupFirebase() async {
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
  initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    initNotification();
    initDynamicLinks();
  }

  initNotification() {
    // notificaitionCtrl.loadFCM();
    notificaitionCtrl.listenFCM();
    notificaitionCtrl.requestPermission();
    // notificaitionCtrl.getToken();
  }

  initDynamicLinks() {
    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink!.link;
      initialRoute = deepLink.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    initialRoute = widget.firstTime ? '/onboarding' : initialRoute;
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
