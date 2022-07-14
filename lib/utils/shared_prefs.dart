// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

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

setNickname() async {
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
