// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import '../contact_us/contact_us.model.dart';
import '../shared/loading_screen.dart' show LoadingScreen;
import 'auth.data.dart' show User;
import 'auth.service.dart' show AuthService;

class AuthController extends GetxController {
  User? _user;
  List<Chat> chats = [];
  bool isLogined = false;
  final AuthService _service = AuthService();

  User get user {
    if (_user != null) {
      return _user!;
    }
    printWarning('=========== WARNING =============');
    printWarning('[AuthController] User is now annonymous');
    printWarning('=========== WARNING =============');
    return User('Annonymous', '000000', '0', 'SKT', '01012345678');
  }

  set user(User? user) => _user = user;

  // 홈화면에서 Prefereces의 전화번호를 불러와 사용자 데이터 초기화
  void init() async {
    debugPrint('[AuthController] init');
    final prefs = await SharedPreferences.getInstance();
    final telNum = prefs.getString('telNum');
    if (telNum != null) {
      debugPrint('[AuthController] SharedPreferences exist');
      final result = await getUserInfo(telNum);
      if (!result) {
        // 잘못된 캐시데이터 삭제
        debugPrint('[AuthController] delete useless SharedPreferences');
        await prefs.clear();
      } else {
        login();
      }
    }
  }

  // 서버에서 사용자 데이터 불러오기
  Future<bool> getUserInfo(String telNum) async {
    Response response = await _service.getUserByTelNum(telNum);
    if (kDebugMode) {
      debugPrint('[AuthController] getUserInfo: ${response.body}');
    }
    if (response.isOk && response.body != null && !response.body['isNew']) {
      user = User.fromJson(response.body['user']);
      debugPrint('[AuthController] user exist.\n Hello, ${user.username}!');
      return true;
    }
    return false;
  }

  // 회원가입
  void signUp() async {
    Response response = await _service.createUser(user.username, user.frontId,
        user.backId, user.telecom, user.phoneNum, user.ci, user.di);
    debugPrint(response.bodyString);
    isLogined = true;
  }

  // 로그인
  // 사용자 데이터는 이미 초기화시 진행되었고, 인증번호까지 진행하여 로그인 여부 확정
  void login() async => isLogined = true;

  bool canVote() => isLogined;

  Future<void> getOtpCode(
    String name,
    String frontId,
    String backId,
    String telecom,
    String telNum,
    bool isNewAcc,
  ) async {
    // Super User for apple QA
    if (telNum == '01086199325' && frontId == '940701') {
      user = User('소재우', '940701', '1', 'SKT', '01086199325');
      return;
    }

    await _service.getOtpCode(name, frontId, backId, telecom, telNum);
    if (isNewAcc) {
      // FIXME: 사용자가 인증번호까지 완료해야 user 생성 필요
      user = User(name, frontId, backId, telecom, telNum);
      user.id = 51;
    }
  }

  Future<void> validateOtpCode(String telNum, String otpCode) async {
    startLoading();
    // Super User for apple QA
    if (telNum == '01086199325' && otpCode == '210913') {
      login();
      stopLoading();
      return;
    }

    await _service.putPassCode(telNum, otpCode);
    const duration = Duration(seconds: 3);
    await Future.delayed(duration, () async {
      var response = await _service.getResult(telNum);
      var exc = 'ValidationException';
      if (response.body['errorType'] == exc ||
          response.body['verified'] != true) {
        // FIXME: 사용자에게 인증번호가 틀렸거나 개인정보가 틀렸다고 알려주어야 함
        stopLoading();
        return exc;
      }
      user.ci = response.body['ci'] ?? '';
      user.di = response.body['di'] ?? '';
      if (user.ci.isEmpty || user.di.isEmpty) {
        throw Exception('휴대폰 인증 에러');
      }

      if (user.id >= 0) {
        login();
      } else {
        signUp();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('telNum', user.phoneNum);
      stopLoading();
    });
  }

  void setAddress(String newAddress) {
    // Update in server
    user.address = newAddress;
    _service.putAddress(user.id, newAddress);
  }

  void contactUs(String message) {
    final newChat = Chat(
      message: message,
      myself: true,
      time: DateTime.now(),
    );
    chats.add(newChat);

    _service.postMessage(user.phoneNum, newChat);
    update();
  }

  Future<void> getChat() async {
    chats = await _service.getMessage(user.phoneNum);
  }

  void putBackId(String backId) async {
    await _service.putBackId(user.id, backId);
  }

  void startLoading() {
    Get.dialog(const LoadingScreen());
  }

  void stopLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  void printWarning(String text) {
    debugPrint('\x1B[33m$text\x1B[0m');
  }
}
