import 'package:bside/mts/mts_functions.dart';

import '../mts_interface.dart';

class LoginRequest implements MTSInterface {
  const LoginRequest(
    this.module, {
    this.idLogin = true,
    required this.username,
    required this.password,
    required this.certExpire,
    this.certUsername = '',
    this.certPassword = '',
  });

  final String module; // 금융사
  final String job = '로그인';
  final bool idLogin;
  final String username;
  final String password;
  final String certPassword;
  final String certUsername;
  final String certExpire;

  @override
  toDictionary() {
    if (idLogin) {
      // 아이디로그인
      return makeFunction(
        module,
        job, // '로그인'
        idLogin: idLogin,
        username: username, // 사용자아이디 예: hkd01234
        password: password, // 사용자비밀번호 예: qwer1234!
      );
    } else {
      // 인증서로그인
      return makeFunction(
        module,
        job, // '로그인'
        idLogin: idLogin,
        username: username, // IBK, KTB 필수 입력
        password: password, // IBK, KTB 필수 입력
        certExpire: certExpire, // 만료일자 예: 20161210
        certUsername: certUsername, // 인증서이름 예: cn=홍길동()000...
        certPassword: certPassword, // 인증서비밀번호 예: qwer1234!
      );
    }
  }
}
