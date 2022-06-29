import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../shared/loading_screen.dart' show LoadingScreen;
import 'auth.service.dart' show AuthService;
import 'auth.data.dart' show User;
import 'package:get/get.dart';
import '../chatting/chatting.model.dart';

class AuthController extends GetxController {
  User? _user;

  User get user {
    if (_user != null) {
      return _user!;
    }
    init();
    if (_user != null) {
      printWarning('[AuthController] User is now ${_user!.username}');
      return _user!;
    }
    printWarning('=========== WARNING =============');
    printWarning('[AuthController] User is now annonymous');
    printWarning('=========== WARNING =============');
    return User('Annonymous', '000000', '0', 'SKT', '01012345678');
  }

  set user(User? user) {
    _user = user;
  }

  @override
  void onInit() {
    super.onInit();
    printWarning('[AuthController] onInit');
    init();
  }

  bool isLogined = false;
  final AuthService _service = AuthService();

  List<Chat> chats = [
    Chat(
        avatar: 'assets/images/logo.png',
        message: '안녕하세요',
        time: DateTime.now(),
        myself: true),
  ];

  void addChat(String message) {
    final newChat = Chat(
        message: message,
        myself: true,
        time: DateTime.now(),
        avatar: 'assets/images/logo.png');
    chats.add(newChat);
    update();
  }

  // 홈화면에서 Prefereces의 전화번호를 불러와 사용자 데이터 초기화
  void init() async {
    print('[AuthController] init');
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

  // 서버에서 사용자 데이터 불러오기
  Future<bool> getUserInfo(String telNum) async {
    Response response = await _service.getUserByTelNum(telNum);
    if (kDebugMode) {
      print('[AuthController] getUserInfo: ${response.body}');
    }
    if (response.isOk && response.body != null && !response.body['isNew']) {
      user = User.fromJson(response.body['user']);
      print('[AuthController] user exist.\n Hello, ${user.username}!');
      return true;
    }
    return false;
  }

  // 회원가입
  void signUp() async {
    isLogined = true;
    Response response = await _service.createUser(user.username, user.frontId,
        user.backId, user.telecom, user.phoneNum, user.ci, user.di);
    print('${response.bodyString}');
  }

  // 로그인
  // 사용자 데이터는 이미 초기화시 진행되었고, 인증번호까지 진행하여 로그인 여부 확정
  void login() async {
    isLogined = true;
  }

  bool canVote() {
    return isLogined;
  }

  Future<void> getOtpCode(
    String name,
    String frontId,
    String backId,
    String telecom,
    String telNum,
    bool isNewAcc,
  ) async {
    await _service.getOtpCode(name, frontId, backId, telecom, telNum);
    if (isNewAcc) {
      // FIXME: 사용자가 인증번호까지 완료해야 user 생성 필요
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
    print('\x1B[33m$text\x1B[0m');
  }
}
