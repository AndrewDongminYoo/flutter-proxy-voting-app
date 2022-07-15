// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:bside/lib.dart';

_() async {
  return await SharedPreferences.getInstance();
}

clearPref() async {
  final prefs = await _();
  await prefs.clear();
}

getIfFirstTime() async {
  final prefs = await _();
  return prefs.getBool('firstTime') ?? true;
}

setIamFirstTime() async {
  final prefs = await _();
  await prefs.setBool('firstTime', false);
}

getNickname() async {
  final prefs = await _();
  return prefs.getString('nickname') ?? '';
}

getTelephoneNumber() async {
  final prefs = await _();
  return prefs.getString('telNum') ?? '';
}

setTelephoneNumber(phoneNumber) async {
  final prefs = await _();
  await prefs.setString('telNum', phoneNumber);
  return phoneNumber;
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

getNotifications() async {
  final prefs = await _();
  return prefs.getStringList('notification') ?? [''];
}

setNotifications(messages) async {
  final prefs = await _();
  await prefs.setStringList('notification', messages);
}

loadAll() async {
  try {
    final authCtrl = AuthController.get();
    final notiCtrl = NotificationController.get();
    final voteCtrl = VoteController.get();
    final phoneNumber = await getTelephoneNumber();
    authCtrl.getUserInfo(phoneNumber);
    notiCtrl.getNotificationsLocal();
    voteCtrl.init();
  } catch (e) {
    debugPrint(e.toString());
  }
}

saveAll() async {
  try {
    final authCtrl = AuthController.get();
    final voteCtrl = VoteController.get();
    setTelephoneNumber(authCtrl.user.phoneNumber);
    setCompletedCampaignList(voteCtrl.completedCampaign.toList());
    setShareholderId(voteCtrl.campaign.enName, voteCtrl.shareholder.id);
  } catch (e) {
    debugPrint(e.toString());
  }
}
