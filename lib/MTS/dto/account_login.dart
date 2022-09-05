// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../mts.dart';

class LoginRequest implements MTSInterface {
  LoginRequest(
    this.module, {
    this.idLogin = true,
    required this.userId,
    required this.password,
    required this.certExpire,
    required this.certPrivate,
    required this.certPublic,
    this.certUsername = '',
    this.certPassword = '',
  });

  final CustomModule module; // 금융사
  final String job = '로그인';
  final bool idLogin;
  late String userId;
  final String password;
  final String certPassword;
  final String certUsername;
  final String certExpire;
  final String certPrivate;
  final String certPublic;

  @override
  CustomRequest get json {
    if (idLogin) {
      // 아이디로그인
      return makeFunction(
        module,
        job, // '로그인'
        idLogin: idLogin,
        userId: userId, // 사용자아이디 예: hkd01234
        password: password, // 사용자비밀번호 예: qwer1234!
      )!;
    } else {
      // 인증서로그인
      return makeFunction(
        module,
        job, // '로그인'
        idLogin: idLogin,
        userId: userId, // IBK, KTB 필수 입력
        password: password, // IBK, KTB 필수 입력
        certExpire: certExpire, // 만료일자 예: 20161210
        certUsername: certUsername, // 인증서이름 예: cn=홍길동()000...
        certPassword: certPassword, // 인증서비밀번호 예: qwer1234!
        certPublic: certPublic,
        certPrivate: certPrivate,
      )!;
    }
  }

  @override
  Future<CustomResponse> fetch(String username) async {
    return await json.fetch(username);
  }

  @override
  Future<String> post(String username) async {
    CustomResponse response = await fetch(username);
    if (username.isEmpty) {
      username = response.Output.Result.userId;
    }
    response.fetch(username);
    response.Output.Result.json.forEach((key, value) {
      print('$key: $value');
      addResult('$key: $value');
    });
    return username;
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();

  @override
  addResult(String value) {
    bool valueIsNotLast =
        controller.texts.isNotEmpty && controller.texts.last.data != value;
    if ((valueIsNotLast) || (controller.texts.isEmpty)) {
      controller.texts.add(Text(value));
    }
  }
}
