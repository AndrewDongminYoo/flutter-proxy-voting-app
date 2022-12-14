// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:get/get_connect/connect.dart' show Response;
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/state_manager.dart' show Get, GetxController;

// 🌎 Project imports:
import '../shared/shared.dart';
import '../utils/utils.dart';
import 'auth.dart';

class AuthController extends GetxController {
  static AuthController get() => Get.isRegistered<AuthController>()
      ? Get.find<AuthController>()
      : Get.put(AuthController());

  User? _user;
  bool _isLogined = false;
  bool get canVote => _isLogined;
  final AuthService _service = AuthService();

  User get user {
    if (_user != null) {
      return _user!;
    }
    print('============== WARNING ================');
    print('[AuthController] User is now annonymous');
    print('============== WARNING ================');
    return User('Annonymous', '000000', '0', 'SKT', '01012345678');
  }

  set user(User? user) => _user = user;

  // 홈화면에서 Prefereces의 전화번호를 불러와 사용자 데이터 초기화
  void init() async {
    print('[AuthController] init');
    final String telNum = await Storage.getTelNum();
    if (telNum.isNotEmpty) {
      print('[AuthController] Yor left the phoneNumber.');
      final User? result = await getUserInfo(telNum);
      if (result == null) {
        // 잘못된 캐시데이터 삭제
        print('[AuthController] deleted useless SharedPreferences');
        // NOTE: 사용자가 앱을 재설치할 경우, pref가 없음, 이에 대한 대처 필요
        await Storage.clear();
      } else {
        _signIn();
      }
    }
  }

  // 서버에서 사용자 데이터 불러오기
  Future<User?> getUserInfo(String telNum) async {
    Response<dynamic> response = await _service.getUserByTelNum(telNum);
    if (kDebugMode) {
      print('[AuthController] getUserInfo: ${response.body}');
    }
    if (response.isOk &&
        response.body != null &&
        response.body['isNew'] == false) {
      user = User.fromJson(response.body['user'] as Map<String, dynamic>);
      print('[AuthController] user exist.\n Hello, ${user.username}!');
      return user;
    }
    return user;
  }

  // 회원가입
  Future<Response<dynamic>> _signUp() async {
    print('[AuthController] signUp');
    Response<dynamic> response = await _service.createUser(
        user.username,
        user.frontId,
        user.backId,
        user.telecom,
        user.phoneNumber,
        user.ci,
        user.di);
    print(response.bodyString);
    _isLogined = true;
    return response;
  }

  // 로그인
  // 사용자 데이터는 이미 초기화시 진행되었고, 인증번호까지 진행하여 로그인 여부 확정
  void _signIn() async => _isLogined = true;

  Future<void> getOtpCode(dynamic userLike) async {
    // Super User for apple QA
    if (userLike.phoneNumber == '01086199325' && userLike.frontId == '940701') {
      user = await getUserInfo(userLike._phoneNumber as String);
      print('super user for apple QA');
      return;
    }
    await _service.getOtpCode(user.username, user.regist, user.sexCode,
        user.telecomCode, user.phoneNumber);
  }

  Future<void> validateOtpCode(
      String telNum, String otpCode, String token) async {
    _startLoading();
    // Super User for apple QA
    if (telNum == '01086199325' && otpCode == '210913') {
      _signIn();
      _putUuid(token);
      _stopLoading();
      return;
    }

    await _service.putOtpCode(telNum, otpCode);
    await Future.delayed(const Duration(seconds: 3), () async {
      Response<dynamic> response = await _service.getResult(telNum);
      print(response.bodyString);
      String exc = 'ValidationException';
      if (response.body['errorType'] == exc ||
          response.body['verified'] != true) {
        _stopLoading();
        _user = null;
        throw CustomException('잘못된 인증번호입니다. 전화번호를 확인하세요.');
      } else {
        user.ci = response.body['ci'] as String;
        user.di = response.body['di'] as String;
        if (user.ci.isEmpty || user.di.isEmpty) {
          throw CustomException('인증이 잘못되었습니다. 다시 인증해주시길 바랍니다.');
        }
        // Annoymous User's id is -1.
        if (user.id >= 0) {
          _signIn();
        } else {
          _signUp();
        }
        _putUuid(token);
        await Storage.setTelNum(user.phoneNumber);
        _stopLoading();
      }
    });
  }

  void setAddress(String newAddress) {
    // Update in server
    user.address = newAddress;
    if (user.id >= 0) _service.putAddress(user.id, newAddress);
  }

  // void contactUs(String message) {
  //   final newChat = Chat(
  //     message: message,
  //     myself: true,
  //     time: DateTime.now(),
  //   );
  //   chats.add(newChat);

  //   _service.postMessage(user.phoneNumber, newChat);
  //   update();
  // }

  // Future<List<Chat>> getChat() async {
  //   chats = await _service.getMessage(user.phoneNumber);
  //   return chats;
  // }

  void putBackId(String backId) async {
    if (user.id >= 0) await _service.putBackId(user.id, backId);
  }

  void _putUuid(String token) async {
    if (user.id >= 0) await _service.putUuid(user.id, token);
  }

  void _startLoading() => Get.dialog(LoadingScreen());
  void _stopLoading() => Get.isDialogOpen! ? goBack() : null;
}
