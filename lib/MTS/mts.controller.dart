// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'mts.dart';

class MtsController extends GetxController {
  static MtsController get() => Get.isRegistered<MtsController>()
      ? Get.find<MtsController>()
      : Get.put(MtsController());

  FIRM? _securitiesFirm;
  String userLoginID = '';
  String userLoginPW = ''; // it's a word made of number, but "String"

  FIRM get securitiesFirmId {
    if (_securitiesFirm != null) {
      return _securitiesFirm!;
    }
    return FIRM('secDaishin', 0, '', '');
  }

  void setMTSFirm(dynamic firm) {
    _securitiesFirm = FIRM.fromJson(firm);
  }

  void setIDPW(String id, String password) {
    userLoginID = id;
    userLoginPW = password;
  }
}
