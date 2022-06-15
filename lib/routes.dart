import 'package:get/route_manager.dart' show GetPage;

import 'package:bside/home/home.dart' show HomePage;
import 'package:bside/onboarding/onboarding.dart' show OnboardingPage;

routes() => [
      GetPage(name: '/onboarding', page: () => const OnboardingPage()),
      GetPage(name: '/', page: () => const HomePage())
    ];
