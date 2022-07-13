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
import 'lib.dart';

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
  String _initialRoute = '/';
  final NotificationController _notificaitionCtrl =
      NotificationController.get();

  @override
  initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _initNotification();
    _initDynamicLinks();
    compareAppVersion();
  }

  _initNotification() {
    _notificaitionCtrl.listenFCM();
    _notificaitionCtrl.requestPermission();
    _notificaitionCtrl.getToken();
  }

  _initDynamicLinks() {
    if (widget.initialLink != null) {
      final Uri deepLink = widget.initialLink!.link;
      _initialRoute = deepLink.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: _errorWidgetBuilder,
      title: 'Bside',
      theme: _theme(),
      locale: Get.deviceLocale,
      fallbackLocale: const Locale('en', 'US'),
      defaultTransition: Transition.cupertino,
      initialRoute: widget.firstTime ? '/onboarding' : _initialRoute,
      getPages: routes(),
      initialBinding: _initialBinding(),
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
    );
  }

  Widget _errorWidgetBuilder(context, child) {
    Widget error = const Text('...rendering error...');
    if (child is Scaffold || child is Navigator) {
      error = Scaffold(body: Center(child: error));
    }
    ErrorWidget.builder = ((details) => error);
    if (child != null) return child;
    throw ('widget is null. something is wrong.');
  }

  ThemeData _theme() {
    return ThemeData(
      primarySwatch: Colors.deepPurple,
      fontFamily: 'Nanum',
      useMaterial3: true,
    );
  }

  BindingsBuilder<dynamic> _initialBinding() {
    return BindingsBuilder(() {
      Get.lazyPut<AuthController>(() => AuthController());
      Get.lazyPut<VoteController>(() => VoteController());
    });
  }
}
