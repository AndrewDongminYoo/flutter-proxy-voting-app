import 'package:flutter/material.dart';
import 'package:get/route_manager.dart'
    show Get, GetMaterialApp, GetNavigation, Transition;
import 'routes.dart' show routes;

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
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Nanum',
      ),
      locale: Get.deviceLocale,
      defaultTransition: Transition.cupertino,
      initialRoute: '/onboarding',
      getPages: routes(),
    );
  }
}
