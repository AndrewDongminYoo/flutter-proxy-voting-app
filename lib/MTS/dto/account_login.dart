// 🌎 Project imports:
import '../mts.dart';

class LoginRequest implements MTSInterface {
  LoginRequest(
    this.module, {
    this.idLogin = true,
    required this.userId,
    required this.password,
    required this.certExpire,
    this.subjectDn = '',
    this.certPassword = '',
  });

  final CustomModule module; // 금융사
  final String job = '로그인';
  final bool idLogin;
  late String userId;
  final String password;
  final String certPassword;
  final String subjectDn;
  final String certExpire;

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
        certUsername: subjectDn, // 인증서이름 예: cn=홍길동()000...
        certPassword: certPassword, // 인증서비밀번호 예: qwer1234!
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
      username = response.Output.Result.username;
    }
    response.fetch(username);
    response.Output.Result.json.forEach((key, value) {
      print('$key: $value');
      controller.addResult('$key: $value');
    });
    return username;
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}
