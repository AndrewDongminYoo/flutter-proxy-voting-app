import 'package:get/route_manager.dart' show GetPage;

import 'auth/auth.dart';
import 'vote/vote.dart';
import 'home/home.dart';
import 'about/check.dart';
import 'about/result.dart';
import 'auth/validate.dart';
import 'campaign/campaign.dart';
import 'signature/id_card.dart';
import 'signature/signature.dart';
import 'onboarding/onboarding.dart';

routes() => [
      GetPage(name: '/onboarding', page: () => const OnboardingPage()),
      GetPage(name: '/', page: () => const HomePage()),
      GetPage(name: '/signup', page: () => const AuthPage()),
      GetPage(name: '/validate', page: () => const ValidatePage()),
      GetPage(name: '/campaign', page: () => const CampaignPage()),
      GetPage(name: '/vote', page: () => const VotePage()),
      GetPage(name: '/signature', page: () => const SignaturePage()),
      GetPage(name: '/idcard', page: () => const UploadIdCardPage()),
      GetPage(name: '/result', page: () => const ResultPage()),
      GetPage(name: '/checkvoteNum', page: () => const CheckVoteNumPage()),
    ];
