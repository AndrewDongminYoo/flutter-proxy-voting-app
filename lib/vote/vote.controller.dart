// π― Dart imports:
import 'dart:async' show Future;
import 'dart:io' show Platform;

// π¦ Flutter imports:
import 'package:flutter/foundation.dart';

// π¦ Package imports:
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/state_manager.dart' show Get;
import 'package:get/instance_manager.dart' show Get;

// π Project imports:
import '../shared/loading_screen.dart';
import '../campaign/campaign.dart';
import '../shared/custom_nav.dart';
import '../utils/utils.dart';
import 'vote.dart';

class VoteController extends GetxController {
  static VoteController get() => Get.isRegistered<VoteController>()
      ? Get.find<VoteController>()
      : Get.put(VoteController());

  // Vote μ§ν μ  μ¬μ© λ³μ
  bool isCompleted = false;
  Campaign campaign = campaigns[1]; // TLI μ§μ 
  Set<String> completedCampaign = {};
  final List<Shareholder> _completedShareholder = [];

  // Vote μ§ν μ€ μ¬μ© λ³μ
  final VoteService _service = VoteService();
  final List<Shareholder> _shareholders = <Shareholder>[];
  Shareholder? _shareholder;
  VoteAgenda? _voteAgenda;

  VoteAgenda get voteAgenda {
    if (_voteAgenda != null) {
      return _voteAgenda!;
    } else {
      return VoteAgenda(
        id: -1,
        company: 'current',
        curStatus: '0000',
        sharesNum: 0,
        agenda1: 0,
        agenda2: 0,
        agenda3: 0,
        agenda4: 0,
      );
    }
  }

  Shareholder get shareholder {
    if (_shareholder != null) {
      return _shareholder!;
    }
    return Shareholder(
      id: -1,
      username: 'annonymous',
      address: 'address',
      sharesNum: 0,
      company: 'current',
    );
  }

  // ννλ©΄μμ User μ λ³΄λ₯Ό λΆλ¬μ¨ ν, userκ° μ‘΄μ¬νλ€λ©΄ vote λ°μ΄ν° λΆλ¬μ€κΈ°
  void init() async {
    final dynamic campaignList = await getCompletedCampaignList();
    if (campaignList != null) {
      print('[VoteController] SharedPreferences exist');
      completedCampaign = {...campaignList as List<String>};
      for (String campaign in completedCampaign) {
        final dynamic shareholderId = await getShareholderId(campaign);
        if (shareholderId != null) {
          Response<dynamic> response =
              await _service.validateShareholder(shareholderId as int);
          if (response.statusCode != 500) {
            _completedShareholder.add(Shareholder.fromJson(
                response.body['shareholder'] as Map<String, dynamic>));
          }
        }
      }
    }
  }

  void setCampaign(Campaign newCampaign) {
    campaign = newCampaign;
    isCompleted = completedCampaign.contains(newCampaign.enName);
    update();
  }

  // μ μμμ κ°λ₯μ¬λΆλ₯Ό νλ¨νμ¬ route μ΄λ μ§ν
  // case A: κΈ°μ‘΄ μ¬μ©μ - κ²°κ³Όνμ΄μ§λ‘ μ΄λ, μ§νμν© νμ
  // case B: μ κ· μ¬μ©μ - μ£Όμ£ΌλͺλΆ νμΈ
  //     case B-1: μ£Όμ£Όκ° μ¬λ €λͺμΈ κ²½μ°, λλͺμ΄μΈμ΄ μλ μν©. μ£Όμ νμΈνμ΄μ§λ‘ μ΄λ
  //     case B-2: μ£Όμ£Όκ° νλͺμΈ κ²½μ°, μ£Όμμ νμΈμΌλ‘ μ΄λ
  //     case B-3: μ£Όμ£Όκ° μλ κ²½μ°, μ£Όμ£Όκ° μλ νλ©΄μΌλ‘ μ΄λ
  void toVote(int uid, String name) async {
    Response<dynamic> response;
    _startLoading();

    try {
      response = await _service.queryAgenda(uid, campaign.enName);
      if (response.isOk && response.body['isExist'] as bool) {
        // case A: κΈ°μ‘΄ μ¬μ©μ - κ²°κ³Όνμ΄μ§λ‘ μ΄λ, μ§νμν© νμ
        print('[VoteController] user is exist');
        _voteAgenda = VoteAgenda.fromJson(
            response.body['agenda'] as Map<String, dynamic>);
        _shareholder = _completedShareholder
            .firstWhere((sh) => sh.company == campaign.enName);
        await jumpToVoteResult();
        return;
      }
    } catch (e) {
      print('[VoteController] queryAgenda error: $e');
    }

    try {
      // case B: μ κ· μ¬μ©μ - μ£Όμ£ΌλͺλΆ νμΈ
      response = await _service.findSharesByName('current', name);
      _shareholders.clear(); // κΈ°μ‘΄ λ°μ΄ν° μ΄κΈ°ν
      (response.body['shareholders']).forEach((dynamic e) =>
          _shareholders.add(Shareholder.fromJson(e as Map<String, dynamic>)));
    } catch (e) {
      print('[VoteController] findSharesByName error: $e');
    }

    _stopLoading();
    if (_shareholders.length > 1) {
      // case B-1: μ£Όμ£Όκ° μ¬λ €λͺμΈ κ²½μ°, λλͺμ΄μΈμ΄ μλ μν©. μ£Όμ νμΈνμ΄μ§λ‘ μ΄λ
      goAddressDedupe();
    } else if (_shareholders.length == 1) {
      // case B-2: μ£Όμ£Όκ° νλͺμΈ κ²½μ°, μ£Όμμ νμΈμΌλ‘ μ΄λ
      _shareholder = _shareholders[0];
      await setShareholderId(campaign.enName, shareholder.id);
      goVoteNumCheck();
    } else {
      // case B-3: μ£Όμ£Όκ° μλ κ²½μ°, μ£Όμ£Όκ° μλ νλ©΄μΌλ‘ μ΄λ
      goNotShareholder();
    }
  }

