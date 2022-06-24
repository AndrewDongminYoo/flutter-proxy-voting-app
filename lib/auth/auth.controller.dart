import 'package:bside/auth/auth.data.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;

import 'auth.service.dart';
import '../shared/loading_screen.dart';

class AuthController extends GetxController {
  final AuthService _service = AuthService();
  
  // User data
  User? user;

  // flags
  bool isLogined = false;
  bool isVerified = false;

  void signUp() {
    isLogined = true;
  }

  void startLoading() {
    Get.dialog(const LoadingScreen());
  }

  void stopLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  Future<void> getUserInfo(String telNum) async {
    // await _service.get
  }

  Future<void> getOtpCode(String name, String frontId, String backId,
      String telecom, String telNum) async {
    await _service.getOtpCode(name, frontId, backId, telecom, telNum);
    user = User(name, frontId, backId, telecom, telNum); 
  }

  Future<void> validateOtpCode(String telNum, String otpCode) async {
    developer.log('validateOtpCode', name: 'service');
    startLoading();
    await _service.putPassCode(telNum, otpCode);
    await Future.delayed(const Duration(seconds: 3), () async {
      var response = await _service.getResult(telNum);
      if (!response.body['verified']) {
        stopLoading();
        // throw Exception('휴대폰 인증 에러');
        return;
      }
      developer.log('response: $response', name: 'service');
      user!.ci = response.body['ci'] ?? '';
      user!.di = response.body['di'] ?? '';
      if (user!.ci.isEmpty) {
        throw Exception('휴대폰 인증 에러');
      }
      isVerified = true;
      signUp();
      stopLoading();
    });
  }
}
