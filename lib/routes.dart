import 'signature/signature.dart';
import 'vote/vote.dart';

import 'home/home.dart' show HomePage;
import 'package:get/route_manager.dart' show GetPage;
import 'onboarding/onboarding.dart' show OnboardingPage;
import 'campaign/campaign.dart' show CampaignPage;

routes() => [
      GetPage(name: '/onboarding', page: () => const OnboardingPage()),
      GetPage(name: '/', page: () => const HomePage()),
      GetPage(name: '/campaign', page: () => const CampaignPage()),
      GetPage(name: '/vote', page: () => const VotePage()),
      GetPage(name: '/signature', page: () => const SignaturePage())
    ];
