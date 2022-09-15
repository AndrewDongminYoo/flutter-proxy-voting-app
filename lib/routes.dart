// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show GetPage;

// 🌎 Project imports:
import 'lib.dart';

List<GetPage<String>> getPages = [
  GetPage(name: '/onboarding', page: () => const OnboardingPage()),
  GetPage(name: '/', page: () => const MainHomePage()),
  GetPage(name: '/preview', page: () => const CampaignPreviewPage()),
  GetPage(name: '/signup', page: () => const AuthSignUpPage()),
  GetPage(name: '/validate', page: () => const AuthValidatePage()),
  GetPage(name: '/campaign', page: () => const CampaignOverviewPage()),
  GetPage(name: '/vote', page: () => const VoteToAgendaPage()),
  GetPage(name: '/signature', page: () => const VoteSignPage()),
  GetPage(name: '/idcard', page: () => const UploadIdCardPage()),
  GetPage(name: '/idnumber', page: () => const TakeIdNumberPage()),
  GetPage(name: '/not-shareholder', page: () => const NotShareholderPage()),
  GetPage(name: '/duplicate', page: () => const AddressDedupePage()),
  GetPage(name: '/result', page: () => const VoteResultPage()),
  GetPage(name: '/checkvotenum', page: () => const VoteNumCheckPage()),
  GetPage(name: '/mts', page: () => const MTSFirmChoicePage()),
  GetPage(name: '/mts-choice', page: () => const MTSLoginChoicePage()),
  GetPage(name: '/mts-id', page: () => const MTSLoginIdPage()),
  GetPage(name: '/mts-cert', page: () => const MTSImportCertPage()),
  GetPage(name: '/cert-list', page: () => const MTSLoginCertPage()),
  GetPage(name: '/mts-result', page: () => const MTSShowResultPage()),
];

List<String> names = getPages
    .map(
      (GetPage<String> element) => element.name,
    )
    .toList();
List<Widget> pages = getPages
    .map(
      (GetPage<String> element) => element.page(),
    )
    .toList();
