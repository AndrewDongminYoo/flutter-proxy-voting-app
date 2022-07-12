// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../contact_us/contact_us.model.dart';
import '../notification/notification.dart';
import '../shared/custom_nav.dart';
import '../utils/shared_prefs.dart';
import 'auth.dart';

class AuthController extends GetxController {
  User? _user;
  List<Chat> chats = [];
  bool isLogined = false;
  final AuthService _service = AuthService();

  NotificationController notificaitionCtrl =
      Get.isRegistered<NotificationController>()
          ? Get.find()
          : Get.put(NotificationController());

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
    final telNum = await getTelephoneNumber();
    if (telNum.isNotEmpty) {
      debugPrint('[AuthController] SharedPreferences exist');
      final result = await getUserInfo(telNum);
      if (result == null) {
        // 잘못된 캐시데이터 삭제
        debugPrint('[AuthController] delete useless SharedPreferences');
        await clearPref();
      } else {
        signIn();
      }
    }
  }

  // 서버에서 사용자 데이터 불러오기
  Future<User?> getUserInfo(String telNum) async {
    Response response = await _service.getUserByTelNum(telNum);
    if (kDebugMode) {
      debugPrint('[AuthController] getUserInfo: ${response.body}');
    }
    if (response.isOk && response.body != null && !response.body['isNew']) {
      user = User.fromJson(response.body['user']);
      debugPrint('[AuthController] user exist.\n Hello, ${user.username}!');
      return user;
    }
    return null;
  }

  // 회원가입
  Future<Response> signUp() async {
    Response response = await _service.createUser(user.username, user.frontId,
        user.backId, user.telecom, user.phoneNumber, user.ci, user.di);
    debugPrint(response.bodyString);
    isLogined = true;
    return response;
  }

  // 로그인
  // 사용자 데이터는 이미 초기화시 진행되었고, 인증번호까지 진행하여 로그인 여부 확정
  void signIn() async => isLogined = true;

  bool canVote() => isLogined;

  Future<void> getOtpCode(
    dynamic user,
  ) async {
    // Super User for apple QA
    if (user.phoneNumber == '01086199325' && user.frontId == '940701') {
      user = getUserInfo(user.phoneNumber);
      debugPrint('super user for apple QA');
      return;
    }

    await _service.getOtpCode(user.username, user.frontId, user.backId,
        user.telecom, user.phoneNumber);
  }

  Future<void> validateOtpCode(String telNum, String otpCode) async {
    startLoading();
    // Super User for apple QA
    if (telNum == '01086199325' && otpCode == '210913') {
      signIn();
      stopLoading();
      return;
    }

    await _service.putPassCode(telNum, otpCode);
    const duration = Duration(seconds: 3);
    await Future.delayed(duration, () async {
      var response = await _service.getResult(telNum);
      debugPrint(response.bodyString);
      var exc = 'ValidationException';
      if (response.body['errorType'] == exc ||
          response.body['verified'] != true) {
        stopLoading();
        _user = null;
        throw Exception('잘못된 인증번호입니다. 전화번호를 확인하세요.');
      } else {
        user.ci = response.body['ci'] ?? '';
        user.di = response.body['di'] ?? '';
        if (user.ci.isEmpty || user.di.isEmpty) {
          throw Exception('잘못된 개인고유부호입니다.');
        }
        // Annoymous User's id is -1.
        if (user.id >= 0) {
          signIn();
        } else {
          signUp();
        }
        putUuid();
        setTelephoneNumber(user.phoneNumber);
        stopLoading();
      }
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

    _service.postMessage(user.phoneNumber, newChat);
    update();
  }

  Future<void> getChat() async {
    chats = await _service.getMessage(user.phoneNumber);
  }

  void putBackId(String backId) async {
    await _service.putBackId(user.id, backId);
  }

  // FIXME: user의 id값이 -1로 덮어 쓰이는 현상이 있음
  void putUuid() async {
    await _service.putUuid(60, notificaitionCtrl.token);
  }

  void startLoading() {
    Get.dialog(LoadingScreen());
  }

  void stopLoading() {
    if (Get.isDialogOpen == true) {
      goBack();
    }
  }

  void printWarning(String text) {
    debugPrint('\x1B[33m$text\x1B[0m');
  }
}
