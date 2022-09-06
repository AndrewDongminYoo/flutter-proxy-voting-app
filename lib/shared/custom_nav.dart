// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

goBack() => Get.back();
goBackWithVal(context, value) => Navigator.pop(context, value);

goOnboarding() => Get.toNamed('/onboarding');
goMainHome() => Get.toNamed('/');
goCampaignPreview() => Get.toNamed('/preview');
goAuthSignUp() => Get.toNamed('/signup');
goAuthValidateNew() =>
    Get.toNamed('/validate', arguments: {'isNew': 'newUser'});
goAuthValidateOld() =>
    Get.toNamed('/validate', arguments: {'isNew': 'existingUser'});
goCampaignOverview() => Get.toNamed('/campaign');
goVoteSign() => Get.toNamed('/signature');
goUploadIdCard() => Get.toNamed('/idcard');
goTakeIdNumber() => Get.toNamed('/idnumber');
goNotShareholder() => Get.toNamed('/not-shareholder');
goAddressDedupe() => Get.toNamed('/duplicate');
goVoteNumCheck() => Get.toNamed('/checkvotenum');
goMTSFirmChoice() => Get.toNamed('/mts');
goMTSLoginChoice() => Get.toNamed('/mts-choice');
goMTSLoginId() => Get.toNamed('/mts-id');
goMTSLoginCert() => Get.toNamed('/mts-cert');
goMTSImportCert() => Get.toNamed('/cert-list');
goMTSShowResult() => Get.toNamed('mts-result');

backToSignUp() => Get.offNamedUntil(
      '/signup',
      (route) => route.settings.name == '/signup',
    );
jumpToCheckVoteNum() => Get.offNamedUntil(
      '/checkvotenum',
      (route) => route.settings.name == '/checkvotenum',
    );
goToVoteWithExample() {
  return Get.toNamed(
    '/vote',
    arguments: 'voteWithExample',
  );
}

goToVoteWithLastMemory() {
  return Get.toNamed(
    '/vote',
    arguments: 'voteWithLastMemory',
  );
}

goToVoteWithoutExample() {
  return Get.toNamed(
    '/vote',
    arguments: 'voteWithoutExample',
  );
}

jumpToHome() => Get.offNamedUntil('/', (route) => route.settings.name == '/');
jumpToCampaign() => Get.offNamedUntil(
    '/campaign', (route) => route.settings.name == '/campaign');
jumpToResult() =>
    Get.offNamedUntil('/result', (route) => route.settings.name == '/result');
