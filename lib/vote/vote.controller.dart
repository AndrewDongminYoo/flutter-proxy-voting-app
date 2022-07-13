// 🎯 Dart imports:
import 'dart:async' show Future;
import 'dart:io' show Platform;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/custom_nav.dart';
import '../campaign/campaign.dart';
import '../auth/widget/loading_screen.dart';
import '../utils/shared_prefs.dart';
import 'vote.dart';

class VoteController extends GetxController {
  static VoteController get() => Get.isRegistered<VoteController>()
      ? Get.find<VoteController>()
      : Get.put(VoteController());

  // Vote 진행 전 사용 변수
  bool isCompleted = false;
  Campaign campaign = campaigns[1]; // TLI 지정
  Set<String> completedCampaign = {};
  List<Shareholder> completedShareholder = [];

  // Vote 진행 중 사용 변수
  final VoteService _service = VoteService();
  final shareholders = <Shareholder>[];
  Shareholder? _shareholder;
  VoteAgenda? _voteAgenda;

  VoteAgenda get voteAgenda {
    if (_voteAgenda != null) {
      return _voteAgenda!;
    } else {
      return VoteAgenda(-1, 'tli', '0000', 0, 0, 0, 0, 0);
    }
  }

  Shareholder get shareholder {
    if (_shareholder != null) {
      return _shareholder!;
    }
    return Shareholder(-1, 'annonymous', 'address', 0);
  }

  // 홈화면에서 User 정보를 불러온 후, user가 존재한다면 vote 데이터 불러오기
  void init() async {
    // TODO: 사용자가 앱을 재설치할 경우, pref가 없음, 이에 대한 대처 필요
    final campaignList = await getCompletedCampaignList();
    if (campaignList != null) {
      debugPrint('[VoteController] SharedPreferences exist');
      completedCampaign = {...campaignList};
      for (var campaign in completedCampaign) {
        final shareholderId = await getShareholderId(campaign);
        if (shareholderId != null) {
          Response response = await _service.validateShareholder(shareholderId);
          completedShareholder
              .add(Shareholder.fromJson(response.body['shareholder']));
        }
      }
    }
  }

  void setCampaign(Campaign newCampaign) {
    campaign = newCampaign;
    isCompleted = completedCampaign.contains(newCampaign.enName);
    update();
  }

  // 전자위임 가능여부를 판단하여 route 이동 진행
  // case A: 기존 사용자 - 결과페이지로 이동, 진행상황 표시
  // case B: 신규 사용자 - 주주명부 확인
  //     case B-1: 주주가 여려명인 경우, 동명이인이 있는 상황. 주소 확인페이지로 이동
  //     case B-2: 주주가 한명인 경우, 주식수 확인으로 이동
  //     case B-3: 주주가 없는 경우, 주주가 아닌 화면으로 이동
  void toVote(int uid, String name) async {
    Response response;
    startLoading();

    try {
      response = await _service.queryAgenda(uid, campaign.enName);
      if (response.isOk && response.body['isExist']) {
        // case A: 기존 사용자 - 결과페이지로 이동, 진행상황 표시
        debugPrint('[VoteController] user is exist');
        _voteAgenda = VoteAgenda.fromJson(response.body['agenda']);
        _shareholder = completedShareholder
            .firstWhere((sh) => sh.company == campaign.enName);
        await jumpToResult();
        return;
      }
    } catch (e) {
      debugPrint('[VoteController] queryAgenda error: $e');
    }

    try {
      // case B: 신규 사용자 - 주주명부 확인
      response = await _service.findSharesByName('tli', name);
      shareholders.clear(); // 기존 데이터 초기화
      (response.body['shareholders'])
          .forEach((e) => shareholders.add(Shareholder.fromJson(e)));
    } catch (e) {
      debugPrint('[VoteController] findSharesByName error: $e');
    }

    stopLoading();
    if (shareholders.length > 1) {
      // case B-1: 주주가 여려명인 경우, 동명이인이 있는 상황. 주소 확인페이지로 이동
      goToDuplicate();
    } else if (shareholders.length == 1) {
      // case B-2: 주주가 한명인 경우, 주식수 확인으로 이동
      _shareholder = shareholders[0];
      await setShareholderId(campaign.enName, shareholder.id);
      goToCheckVoteNum();
    } else {
      // case B-3: 주주가 없는 경우, 주주가 아닌 화면으로 이동
      goToNotShareHolders();
    }
  }

  // ===  page: 주소 확인페이지 ===
  List<String> addressList() => shareholders.map((sh) => sh.address).toList();

  void selectShareholder(int index) async {
    _shareholder = shareholders[index];
    await setShareholderId(campaign.enName, shareholder.id);
    await _service.validateShareholder(index); // 주주를 선택했다고 서버에 기록
  }

  Future<String> deviceInfo() async {
    String deviceInfo = 'unknown';
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    if (Platform.isIOS) {
      var response = await deviceInfoPlugin.iosInfo;
      deviceInfo = response.model.toString();
    } else if (Platform.isAndroid) {
      var response = await deviceInfoPlugin.androidInfo;
      deviceInfo = response.model.toString();
    }
    return deviceInfo;
  }

  void postVoteResult(int uid, List<VoteType> voteResult) async {
    String deviceName = await deviceInfo();
    Response response = await _service.postResult(
      uid,
      shareholder.id,
      deviceName,
      _switchVoteValue(voteResult[0]),
      _switchVoteValue(voteResult[1]),
      _switchVoteValue(voteResult[2]),
      _switchVoteValue(voteResult[3]),
    );
    _voteAgenda = VoteAgenda.fromJson(response.body['agenda']);

    // 현재 캠페인을 완료 목록에 저장
    completedCampaign.add(campaign.enName);
    final prefs = await getPrefs();
    prefs.setStringList('completedCampaign', completedCampaign.toList());
    debugPrint('completedCampaign, $completedCampaign');
    if (kDebugMode) {
      debugPrint("[VoteController] voteAgenda: ${response.body['agenda']}");
    }
  }

  Future<VoteAgenda?> getVoteResult(int uid, String company) async {
    Response response = await _service.queryAgenda(uid, company);
    if (response.body['isExist']) {
      debugPrint('[VoteController] ${response.body}');
      _voteAgenda = VoteAgenda.fromJson(response.body['agenda']);
      return _voteAgenda;
    } else {
      debugPrint("[VoteController] agenda doesn't exists.");
      return null;
    }
  }

  // === page: 전자서명 ===
  void putSignatureUrl(String url) async {
    await _service.postSignature(voteAgenda.id, url);
    voteAgenda.signatureAt = DateTime.now();
    update();
  }

  // === page: 신분증 업로드 ===
  void putIdCard(String url) async {
    await _service.postIdCard(voteAgenda.id, url);
    voteAgenda.idCardAt = DateTime.now();
    update();
  }

  // === Common ===
  void startLoading() {
    Get.dialog(LoadingScreen());
  }

  void stopLoading() {
    if (Get.isDialogOpen == true) {
      goBack();
    }
  }

  void trackBackId() {
    voteAgenda.backIdAt = DateTime.now();
  }

  int _switchVoteValue(VoteType voteType) {
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
}