  // ===  page: μ£Όμ νμΈνμ΄μ§ ===
  List<String> get addressList =>
      _shareholders.map((sh) => sh.address).toList();

  selectShareholder(int index) async {
    _shareholder = _shareholders[index];
    await setShareholderId(campaign.enName, shareholder.id);
    await _service.validateShareholder(index); // μ£Όμ£Όλ₯Ό μ ννλ€κ³  μλ²μ κΈ°λ‘
  }

  Future<String> deviceInfo() async {
    String batteryInfo = await Battery.getBattery();
    String deviceInfo = 'unknown';
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS) {
      IosDeviceInfo response = await deviceInfoPlugin.iosInfo;
      deviceInfo = response.model.toString();
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo response = await deviceInfoPlugin.androidInfo;
      deviceInfo = response.model.toString();
    }
    Map<String, String> info = {
      'app_name': packageInfo.appName,
      'build_number': packageInfo.buildNumber,
      'app_version': packageInfo.version,
      'device_name': deviceInfo,
      'battery': batteryInfo,
    };
    if (kDebugMode) {
      print(info);
    }
    return deviceInfo;
  }

  void postVoteResult(int uid, List<VoteType> voteResult) async {
    String deviceName = await deviceInfo();
    int choice(VoteType voteType) {
      switch (voteType) {
        case VoteType.agree:
          return 1;
        case VoteType.abstention:
          return 0;
        case VoteType.disagree:
          return -1;
        case VoteType.none:
          return -2;
      }
    }

    Response<dynamic> response = await _service.postResult(
      uid,
      shareholder.id,
      deviceName,
      choice(voteResult[0]),
      choice(voteResult[1]),
      choice(voteResult[2]),
      choice(voteResult[3]),
    );
    _voteAgenda =
        VoteAgenda.fromJson(response.body['agenda'] as Map<String, dynamic>);

    // νμ¬ μΊ νμΈμ μλ£ λͺ©λ‘μ μ μ₯
    completedCampaign.add(campaign.enName);
    await setCompletedCampaignList(completedCampaign.toList());
    print('completedCampaign, $completedCampaign');
    if (kDebugMode) {
      print("[VoteController] voteAgenda: ${response.body['agenda']}");
    }
  }

  // === page: μ μμλͺ ===
  void putSignatureUrl(String url) async {
    await _service.postSignature(voteAgenda.id, url);
    voteAgenda.signatureAt = DateTime.now();
    update();
  }

  // === page: μ λΆμ¦ μλ‘λ ===
  void putIdCard(String url) async {
    await _service.postIdCard(voteAgenda.id, url);
    voteAgenda.idCardAt = DateTime.now();
    update();
  }

  // === Common ===
  void _startLoading() {
    Get.dialog(LoadingScreen());
  }

  void _stopLoading() {
    if (Get.isDialogOpen == true) {
      goBack();
    }
  }

  void trackBackId() {
    voteAgenda.backIdAt = DateTime.now();
  }
}
