// 🎯 Dart imports:
import 'dart:async' show runZonedGuarded;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// 🌎 Project imports:
import 'lib.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  FlutterError.onError = crashlytics.recordFlutterFatalError;

  // initialize app
  await dotenv.load(fileName: '.env');
  final initialLink = await setupFirebase();
  bool firstTime = await CustomStorage.needOnBoarding();
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  runZonedGuarded(() {
    runApp(MyApp(initialLink: initialLink, firstTime: firstTime));
  }, (Object error, StackTrace trace) {
    var detail = FlutterErrorDetails(stack: trace, exception: error);
    crashlytics.recordFlutterFatalError(detail);
  });
}

class MyApp extends StatefulWidget {
  final bool firstTime;
  final dynamic initialLink;

  const MyApp({
    Key? key,
    this.initialLink,
    required this.firstTime,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _initialRoute = '/mts';
  final NotiController _notificationCtrl = NotiController.get();

  @override
  initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _initNotification();
    _initDynamicLinks();
    compareAppVersion();
    Battery.getBattery();
  }

  _initNotification() {
    _notificationCtrl.listenFCM();
    _notificationCtrl.requestPermission();
    _notificationCtrl.getToken();
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
      initialRoute: _initialRoute,
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
      Get.put<AuthController>(AuthController());
      Get.put<VoteController>(VoteController());
    });
  }
}
