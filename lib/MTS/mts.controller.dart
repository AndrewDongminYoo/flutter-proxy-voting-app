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
  CustomModule? _securitiesFirm;
  String _userLoginID = ''; // 사용자 아이디
  String _userLoginPW = ''; // 사용자 비밀번호
  String _bankPINNumber = ''; // 사용자 핀번호(4)
  String _certificationID = ''; // 인증서 상세이름
  String _certificationPW = ''; // 인증서 비밀번호
  String _certificationEX = ''; // 인증서 만료일자

  CustomModule get securitiesFirm {
    while (_securitiesFirm == null) {
      goToMtsFirmChoice();
    }
    return _securitiesFirm!;
  }

  void setMTSFirm(CustomModule firm) {
    _securitiesFirm = firm;
  }

  void setIDPW(String id, String password, String bankPIN) {
    _userLoginID = id;
    _userLoginPW = password;
    _bankPINNumber = bankPIN;
    String module = securitiesFirm.firmName;
    print('id: $id, password: $password, module: $module');
  }

  void setCERT(String id, String pw, String ex) {
    _certificationID = id;
    _certificationPW = pw;
    _certificationEX = ex;
    print('id: $id, password: $pw, expired: $ex');
  }

  loadMTSProcess() async {
    Get.dialog(LoadingScreen());
    await _service.fetchMTSData(
      module: securitiesFirm,
      userID: _userLoginID,
      password: _userLoginPW,
      passNum: _bankPINNumber,
      idLogin: securitiesFirm.canLoginWithID,
      certExpire: _certificationEX,
      certUsername: _certificationID,
      certPassword: _certificationPW,
    );
  }

  getTheResult(String functionName) async {
    return await _service.loadFunctionVal(functionName);
  }

  Future<void> showMTSResult() async {
    await loadMTSProcess();
    Get.isDialogOpen! ? goBack() : null;
    Get.bottomSheet(Container(
        padding: const EdgeInsets.all(36),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            )),
        child: ListView(children: texts)));
  }
}
