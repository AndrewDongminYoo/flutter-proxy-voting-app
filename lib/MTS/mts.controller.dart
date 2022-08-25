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

  FIRM? _securitiesFirm;
  String _userLoginID = ''; // ID for login
  String _userLoginPW = ''; // PaSsWoRd!@#

  FIRM get securitiesFirm {
    if (_securitiesFirm != null) {
      return _securitiesFirm!;
    }
    return FIRM('secShinhan', 0, '', '');
  }

  void setMTSFirm(dynamic firm) {
    _securitiesFirm = FIRM.fromJson(firm);
  }

  void setIDPW(String id, String password) {
    _userLoginID = id;
    _userLoginPW = password;
    print('id: $id, password: $password, module: ${securitiesFirm.module}');
  }

  loadMTSDataAndProcess(String bankPassword) async {
    Get.dialog(LoadingScreen());
    return await _service.fetchMTSData(
      module: CustomModule(securitiesFirm.module),
      userID: _userLoginID,
      password: _userLoginPW,
      passNum: bankPassword,
    );
  }

  getTheResult(String functionName) async {
    return await _service.loadFunctionVal(functionName);
  }
}
