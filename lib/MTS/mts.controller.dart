// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../auth/widget/loading_screen.dart' show LoadingScreen;
import 'mts.dart';

class MtsController extends GetxController {
  static MtsController get() => Get.isRegistered<MtsController>()
      ? Get.find<MtsController>()
      : Get.put(MtsController());
  final CooconMTSService _service = CooconMTSService();

  CustomModule? _securitiesFirm;
  String _userLoginID = ''; // ID for login
  String _userLoginPW = ''; // PaSsWoRd!@#
  String _bankPINNumber = '';
  String _certificationID = '';
  String _certificationPW = '';
  String _certificationEX = '';

  CustomModule get securitiesFirm {
    if (_securitiesFirm != null) {
      return _securitiesFirm!;
    }
    return CustomModule(firmName: 'secShinhan');
  }

  void setMTSFirm(CustomModule firm) {
    _securitiesFirm = firm;
  }

  void setIDPW(String id, String password, String bankPIN) {
    _userLoginID = id;
    _userLoginPW = password;
    _bankPINNumber = bankPIN;
    print('id: $id, password: $password, module: ${securitiesFirm.firmName}');
  }

  void setCERT(String id, String pw, String ex) {
    _certificationID = id;
    _certificationPW = pw;
    _certificationEX = ex;
    print('id: $id, password: $pw, expired: $ex');
  }

  loadMTSDataAndProcess() async {
    Get.dialog(LoadingScreen());
    return await _service.fetchMTSData(
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
}
