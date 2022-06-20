import 'package:get/route_manager.dart' show GetPage;

import 'auth/auth.dart';
import 'vote/vote.dart';
import 'home/home.dart';
import 'id_card/id_card.dart';
import 'campaign/campaign.dart';
import 'signature/signature.dart';
import 'onboarding/onboarding.dart';

routes() => [
      GetPage(name: '/onboarding', page: () => const OnboardingPage()),
      GetPage(name: '/', page: () => const HomePage()),
      GetPage(name: '/signup', page: () => const AuthPage()),
      GetPage(name: '/campaign', page: () => const CampaignPage()),
      GetPage(name: '/vote', page: () => const VotePage()),
      GetPage(name: '/signature', page: () => const SignaturePage()),
      GetPage(name: '/idcard', page: () => const UploadIdCardPage())
    ];
