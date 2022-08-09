// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../auth/widget/loading_screen.dart';
import 'mts.dart';

class MtsController extends GetxController {
  static MtsController get() => Get.isRegistered<MtsController>()
      ? Get.find<MtsController>()
      : Get.put(MtsController());
  CooconMTSService service = CooconMTSService();

  FIRM? _securitiesFirm;
  String userLoginID = ''; // username123
  String userLoginPW = ''; // PaSsWoRd!@#

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
    userLoginID = id;
    userLoginPW = password;
    print('id: $id, password: $password, module: ${securitiesFirm.module}');
  }

  loadMTSDataAndProcess(String bankPassword) async {
    Get.dialog(LoadingScreen());
    return await service.fetchMTSData(
      module: securitiesFirm.module,
      username: userLoginID,
      password: userLoginPW,
      passNum: bankPassword,
    );
  }
}
