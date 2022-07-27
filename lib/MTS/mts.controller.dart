// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'mts.data.dart';

class MtsController extends GetxController {
  static MtsController get() => Get.isRegistered<MtsController>()
      ? Get.find<MtsController>()
      : Get.put(MtsController());

  Mts? _securitiesFirmId;

  Mts get securitiesFirmId {
    if (_securitiesFirmId != null) {
      return _securitiesFirmId!;
    }
    return Mts('secDaishin', '', 0);
  }

  void setSecuritiesModule(String module){
    securitiesFirmId.setModule = module;
  }

  void setMts(String id, int password) {
    securitiesFirmId.setId = id;
    securitiesFirmId.setPassword = password;
  }

  void getMts() {}
}
