// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> _getPrefs() async {
  return await SharedPreferences.getInstance();
}

clearPref() async {
  final prefs = await _getPrefs();
  await prefs.clear();
}

getIfFirstTime() async {
  final prefs = await _getPrefs();
  return prefs.getBool('firstTime') ?? true;
}

setIamFirstTime() async {
  final prefs = await _getPrefs();
  await prefs.setBool('firstTime', false);
}

setNickname() async {
  final prefs = await _getPrefs();
  return prefs.getString('nickname') ?? '';
}

getTelephoneNumber() async {
  final prefs = await _getPrefs();
  return prefs.getString('telNum') ?? '';
}

setTelephoneNumber(phoneNumber) async {
  final prefs = await _getPrefs();
  await prefs.setString('telNum', phoneNumber);
  return phoneNumber;
}

setCompletedCampaignList(completedCampaignList) async {
  final prefs = await _getPrefs();
  await prefs.setStringList('completedCampaign', completedCampaignList);
}

getCompletedCampaignList() async {
  final prefs = await _getPrefs();
  return prefs.getStringList('completedCampaign');
}

getShareholderId(campaignName) async {
  final prefs = await _getPrefs();
  return prefs.getInt('$campaignName-shareholder');
}

setShareholderId(campaignName, shareholderId) async {
  final prefs = await _getPrefs();
  await prefs.setInt('$campaignName-shareholder', shareholderId);
}

getNotifications() async {
  final prefs = await _getPrefs();
  return prefs.getStringList('notification') ?? [''];
}

setNotifications(messages) async {
  final prefs = await _getPrefs();
  await prefs.setStringList('notification', messages);
}
