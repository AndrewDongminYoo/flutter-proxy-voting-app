// 🎯 Dart imports:
import 'dart:async' show runZonedGuarded;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/route_manager.dart' show Get, GetMaterialApp, Transition;
import 'package:get/instance_manager.dart' show BindingsBuilder, Get;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' show dotenv;
import 'package:intl/date_symbol_data_local.dart' show initializeDateFormatting;
import 'package:timeago/timeago.dart' as timeago;

// 🌎 Project imports:
import 'lib.dart';

dynamic main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // initialize app
  await dotenv.load(fileName: '.env');
  PendingDynamicLinkData? initialLink = await setupFirebase();
  FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  FlutterError.onError = crashlytics.recordFlutterFatalError;
  bool firstTime = await Storage.needOnBoarding();
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  runZonedGuarded(() {
    runApp(MyApp(initialLink: initialLink, firstTime: firstTime));
  }, (Object error, StackTrace trace) {
    FlutterErrorDetails detail =
        FlutterErrorDetails(stack: trace, exception: error);
    crashlytics.recordFlutterFatalError(detail);
  });
}

class MyApp extends StatefulWidget {
  final bool firstTime;
  final PendingDynamicLinkData? initialLink;

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
  void initState() {
    super.initState();
    initializeDateFormatting('ko_KR', null);
    _initNotification();
    _initDynamicLinks();
    compareAppVersion();
    print('available pages are $pages');
    print('available addresses are $names');
  }

  void _initNotification() {
    _notificationCtrl.listenFCM();
    _notificationCtrl.requestPermission();
    _notificationCtrl.getToken();
  }

  void _initDynamicLinks() {
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
      getPages: getPages,
      initialBinding: _initialBinding(),
      debugShowCheckedModeBanner: false,
      navigatorKey: Get.key,
    );
  }

  Widget _errorWidgetBuilder(dynamic context, Widget? child) {
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
