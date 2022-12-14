// π¦ Package imports:
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get_connect/connect.dart' show GetConnect;
import 'package:get/get_utils/src/extensions/dynamic_extensions.dart';

// π Project imports:
import '../utils/global_channel.dart';
import 'mts.dart';

class CooconMTSService extends GetConnect {
  MtsController? ctrl;

  Future<void> fetchMTSData({
    required CustomModule module,
    required String userId, // "ydm2790"
    required String username, // "μ λλ―Ό"
    required String password,
    required String passNum,
    required bool idLogin,
    String start = '',
    String end = '',
    String code = '',
    String unit = '',
    String certExpire = '',
    String certUsername = '',
    String certPassword = '',
    required MtsController controller,
  }) async {
    ctrl = controller;
    String idOrCert = idLogin ? 'μ¦κΆμ¬μμ΄λ' : 'κ³΅λμΈμ¦μ';
    try {
      String name = await LoginRequest(
        module,
        idLogin: idLogin,
        userId: userId,
        password: password,
        certExpire: certExpire,
        certPassword: certPassword,
        subjectDn: certUsername,
        username: username,
        idOrCert: idOrCert,
        pinNum: passNum,
      ).post();
      username = name;
      await AccountAll(
        module,
        password: passNum,
        username: username,
        idOrCert: idOrCert,
      ).post();
      await AccountStocks(
        module,
        username,
        idOrCert,
      ).post();
      for (Account acc in ctrl!.accounts) {
        await AccountDetail(
          module,
          accountNum: acc.accountNum,
          accountPin: passNum,
          queryCode: code,
          showISO: unit,
          username: username,
          idOrCert: idOrCert,
        ).post();
      }
      for (Account acc in ctrl!.accounts) {
        await AccountTransaction(
          module,
          accountNum: acc.accountNum,
          accountPin: passNum,
          accountExt: '',
          accountType: '01',
          queryCode: '1',
          username: username,
          idOrCert: idOrCert,
        ).post();
      }
    } catch (err, trc) {
      FirebaseCrashlytics.instance.recordError(err, trc);
    } finally {
      await LogoutRequest(
        module,
        username,
        idOrCert,
      ).post();
    }
  }

  Future<String?> getTwelveDigits() async {
    try {
      return await channel.invokeMethod('getTwelveDigits');
    } catch (e) {
      e.printError();
      return null;
    }
  }

  Future<bool> checkImport() async {
    return await channel.invokeMethod('checkIfImported') as bool;
  }

  Future<Set<RKSWCertItem>> loadCertificationList() async {
    Set<RKSWCertItem> list = {};
    List<dynamic>? response = await channel.invokeListMethod('loadCertList');
    print(response);
    if (response != null) {
      for (Map<Object?, Object?> json
          in response as List<Map<Object?, Object?>>) {
        RKSWCertItem item = RKSWCertItem.from(json);
        list.add(item);
      }
    }
    return list;
  }

  Future<void> emptyCerts() async {
    await channel.invokeMethod('emptyCertifications');
  }

  Future<void> changePasswordOfCert(
      String oldPassword, String newPassword, String certName) async {
    await channel.invokeMethod('changePassword', {
      'newPassword': newPassword,
      'oldPassword': oldPassword,
      'certName': certName,
    });
  }

  Future<void> deleteCert(String certName) async {
    await channel.invokeMethod('deleteCertification', certName);
  }
}
