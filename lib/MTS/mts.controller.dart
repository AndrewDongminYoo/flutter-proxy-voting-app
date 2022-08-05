// 📦 Package imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'mts.dart';

class MtsController extends GetxController {
  static MtsController get() => Get.isRegistered<MtsController>()
      ? Get.find<MtsController>()
      : Get.put(MtsController());
  CooconMTSService service = CooconMTSService();

  FIRM? _securitiesFirm;
  String userLoginID = ''; // username123
  String userLoginPW = ''; // PaSsWoRd!@#
  String bankPassword = ''; // 4-num password

  FIRM get securitiesFirmId {
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
    debugPrint('id: $id, password: $password');
  }

  loadMTSDataAndProcess() {
    service.fetchMTSData(
      module: securitiesFirmId.module,
      username: userLoginID,
      password: userLoginPW,
      passNum: bankPassword,
    );
  }
}
