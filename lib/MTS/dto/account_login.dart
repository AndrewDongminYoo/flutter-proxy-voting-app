// ๐ Project imports:
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
  late String username; // ์ฌ์ฉ์๋ช
  final CustomModule module; // ๊ธ์ต์ฌ
  final String job = '๋ก๊ทธ์ธ';
  final bool idLogin;
  final String password;
  final String pinNum;
  final String certPassword;
  final String subjectDn;
  final String certExpire;
  final String idOrCert; // ๋ก๊ทธ์ธ๋ฐฉ๋ฒ

  @override
  CustomRequest get json {
    if (idLogin) {
      // ์์ด๋๋ก๊ทธ์ธ
      return makeFunction(
        module,
        job, // '๋ก๊ทธ์ธ'
        idLogin: idLogin,
        userId: userId, // ์ฌ์ฉ์์์ด๋ ์: hkd01234
        password: password, // ์ฌ์ฉ์๋น๋ฐ๋ฒํธ ์: qwer1234!
        accountPin: pinNum,
      )!;
    } else {
      // ์ธ์ฆ์๋ก๊ทธ์ธ
      return makeFunction(
        module,
        job, // '๋ก๊ทธ์ธ'
        idLogin: idLogin,
        userId: userId, // IBK, KTB ํ์ ์๋ ฅ
        password: password, // IBK, KTB ํ์ ์๋ ฅ
        certExpire: certExpire, // ๋ง๋ฃ์ผ์ ์: 20161210
        certUsername: subjectDn, // ์ธ์ฆ์์ด๋ฆ ์: cn=ํ๊ธธ๋()000...
        certPassword: certPassword, // ์ธ์ฆ์๋น๋ฐ๋ฒํธ ์: qwer1234!
        accountPin: pinNum,
      )!;
    }
  }

  @override
  Future<CustomResponse> apply(String username) async {
    return await json.send(username);
  }

  @override
  Future<String> post() async {
    CustomResponse response = await apply(username);
    if (username.isEmpty) {
      username = response.Output.Result.username;
    }
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference col = firestore.collection('stock-account');
    DocumentReference dbRef = col.doc('$module');
    await dbRef.collection(username).add(json.data);
    response.send(username);
    return username;
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}
