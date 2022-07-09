// 📦 Package imports:
import 'package:get/route_manager.dart' show GetPage;

// 🌎 Project imports:
import 'about/result_page.dart';
import 'about/votes_num.dart';
import 'auth/auth.view.dart';
import 'auth/validate.view.dart';
import 'campaign/campaign.dart';
import 'exception/address_duplicate.dart';
import 'exception/not_shareholder.dart';
import 'home/home.dart';
import 'notificaition/notificaition.view.dart';
import 'onboarding/onboarding.dart';
import 'signature/shot_idcard.view.dart';
import 'signature/signature.view.dart';
import 'signature/id_number.view.dart';
import 'vote/vote.view.dart';

routes() => [
      GetPage(name: '/onboarding', page: () => const OnboardingPage()),
      GetPage(name: '/', page: () => const HomePage()),
      GetPage(name: '/signup', page: () => const AuthPage()),
      GetPage(name: '/validate', page: () => const ValidatePage()),
      GetPage(name: '/campaign', page: () => const CampaignPage()),
      GetPage(name: '/vote', page: () => const VotePage()),
      GetPage(name: '/signature', page: () => const SignaturePage()),
      GetPage(name: '/idcard', page: () => const UploadIdCardPage()),
      GetPage(name: '/idnumber', page: () => const TakeBackNumberPage()),
      GetPage(name: '/not-shareholder', page: () => const NotShareholderPage()),
      GetPage(name: '/duplicate', page: () => const AddressDuplicationPage()),
      GetPage(name: '/result', page: () => const ResultPage()),
      GetPage(name: '/checkvotenum', page: () => const CheckVoteNumPage()),
      GetPage(name: '/notification', page: () => const NotificaitionPage()),
    ];
