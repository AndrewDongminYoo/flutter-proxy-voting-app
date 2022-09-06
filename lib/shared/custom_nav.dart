// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

// 🌎 Project imports:
import 'package:bside/lib.dart';

goBack() => Get.back();
goBackWithVal(context, value) => Navigator.pop(context, value);
goOnboarding() => Get.to(const OnboardingPage());
goMainHome() => Get.to(const MainHomePage());
goCampaignPreview() => Get.to(const CampaignPreviewPage());
goAuthSignUp() => Get.to(const AuthSignUpPage());
goAuthValidNew() => Get.to(const AuthValidatePage(), arguments: {'new': true});
goAuthValidOld() => Get.to(const AuthValidatePage(), arguments: {'new': false});
goCampaignOverview() => Get.to(const CampaignOverviewPage());
goVoteSign() => Get.to(const VoteSignPage());
goUploadIdCard() => Get.to(const UploadIdCardPage());
goTakeIdNumber() => Get.to(const TakeIdNumberPage());
goNotShareholder() => Get.to(const NotShareholderPage());
goAddressDedupe() => Get.to(const AddressDedupePage());
goVoteNumCheck() => Get.to(const VoteNumCheckPage());
jumpVoteNumCheck() => Get.offAll(const VoteNumCheckPage());
goMTSFirmChoice() => Get.to(const MTSFirmChoicePage());
goMTSLoginChoice() => Get.to(const MTSLoginChoicePage());
goMTSLoginId() => Get.to(const MTSLoginIdPage());
goMTSLoginCert() => Get.to(const MTSLoginCertPage());
goMTSImportCert() => Get.to(const MTSImportCertPage());
goMTSShowResult() => Get.to(const MTSShowResultPage());
backToSignUp() => Get.offAll(const AuthSignUpPage());
goVoteWithExample() => Get.to(const VoteToAgendaPage(), arguments: 'example');
goVoteWithMemory() => Get.to(const VoteToAgendaPage(), arguments: 'memory');
goVoteNoExample() => Get.to(const VoteToAgendaPage(), arguments: null);
jumpToMainHome() => Get.offAll(const MainHomePage());
jumpToCampaignOverview() => Get.offAll(const CampaignOverviewPage());
jumpToVoteResult() => Get.offAll(const VoteResultPage());
