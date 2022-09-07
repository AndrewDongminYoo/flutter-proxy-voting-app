// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import 'mts.dart';

class MtsController extends GetxController {
  static MtsController get() => Get.isRegistered<MtsController>()
      ? Get.find<MtsController>()
      : Get.put(MtsController());
  final CooconMTSService _service = CooconMTSService();

  final List<Text> texts = [];
  final List<CustomModule> firms = <CustomModule>[];
  String username = ''; // 사용자 이름
  String _userLoginID = ''; // 사용자 아이디
  String _userLoginPW = ''; // 사용자 비밀번호
  String _bankPINNumber = ''; // 사용자 핀번호(4)
  String _certID = ''; // 인증서 상세이름
  String _certPW = ''; // 인증서 비밀번호
  String _certEX = ''; // 인증서 만료일자
  bool _needId = false;

  bool idLogin = true;
  List<RKSWCertItem> certList = []; // 공동인증서 리스트
  bool get needId {
    for (int i = 0; i < firms.length; i++) {
      CustomModule current = firms[i];
      if (current.isException) {
        _needId = true;
      }
    }
    return _needId;
  }

  void addMTSFirm(CustomModule firm) {
    firms.add(firm);
  }

  void delMTSFirm(CustomModule firm) {
    firms.remove(firm);
  }

  void setIDPW(String id, String password, String bankPIN) {
    _userLoginID = id;
    _userLoginPW = password;
    _bankPINNumber = bankPIN;
    idLogin = true;
    print('id: $id, password: $password, modules: $firms');
  }

  void setCertID(String id) {
    _userLoginID = id;
    idLogin = false;
  }

  void setCertPW(String password) {
    _certPW = password;
    idLogin = false;
    print('id: $_certID, password: $_certPW, expired: $_certEX');
  }

  setCertification(RKSWCertItem item) {
    _certID = item.subjectName;
    _certEX = item.expiredTime.replaceAll('.', '');
    idLogin = false;
  }

  Future<void> showMTSResult() async {
    texts.clear();
    Get.dialog(LoadingScreen());
    for (var firm in firms) {
      await _service.fetchMTSData(
        module: firm,
        username: username,
        userId: _userLoginID,
        password: _userLoginPW,
        passNum: _bankPINNumber,
        idLogin: idLogin,
        certExpire: _certEX,
        certUsername: _certID,
        certPassword: _certPW,
      );
    }
    if (Get.isDialogOpen!) Get.back();
    await goMTSShowResult();
  }

  Future<String?> loadTwelveDigits() async {
    return await _service.getTwelveDigits();
  }

  Future<bool> checkIfImported() async {
    return await _service.checkImport();
  }

  Future<List<RKSWCertItem>?> loadCertList() async {
    certList = await _service.loadCertiList();
    return certList;
  }

  void emptyCerts() async {
    await _service.emptyCerts();
    certList = [];
  }
}
