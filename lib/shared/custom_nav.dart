// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// 🌎 Project imports:
import '../lib.dart';

dynamic goBack() => Get.back();
dynamic goBackWithVal(dynamic context, dynamic value) =>
    Navigator.pop(context, value);
dynamic goOnboarding() => Get.to(() => const OnboardingPage());
dynamic goMainHome() => Get.to(() => const MainHomePage());
dynamic goCampaignPreview() => Get.to(() => const CampaignPreviewPage());
dynamic goAuthSignUp() => Get.to(() => const AuthSignUpPage());
dynamic goAuthValidNew() =>
    Get.to(() => const AuthValidatePage(), arguments: {'new': true});
dynamic goAuthValidOld() =>
    Get.to(() => const AuthValidatePage(), arguments: {'new': false});
dynamic goCampaignOverview() => Get.to(() => const CampaignOverviewPage());
dynamic goVoteSign() => Get.to(() => const VoteSignPage());
dynamic goUploadIdCard() => Get.to(() => const UploadIdCardPage());
dynamic goTakeIdNumber() => Get.to(() => const TakeIdNumberPage());
dynamic goNotShareholder() => Get.to(() => const NotShareholderPage());
dynamic goAddressDedupe() => Get.to(() => const AddressDedupePage());
dynamic goVoteNumCheck() => Get.to(() => const VoteNumCheckPage());
dynamic jumpVoteNumCheck() => Get.offAll(const VoteNumCheckPage());
dynamic goMTSFirmChoice() => Get.to(() => const MTSFirmChoicePage());
dynamic goMTSLoginChoice() => Get.to(() => const MTSLoginChoicePage());
dynamic goMTSLoginId() => Get.to(() => const MTSLoginIdPage());
dynamic goMTSLoginCert() => Get.to(() => const MTSLoginCertPage());
dynamic goMTSImportCert() => Get.to(() => const MTSImportCertPage());
dynamic goMTSShowResult() => Get.to(() => const MTSShowResultPage());
dynamic goMTSStockChoice(Account account) =>
    Get.to(() => ShowTransactionPage(account: account));
dynamic backToSignUp() => Get.offAll(() => const AuthSignUpPage());
dynamic goVoteWithExample() =>
    Get.to(() => const VoteToAgendaPage(), arguments: 'example');
dynamic goVoteWithMemory() =>
    Get.to(() => const VoteToAgendaPage(), arguments: 'memory');
dynamic goVoteNoExample() =>
    Get.to(() => const VoteToAgendaPage(), arguments: null);
dynamic jumpToMainHome() => Get.offAll(() => const MainHomePage());
dynamic jumpToCampaignOverview() =>
    Get.offAll(() => const CampaignOverviewPage());
dynamic jumpToVoteResult() => Get.offAll(() => const VoteResultPage());
