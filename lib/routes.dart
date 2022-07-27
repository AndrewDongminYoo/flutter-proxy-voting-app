// 📦 Package imports:
import 'package:get/route_manager.dart' show GetPage;

// 🌎 Project imports:
import 'MTS/mts.dart';
import 'lib.dart';

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
      GetPage(name: '/mts', page: () => const MtsPage()),
      GetPage(name: '/mts-link', page: () => const MtsLinkPage()),
      GetPage(name: '/mts-certification', page: () => const SecuritiesPage())
    ];
