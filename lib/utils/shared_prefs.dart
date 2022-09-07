// 📦 Package imports:
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<SharedPreferences> _get() async {
    return await SharedPreferences.getInstance();
  }

  static Future<bool> clear() async {
    final prefs = await _get();
    return await prefs.clear();
  }

  static Future<bool> needOnBoarding() async {
    final prefs = await _get();
    final onBoarding = prefs.getBool('onBoarding') ?? true;
    print('[pref] onBoarding: $onBoarding');
    return onBoarding;
  }

  static Future<bool> doneOnBoarding() async {
    final prefs = await _get();
    print('[pref] doneOnBoarding');
    return prefs.setBool('onBoarding', false);
  }

  static Future<List<String>> getConnectedFirms() async {
    final prefs = await _get();
    return prefs.getStringList('connected') ?? [];
  }

  static Future<String> getTelNum() async {
    final prefs = await _get();
    return prefs.getString('telNum') ?? '';
  }

  static Future<bool> setTelNum(String telNum) async {
    final prefs = await _get();
    return await prefs.setString('telNum', telNum);
  }

  static Future<List<String>> getNotifications() async {
    final prefs = await _get();
    return prefs.getStringList('notifications') ?? [];
  }

  static Future<bool> setNotifications(List<String> messages) async {
    final prefs = await _get();
    return await prefs.setStringList('notifications', messages);
  }
}

Future<SharedPreferences> _() async {
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
//     print(e.toString());
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
//     print(e.toString());
//   }
// }
