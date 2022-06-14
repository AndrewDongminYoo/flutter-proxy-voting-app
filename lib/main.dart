import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Bside',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      locale: Get.deviceLocale,
      defaultTransition: Transition.rightToLeft,
      initialRoute: '/onboarding',
      getPages: routes(),
    );
  }
}
