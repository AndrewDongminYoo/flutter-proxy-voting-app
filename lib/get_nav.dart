import 'package:get/get.dart';

Future<dynamic>? goToOnBoarding() => Get.toNamed('/onboarding');
Future<dynamic>? goToHome() => Get.toNamed('/');
Future<dynamic>? goToSignUp() => Get.toNamed('/signup');
Future<dynamic>? goToCampaign() => Get.toNamed('/campaign');
Future<dynamic>? goToSignature() => Get.toNamed('/signature');
Future<dynamic>? goToIDCard() => Get.toNamed('/idcard');
Future<dynamic>? goToIDNumber() => Get.toNamed('/idnumber');
Future<dynamic>? goToNotShareHolders() => Get.toNamed('/not-shareholders');
Future<dynamic>? goToDuplicate() => Get.toNamed('/duplicate');
Future<dynamic>? goToResult() => Get.toNamed('/result');
Future<dynamic>? goToCheckVoteNum() => Get.toNamed('/checkvotenum');
Future<dynamic>? jumpToCheckVoteNum() => Get.offNamed('/checkvotenum');

Future<dynamic>? goToVoteWithLastMemory() =>
    Get.toNamed('/vote', arguments: 'voteWithLastMemory');
Future<dynamic>? goToVoteWithExample() =>
    Get.toNamed('/vote', arguments: 'voteWithExample');
Future<dynamic>? goToVoteWithoutExample() =>
    Get.toNamed('/vote', arguments: 'voteWithoutExample');

Future<dynamic>? goToValidateNew() =>
    Get.toNamed('/validate', arguments: 'newUser');
Future<dynamic>? goToValidateOld() =>
    Get.toNamed('/validate', arguments: 'existingUser');

Future<dynamic>? jumpToResult() {
  return Get.offNamedUntil('/', (route) {
    return route.settings.name == '/';
  });
}

Future<dynamic>? jumpToCampaign() {
  return Get.offNamedUntil('/campaign', (route) {
    return route.settings.name == '/';
  });
}
