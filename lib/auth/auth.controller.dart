import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.service.dart';
import 'auth.data.dart';
import '../shared/loading_screen.dart';

class AuthController extends GetxController {
  final AuthService _service = AuthService();

  // User data
  User? user;

  // flags
  bool isLogined = false;

  void init() async {
    print('init authController');
    if (user == null) {
      final prefs = await SharedPreferences.getInstance();
      final phoneNum = prefs.getString('phoneNum');
      print('phoneNum: $phoneNum');
      if (phoneNum != null) {
        isLogined = true;
        await getUserInfo(phoneNum);
      }
    }
  }

  void signUp() async {
    isLogined = true;
    var response = await _service.createUser(user!.username, user!.frontId,
        user!.backId, user!.telecom, user!.phoneNum, user!.ci, user!.di);
    print(response.bodyString);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNum', user!.phoneNum);
  }

  bool canVote() {
    return isLogined;
  }

  void startLoading() {
    Get.dialog(const LoadingScreen());
  }

  void stopLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  void setAddress(String address) {
    if (user != null) {
      user!.address = address;
    }
  }

  void putBackId(String backId) async {
    await _service.putBackId(user!.id, backId);
  }

  Future<void> getUserInfo(String telNum) async {
    Response response = await _service.getUserByTelNum(telNum);
    print(response.body);
    try {
      if (response.body['user']) {
        print(response);
        user = User.fromJson(response.body['user']);
      }
    } catch (e) {
      e.printError();
    }
  }

  Future<void> getOtpCode(String name, String frontId, String backId,
      String telecom, String telNum) async {
    await _service.getOtpCode(name, frontId, backId, telecom, telNum);
    user = User(name, frontId, backId, telecom, telNum);
  }

  Future<void> validateOtpCode(String telNum, String otpCode) async {
    startLoading();
    await _service.putPassCode(telNum, otpCode);
    await Future.delayed(const Duration(seconds: 3), () async {
      var response = await _service.getResult(telNum);
      if (!response.body['verified']) {
        stopLoading();
        // throw Exception('휴대폰 인증 에러');
        return;
      }
      user!.ci = response.body['ci'] ?? '';
      user!.di = response.body['di'] ?? '';
      if (user!.ci.isEmpty) {
        throw Exception('휴대폰 인증 에러');
      }
      signUp();
      stopLoading();
    });
  }
}
