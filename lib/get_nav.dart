import 'package:get/get.dart';

goToOnBoarding() => Get.toNamed('/onboarding');
goToHome() => Get.toNamed('/');
goToSignUp() => Get.toNamed('/signup');
goToCampaign() => Get.toNamed('/campaign');
goToSignature() => Get.toNamed('/signature');
goToIDCard() => Get.toNamed('/idcard');
goToIDNumber() => Get.toNamed('/idnumber');
goToNotShareHolders() => Get.toNamed('/not-shareholders');
goToDuplicate() => Get.toNamed('/duplicate');
goToResult() => Get.toNamed('/result');
goToCheckVoteNum() => Get.toNamed('/checkvotenum');
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

goToValidateNew() => Get.toNamed('/validate', arguments: 'newUser');
goToValidateOld() => Get.toNamed('/validate', arguments: 'existingUser');

jumpToHome() => Get.offNamedUntil('/', (route) {
      return route.settings.name == '/';
    });

jumpToCampaign() => Get.offNamedUntil('/campaign', (route) {
      return route.settings.name == '/';
    });

jumpToResult() => Get.offNamedUntil('/result', (route) {
      return route.settings.name == '/result';
    });
