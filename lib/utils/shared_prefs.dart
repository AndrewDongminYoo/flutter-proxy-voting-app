// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class CustomStorage {
  static Future<bool> clear() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  static Future<bool> needOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    final onBoarding = prefs.getBool('onBoarding') ?? true;
    debugPrint('[pref] onBoarding: $onBoarding');
    return onBoarding;
  }

  static Future<bool> doneOnBoarding() async {
    final prefs = await SharedPreferences.getInstance();
    debugPrint('[pref] doneOnBoarding');
    return prefs.setBool('onBoarding', false);
  }

  static Future<String> getTelNum() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('telNum') ?? '';
  }

  static Future<bool> setTelNum(String telNum) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString('telNum', telNum);
  }

  static Future<List<String>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notifications') ?? [];
  }

  static Future<bool> setNotifications(List<String> messages) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setStringList('notifications', messages);
  }
}

_() async {
  return await SharedPreferences.getInstance();
}

setCompletedCampaignList(completedCampaignList) async {
  final prefs = await _();
  await prefs.setStringList('completedCampaign', completedCampaignList);
}

getCompletedCampaignList() async {
  final prefs = await _();
  return prefs.getStringList('completedCampaign');
}

getShareholderId(campaignName) async {
  final prefs = await _();
  return prefs.getInt('$campaignName-shareholder');
}

setShareholderId(campaignName, shareholderId) async {
  final prefs = await _();
  await prefs.setInt('$campaignName-shareholder', shareholderId);
}

// loadAll() async {
//   try {
//     final authCtrl = AuthController.get();
//     final notiCtrl = NotiController.get();
//     final voteCtrl = VoteController.get();
//     final phoneNumber = await getTelephoneNumber();
//     authCtrl.getUserInfo(phoneNumber);
//     notiCtrl.getNotificationsLocal();
//     voteCtrl.init();
//   } catch (e) {
//     debugPrint(e.toString());
//   }
// }

// saveAll() async {
//   try {
//     final authCtrl = AuthController.get();
//     final voteCtrl = VoteController.get();
//     setTelephoneNumber(authCtrl.user.phoneNumber);
//     setCompletedCampaignList(voteCtrl.completedCampaign.toList());
//     setShareholderId(voteCtrl.campaign.enName, voteCtrl.shareholder.id);
//   } catch (e) {
//     debugPrint(e.toString());
//   }
// }
