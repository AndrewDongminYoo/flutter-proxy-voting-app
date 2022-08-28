// 🎯 Dart imports:
import 'dart:async' show Future;
import 'dart:io' show Platform;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart' show kDebugMode;

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/loading_screen.dart';
import '../campaign/campaign.dart';
import '../shared/custom_nav.dart';
import '../utils/utils.dart';
import 'vote.dart';

class VoteController extends GetxController {
  static VoteController get() => Get.isRegistered<VoteController>()
      ? Get.find<VoteController>()
      : Get.put(VoteController());

  // Vote 진행 전 사용 변수
  bool isCompleted = false;
  Campaign campaign = campaigns[1]; // TLI 지정
  Set<String> completedCampaign = {};
  final List<Shareholder> _completedShareholder = [];

  // Vote 진행 중 사용 변수
  final VoteService _service = VoteService();
  final _shareholders = <Shareholder>[];
  Shareholder? _shareholder;
  VoteAgenda? _voteAgenda;

  VoteAgenda get voteAgenda {
    if (_voteAgenda != null) {
      return _voteAgenda!;
    } else {
      return VoteAgenda(
        id: -1,
        company: 'tli',
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
      company: 'tli',
    );
  }

  // 홈화면에서 User 정보를 불러온 후, user가 존재한다면 vote 데이터 불러오기
  void init() async {
    final campaignList = await getCompletedCampaignList();
    if (campaignList != null) {
      print('[VoteController] SharedPreferences exist');
      completedCampaign = {...campaignList};
      for (String campaign in completedCampaign) {
        final shareholderId = await getShareholderId(campaign);
        if (shareholderId != null) {
          Response response = await _service.validateShareholder(shareholderId);
          if (response.statusCode != 500) {
            _completedShareholder
                .add(Shareholder.fromJson(response.body['shareholder']));
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

  // 전자위임 가능여부를 판단하여 route 이동 진행
  // case A: 기존 사용자 - 결과페이지로 이동, 진행상황 표시
  // case B: 신규 사용자 - 주주명부 확인
  //     case B-1: 주주가 여려명인 경우, 동명이인이 있는 상황. 주소 확인페이지로 이동
  //     case B-2: 주주가 한명인 경우, 주식수 확인으로 이동
  //     case B-3: 주주가 없는 경우, 주주가 아닌 화면으로 이동
  void toVote(int uid, String name) async {
    Response response;
    _startLoading();

    try {
      response = await _service.queryAgenda(uid, campaign.enName);
      if (response.isOk && response.body['isExist']) {
        // case A: 기존 사용자 - 결과페이지로 이동, 진행상황 표시
        print('[VoteController] user is exist');
        _voteAgenda = VoteAgenda.fromJson(response.body['agenda']);
        _shareholder = _completedShareholder
            .firstWhere((sh) => sh.company == campaign.enName);
        await jumpToResult();
        return;
      }
    } catch (e) {
      print('[VoteController] queryAgenda error: $e');
    }

    try {
      // case B: 신규 사용자 - 주주명부 확인
      response = await _service.findSharesByName('tli', name);
      _shareholders.clear(); // 기존 데이터 초기화
      (response.body['shareholders'])
          .forEach((e) => _shareholders.add(Shareholder.fromJson(e)));
    } catch (e) {
      print('[VoteController] findSharesByName error: $e');
    }

    _stopLoading();
    if (_shareholders.length > 1) {
      // case B-1: 주주가 여려명인 경우, 동명이인이 있는 상황. 주소 확인페이지로 이동
      goToDuplicate();
    } else if (_shareholders.length == 1) {
      // case B-2: 주주가 한명인 경우, 주식수 확인으로 이동
      _shareholder = _shareholders[0];
      await setShareholderId(campaign.enName, shareholder.id);
      goToCheckVoteNum();
    } else {
      // case B-3: 주주가 없는 경우, 주주가 아닌 화면으로 이동
      goToNotShareHolders();
    }
  }

  // ===  page: 주소 확인페이지 ===
  List<String> get addressList =>
      _shareholders.map((sh) => sh.address).toList();

  selectShareholder(int index) async {
    _shareholder = _shareholders[index];
    await setShareholderId(campaign.enName, shareholder.id);
    await _service.validateShareholder(index); // 주주를 선택했다고 서버에 기록
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
    int _switch(VoteType voteType) {
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

    Response response = await _service.postResult(
      uid,
      shareholder.id,
      deviceName,
      _switch(voteResult[0]),
      _switch(voteResult[1]),
      _switch(voteResult[2]),
      _switch(voteResult[3]),
    );
    _voteAgenda = VoteAgenda.fromJson(response.body['agenda']);

    // 현재 캠페인을 완료 목록에 저장
    completedCampaign.add(campaign.enName);
    await setCompletedCampaignList(completedCampaign.toList());
    print('completedCampaign, $completedCampaign');
    if (kDebugMode) {
      print("[VoteController] voteAgenda: ${response.body['agenda']}");
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
