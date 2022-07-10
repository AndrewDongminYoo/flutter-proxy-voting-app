// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🐦 Flutter imports:
import 'package:get/get.dart';

goBack() => Get.back();
goBackWithVal(context, value) => Navigator.pop(context, value);

goToOnBoarding() => Get.toNamed('/onboarding');
goToHome() => Get.toNamed('/');
goToSignUp() => Get.toNamed('/signup');
goToCampaign() => Get.toNamed('/campaign');
goToSignature() => Get.toNamed('/signature');
goToIDCard() => Get.toNamed('/idcard');
goToIDNumber() => Get.toNamed('/idnumber');
goToNotShareHolders() => Get.toNamed('/not-shareholders');
goToDuplicate() => Get.toNamed('/duplicate');
goToCheckVoteNum() => Get.toNamed('/checkvotenum');
goToNotificationPage() => Get.toNamed('/notification');
jumpToCheckVoteNum() => Get.offNamed('/checkvotenum');

goToVoteWithExample() {
  return Get.toNamed('/vote', arguments: 'voteWithExample');
}

goToVoteWithLastMemory() {
  return Get.toNamed('/vote', arguments: 'voteWithLastMemory');
}

goToVoteWithoutExample() {
  return Get.toNamed('/vote', arguments: 'voteWithoutExample');
}

goToValidateNew() => Get.toNamed(
      '/validate',
      arguments: {'isNew': 'newUser'},
    );
goToValidateOld() => Get.toNamed(
      '/validate',
      arguments: {'isNew': 'existingUser'},
    );

jumpToHome() => Get.offNamedUntil('/', (route) {
      return route.settings.name == '/';
    });

jumpToCampaign() => Get.offNamedUntil('/campaign', (route) {
      return route.settings.name == '/';
    });

jumpToResult() => Get.offNamedUntil('/result', (route) {
      return route.settings.name == '/result';
    });