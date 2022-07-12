// 🎯 Dart imports:
import 'dart:async' show runZonedGuarded;
import 'dart:io' show exit;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timeago/timeago.dart' as timeago;

// 🌎 Project imports:
import 'services.dart';
import 'routes.dart' show routes;
import 'auth/auth.controller.dart';
import 'notification/notification.dart';
import 'utils/utils.dart';
import 'vote/vote.controller.dart';
import 'utils/validate_app_version.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MainService service = MainService();

  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.stack != null) {
      service.reportUncaughtError(details.exception, details.stack!);
    }
    FlutterError.presentError(details);
    // 배포된 앱은 종료 코드 1(비정상적 종료)로 종료
    if (kReleaseMode) exit(1);
  };

  // await clearPref(); // NOTE: 디버깅용

  // initialize app
  await dotenv.load(fileName: '.env');
  final initialLink = await setupFirebase();
  bool firstTime = await getIfFirstTime();
  debugPrint('[main] firstTime: $firstTime');
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  runZonedGuarded(() {
    service.logAppVersion();
    runApp(MyApp(initialLink: initialLink, firstTime: firstTime));
  }, (Object error, StackTrace trace) {
    service.reportUncaughtError(error, trace);
  });
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
    compareAppVersion();
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
    return GetMaterialApp(
      builder: errorWidgetBuilder,
      title: 'Bside',
      theme: theme(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      defaultTransition: Transition.cupertino,
      initialRoute: widget.firstTime ? '/onboarding' : initialRoute,
      getPages: routes(),
      initialBinding: initialBinding(),
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
    );
  }

  Widget errorWidgetBuilder(context, child) {
    Widget error = const Text('...rendering error...');
    if (child is Scaffold || child is Navigator) {
      error = Scaffold(body: Center(child: error));
    }
    ErrorWidget.builder = ((details) => error);
    if (child != null) return child;
    throw ('widget is null. something is wrong.');
  }

  ThemeData theme() {
    return ThemeData(
      primarySwatch: Colors.deepPurple,
      fontFamily: 'Nanum',
      useMaterial3: true,
    );
  }

  BindingsBuilder<dynamic> initialBinding() {
    return BindingsBuilder(() {
      Get.lazyPut<AuthController>(() => AuthController());
      Get.lazyPut<VoteController>(() => VoteController());
    });
  }
}
