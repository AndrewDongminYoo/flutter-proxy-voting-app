// 📦 Package imports:
import 'package:get/route_manager.dart' show GetPage;

// 🌎 Project imports:
import 'about/show_result_page.view.dart';
import 'about/check_votes_num.view.dart';
import 'auth/auth.view.dart';
import 'auth/auth_validation.view.dart';
import 'auth/dedupe_address.view.dart';
import 'auth/not_shareholder.view.dart';
import 'campaign/campaign.view.dart';
import 'home/home.dart';
import 'notificaition/notification.view.dart';
import 'onboarding/onboarding.view.dart';
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
      GetPage(name: '/vote', page: () => const VoteAgendaPage()),
      GetPage(name: '/signature', page: () => const SignaturePage()),
      GetPage(name: '/idcard', page: () => const UploadIdCardPage()),
      GetPage(name: '/idnumber', page: () => const TakeBackNumberPage()),
      GetPage(name: '/not-shareholder', page: () => const NotShareholderPage()),
      GetPage(name: '/duplicate', page: () => const AddressDuplicationPage()),
      GetPage(name: '/result', page: () => const ShowResultPage()),
      GetPage(name: '/checkvotenum', page: () => const CheckVoteNumPage()),
      GetPage(name: '/notification', page: () => const NotificaitionPage()),
    ];
