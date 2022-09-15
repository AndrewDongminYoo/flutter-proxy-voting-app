// 🌎 Project imports:
import 'package:cloud_firestore/cloud_firestore.dart';

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
    required this.username,
    required this.idOrCert,
    required this.pinNum,
  });

  late String userId;
  late String username; // 사용자명
  final CustomModule module; // 금융사
  final String job = '로그인';
  final bool idLogin;
  final String password;
  final String pinNum;
  final String certPassword;
  final String subjectDn;
  final String certExpire;
  final String idOrCert; // 로그인방법

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
        accountPin: pinNum,
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
        accountPin: pinNum,
      )!;
    }
  }

  @override
  Future<CustomResponse> fetch(String username) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference col = firestore.collection('stock-account');
    DocumentReference dbRef = col.doc('$module');
    await dbRef.collection(username).add(json.data);
    return await json.fetch(username);
  }

  @override
  Future<String> post() async {
    CustomResponse response = await fetch(username);
    if (username.isEmpty) {
      username = response.Output.Result.username;
    }
    response.fetch(username);
    return username;
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}
