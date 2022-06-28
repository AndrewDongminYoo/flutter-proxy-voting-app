import 'dart:io';
import 'dart:async';

import 'package:get/get.dart';
import '../vote/vote.service.dart';
import '../shared/loading_screen.dart';
import '../campaign/campaign.data.dart';
import '../campaign/campaign.model.dart';

import 'vote.model.dart';
import 'shareholder.data.dart';
import 'package:device_info_plus/device_info_plus.dart';

class VoteController extends GetxController {
  final VoteService _service = VoteService();
  final shareholders = <Shareholder>[];
  Campaign campaign = campaigns[0];
  Shareholder? shareholder;
  VoteAgenda? voteAgenda;

  static VoteController get to => Get.find();

  void setCampaign(Campaign newCampaign) {
    campaign = newCampaign;
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
      response = await _service.queryAgenda(uid, 'tli');
      if (response.isOk && response.body['isExist']) {
        // case A: 기존 사용자 - 결과페이지로 이동, 진행상황 표시
        print('[VoteController] user is exist');
        voteAgenda = VoteAgenda.fromJson(response.body['agenda']);
        Get.toNamed('/result');
        return;
      }
    } catch (e) {
      print('[VoteController] queryAgenda error: $e');
    }

    try {
      // case B: 신규 사용자 - 주주명부 확인
      response = await _service.findSharesByName('tli', name);
      shareholders.clear(); // 기존 데이터 초기화
      (response.body['shareholders'])
          .forEach((e) => shareholders.add(Shareholder.fromSharesJson(e)));
    } catch (e) {
      print('[VoteController] findSharesByName error: $e');
    }

    stopLoading();
    if (shareholders.length > 1) {
      // case B-1: 주주가 여려명인 경우, 동명이인이 있는 상황. 주소 확인페이지로 이동
      Get.toNamed('/duplicate');
    } else if (shareholders.length == 1) {
      // case B-2: 주주가 한명인 경우, 주식수 확인으로 이동
      shareholder = shareholders[0];
      Get.toNamed('/checkvotenum');
    } else {
      // case B-3: 주주가 없는 경우, 주주가 아닌 화면으로 이동
      Get.toNamed('/not-shareholder');
    }
  }

  // ===  page: 주소 확인페이지 ===
  List<String> addressList() {
    return shareholders.map((e) {
      return e.address;
    }).toList();
  }

  void selectShareholder(int index) async {
    shareholder = shareholders[index];
    await _service.validateShareholder(index);
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

  // === page: 주식수 확인 ===
  void postVoteResult(int uid, List<VoteType> voteResult) async {
    String deviceName = await deviceInfo();
    if (shareholder != null) {
      Response response = await _service.postVoteResult(
        uid,
        shareholder!.id,
        deviceName,
        _switchVoteValue(voteResult[0]),
        _switchVoteValue(voteResult[1]),
        _switchVoteValue(voteResult[2]),
        _switchVoteValue(voteResult[3]),
      );
      voteAgenda = VoteAgenda.fromJson(response.body['agenda']);
    }
  }

  Future<VoteAgenda?> getVoteResult(int uid, String company) async {
    Response response = await _service.queryAgenda(uid, company);
    if (response.body['isExist']) {
      print(response.body);
      return VoteAgenda.fromJson(response.body['agenda']);
    } else {
      print("agenda doesn't exists.");
      return null;
    }
  }

  // === page: 전자서명 ===
  void putSignatureUrl(String url) async {
    await _service.postSignature(voteAgenda!.id, url);
  }

  // === page: 신분증 업로드 ===
  void putIdCard(String url) async {
    await _service.postIdCard(voteAgenda!.id, url);
  }

  // === Common ===
  void startLoading() {
    Get.dialog(const LoadingScreen());
  }

  void stopLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
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
