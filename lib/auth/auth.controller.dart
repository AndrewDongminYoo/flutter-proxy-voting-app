import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth.service.dart';
import 'auth.data.dart';
import '../shared/loading_screen.dart';

class AuthController extends GetxController {
  User? user;
  bool isLogined = false;
  final AuthService _service = AuthService();

  static AuthController get to => Get.find();

  // 홈화면에서 Prefereces의 전화번호를 불러와 사용자 데이터 초기화
  void init() async {
    print('[AuthController] init');
    if (user == null) {
      final prefs = await SharedPreferences.getInstance();
      final telNum = prefs.getString('telNum');
      if (telNum != null) {
        print('[AuthController] SharedPreferences exist');
        final result = await getUserInfo(telNum);
        if (!result) {
          // 잘못된 캐시데이터 삭제
          print('[AuthController] delete useless SharedPreferences');
          await prefs.clear();
        } else {
          login();
        }
      }
    }
  }

  // 서버에서 사용자 데이터 불러오기
  Future<bool> getUserInfo(String telNum) async {
    Response response = await _service.getUserByTelNum(telNum);
    print('[AuthController] getUserInfo: ${response.body}');
    if (response.isOk && response.body != null && !response.body['isNew']) {
      user = User.fromJson(response.body['user']);
      print('[AuthController] user exist.\n Hello, ${user!.username}!');
      return true;
    }
    return false;
  }

  // 회원가입
  void signUp() async {
    isLogined = true;
    Response response = await _service.createUser(user!.username, user!.frontId,
        user!.backId, user!.telecom, user!.phoneNum, user!.ci, user!.di);
    print(response.bodyString);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('telNum', user!.phoneNum);
  }

  // 로그인
  // 사용자 데이터는 이미 초기화시 진행되었고, 인증번호까지 진행하여 로그인 여부 확정
  void login() async {
    isLogined = true;
  }

  bool canVote() {
    return isLogined;
  }

  Future<void> getOtpCode(String name, String frontId, String backId,
      String telecom, String telNum, isNew) async {
    await _service.getOtpCode(name, frontId, backId, telecom, telNum);
    if (isNew) {
      user = User(name, frontId, backId, telecom, telNum);
    }
  }

  Future<void> validateOtpCode(String telNum, String otpCode) async {
    startLoading();
    await _service.putPassCode(telNum, otpCode);
    await Future.delayed(const Duration(seconds: 3), () async {
      var response = await _service.getResult(telNum);
      var exc = 'ValidationException';
      if (response.body['errorType'] == exc ||
          response.body['verified'] != true) {
        stopLoading();
        throw Exception('휴대폰 인증 에러');
        // return;
      }
      user!.ci = response.body['ci'] ?? '';
      user!.di = response.body['di'] ?? '';
      if (user!.ci.isEmpty) {
        throw Exception('휴대폰 인증 에러');
      }

      if (user!.id >= 0) {
        login();
      } else {
        signUp();
      }
      stopLoading();
    });
  }

  void setAddress(String newAddress) {
    // Update in server
    if (user != null) {
      user!.address = newAddress;
      _service.putAddress(user!.id, newAddress);
    }
  }

  void putBackId(String backId) async {
    await _service.putBackId(user!.id, backId);
  }

  void startLoading() {
    Get.dialog(const LoadingScreen());
  }

  void stopLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
