// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart' show Get;
import 'package:get/instance_manager.dart' show Get;

// 🌎 Project imports:
import '../shared/shared.dart';
import '../utils/shared_prefs.dart';
import 'mts.dart';

class MtsController extends GetxController {
  static MtsController get() => Get.isRegistered<MtsController>()
      ? Get.find<MtsController>()
      : Get.put(MtsController());
  final CooconMTSService _service = CooconMTSService();

  final String _username = ''; // 사용자 이름
  String _userLoginID = ''; // 사용자 아이디
  String _userLoginPW = ''; // 사용자 비밀번호
  String _bankPINNumber = ''; // 사용자 핀번호(4)
  String _certID = ''; // 인증서 상세이름
  String _certPW = ''; // 인증서 비밀번호
  String _certEX = ''; // 인증서 만료일자
  bool idLogin = true;
  Set<RKSWCertItem> _certList = {}; // 공동인증서 리스트
  final Set<Account> _accounts = {};
  Set<Account> get accounts => _accounts;
  void addAccount(
    CustomModule module,
    String idOrCert,
    String accountNum,
    String productCode,
    String productName,
  ) {
    bool isOk = true;
    for (Account element in _accounts) {
      if (accountNum == element.accountNum) {
        isOk = false;
      }
    }
    if (isOk) {
      _accounts.add(Account(
        module: module,
        idOrCert: idOrCert,
        accountNum: accountNum,
        productCode: productCode,
        productName: productName,
      ));
    }
  }

  bool _needId = false;
  bool get needId {
    for (int i = 0; i < firms.length; i++) {
      CustomModule current = firms[i];
      if (current.isException) {
        _needId = true;
      }
    }
    return _needId;
  }

  final List<CustomModule> _firms = <CustomModule>[];
  List<CustomModule> get firms {
    if (_firms.isNotEmpty) {
      return _firms;
    } else {
      loadFirms();
    }
    return _firms;
  }

  Future<void> loadFirms() async {
    List<String> res = await Storage.getConnectedFirms();
    for (String r in res) {
      CustomModule t = stockTradingFirms.firstWhere(
        (firm) => firm.firmName == r,
      );
      _firms.add(t);
    }
  }

  void addMTSFirm(CustomModule firm) {
    firms.add(firm);
  }

  void delMTSFirm(CustomModule firm) {
    firms.remove(firm);
  }

  void setIDPW(String id, String password, String bankPIN) {
    setID(id);
    _userLoginPW = password;
    setPin(bankPIN);
    idLogin = true;
    print('id: $id, password: $password, modules: $firms');
  }

  void setID(String id) {
    _userLoginID = id;
  }

  void setCertPW(String password) {
    _certPW = password;
  }

  void setPin(String bankPIN) {
    _bankPINNumber = bankPIN;
  }

  setCertification(RKSWCertItem item) {
    _certID = item.certName;
    _certEX = item.certExpire.replaceAll('.', '');
    idLogin = false;
  }

  Future<void> showMTSResult() async {
    Get.dialog(LoadingScreen());
    for (CustomModule firm in firms) {
      await _service.fetchMTSData(
        module: firm,
        username: _username,
        userId: _userLoginID,
        password: _userLoginPW,
        passNum: _bankPINNumber,
        idLogin: idLogin,
        certExpire: _certEX,
        certUsername: _certID,
        certPassword: _certPW,
        controller: this,
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

  Future<Set<RKSWCertItem>?> loadCertList() async {
    _certList = await _service.loadCertificationList();
    return _certList;
  }

  void emptyCerts() async {
    await _service.emptyCerts();
    _certList.clear();
  }

  Map<String, String> detailInfo(RKSWCertItem item) => item.json;

  void changePass(BuildContext context, RKSWCertItem item) async {
    String newPass = '';
    _certPW = await Get.dialog(PasswordDialog(
      password: newPass,
      title: '기존의 비밀번호를 입력하세요.',
    ));
    newPass = await Get.dialog(PasswordDialog(
      password: newPass,
      title: '변경할 비밀번호를 입력하세요.',
    ));
    _service.changePasswordOfCert(_certPW, newPass, item.certName);
    print(newPass);
    print(item.json);
  }

  void deleteCert(RKSWCertItem item) {
    _certList.remove(item);
    _service.deleteCert(item.certName);
  }
}
