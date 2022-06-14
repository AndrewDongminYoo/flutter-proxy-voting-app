import 'package:get/route_manager.dart';

import 'home/home.dart';
import 'onboarding/onboarding.dart';

routes() => [
  GetPage(name: '/onboarding', page: ()=> const OnboardingPage()),
  GetPage(name: '/', page: ()=> const HomePage())
];