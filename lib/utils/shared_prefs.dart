// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<SharedPreferences> _get() async {
    return await SharedPreferences.getInstance();
  }

  static Future<bool> clear() async {
    final SharedPreferences prefs = await _get();
    return await prefs.clear();
  }

  static Future<bool> needOnBoarding() async {
    final SharedPreferences prefs = await _get();
    final bool onBoarding = prefs.getBool('onBoarding') ?? true;
    print('[pref] onBoarding: $onBoarding');
    return onBoarding;
  }

  static Future<bool> doneOnBoarding() async {
    final SharedPreferences prefs = await _get();
    print('[pref] doneOnBoarding');
    return prefs.setBool('onBoarding', false);
  }

  static Future<List<String>> getConnectedFirms() async {
    final SharedPreferences prefs = await _get();
    return prefs.getStringList('connected') ?? [];
  }

  static Future<String> getTelNum() async {
    final SharedPreferences prefs = await _get();
    return prefs.getString('telNum') ?? '';
  }

  static Future<bool> setTelNum(String telNum) async {
    final SharedPreferences prefs = await _get();
    return await prefs.setString('telNum', telNum);
  }

  static Future<List<String>> getNotifications() async {
    final SharedPreferences prefs = await _get();
    return prefs.getStringList('notifications') ?? [];
  }

  static Future<bool> setNotifications(List<String> messages) async {
    final SharedPreferences prefs = await _get();
    return await prefs.setStringList('notifications', messages);
  }
}

Future<SharedPreferences> _() async {
  return await SharedPreferences.getInstance();
}

dynamic setCompletedCampaignList(List<String> completedCampaignList) async {
  final SharedPreferences prefs = await _();
  await prefs.setStringList('completedCampaign', completedCampaignList);
}

dynamic getCompletedCampaignList() async {
  final SharedPreferences prefs = await _();
  return prefs.getStringList('completedCampaign');
}

dynamic getShareholderId(dynamic campaignName) async {
  final SharedPreferences prefs = await _();
  return prefs.getInt('$campaignName-shareholder');
}

setShareholderId(String campaignName, int shareholderId) async {
  final SharedPreferences prefs = await _();
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
//     print(e);
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
//     print(e);
//   }
// }
