import 'dart:convert';

import 'package:get/get_connect.dart';

class AuthService extends GetConnect {
  String lambdaURL =
      "https://uu6ro1ddc7.execute-api.ap-northeast-2.amazonaws.com/v1/identification";
  String lambdaResultURL =
      'https://uu6ro1ddc7.execute-api.ap-northeast-2.amazonaws.com/v1/mobile-identification-result';

  /// 본인인증:
  /// birth: 8자리 ex) 19900110
  /// sex: 남: 1, 여: 2
  /// telecom: 'SKT':01, 'KT':02, 'LG U+':03, 'SKT알뜰폰':04, 'KT알뜰폰':05, 'LG알뜰폰':06
  Future<Response> getOtpCode(
      String name, String birth, String sex, String telecom, String telNum) {
    String telecomCode = "";
    switch (telecom) {
      case "SKT":
        telecomCode = "01";
        break;
      case "KT":
        telecomCode = "02";
        break;
      case "LG U+":
        telecomCode = "03";
        break;
      case "SKT알뜰폰":
        telecomCode = "04";
        break;
      case "KT알뜰폰":
        telecomCode = "05";
        break;
      case "LG알뜰폰":
        telecomCode = "06";
        break;
    }
    final registCode = birth.startsWith('0') ? '20$birth' : '19$birth';
    final sexCode = sex.startsWith('1') || sex.startsWith('3') ? 1 : 2;
    return post(
        lambdaURL,
        jsonEncode({
          'name': name,
          'birth': registCode,
          'sex': sexCode,
          'telecom': telecomCode,
          'telNum': telNum
        }));
  }

  Future<Response> putPassCode(String telNum, String otpNo) {
    return put(lambdaURL, jsonEncode({'telNum': telNum, 'otpNo': otpNo}));
  }

  /// postPassCode는 putPassCode 호출 이후 3초 뒤에 호출 권장
  Future<Response> getResult(String telNum) {
    return post(lambdaResultURL, jsonEncode({'telNum': telNum}));
  }
}