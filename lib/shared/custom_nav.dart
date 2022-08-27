// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

goBack() => Get.back();
goBackWithVal(context, value) => Navigator.pop(context, value);

goToOnBoarding() => Get.toNamed('/onboarding');
goToHome() => Get.toNamed('/');
goToSignUp() => Get.toNamed('/signup');
goToCampaign() => Get.toNamed('/campaign');
goToSignature() => Get.toNamed('/signature');
goToIDCard() => Get.toNamed('/idcard');
goToIDNumber() => Get.toNamed('/idnumber');
goToNotShareHolders() => Get.toNamed('/not-shareholder');
goToDuplicate() => Get.toNamed('/duplicate');
goToCheckVoteNum() => Get.toNamed('/checkvotenum');
goToMtsChoice() => Get.toNamed('/mts');
goToMtsLink(String sec) => Get.toNamed('/mts-signin');
goToMtsCertification() => Get.toNamed('/mts-cert');
goToPreviewCampaign() => Get.toNamed('/preview');

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

goToValidateNew() => Get.toNamed(
      '/validate',
      arguments: {'isNew': 'newUser'},
    );
goToValidateOld() => Get.toNamed(
      '/validate',
      arguments: {'isNew': 'existingUser'},
    );

jumpToHome() => Get.offNamedUntil('/', (route) => route.settings.name == '/');

jumpToCampaign() => Get.offNamedUntil(
    '/campaign', (route) => route.settings.name == '/campaign');

jumpToResult() =>
    Get.offNamedUntil('/result', (route) => route.settings.name == '/result');
