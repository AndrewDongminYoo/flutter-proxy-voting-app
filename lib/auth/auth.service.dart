// 🎯 Dart imports:
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_connect.dart';

// 🌎 Project imports:
import '../contact_us/contact_us.model.dart';

class AuthService extends GetConnect {
  String baseURL = 'https://api.bside.ai/onboarding';
  String getURL(String url) => baseURL + url;
  Future<Response> getUserByTelNum(String telNum) =>
      get(getURL('/users?phoneNumber=$telNum'));

  String lambdaURL =
      'https://uu6ro1ddc7.execute-api.ap-northeast-2.amazonaws.com/v1/identification';
  String lambdaResultURL =
      'https://uu6ro1ddc7.execute-api.ap-northeast-2.amazonaws.com/v1/mobile-identification-result';

  FirebaseFirestore db = FirebaseFirestore.instance;

  /// 본인인증:
  /// telecom: 'SKT':01, 'KT':02, 'LG U+':03, 'SKT 알뜰폰':04, 'KT 알뜰폰':05, 'LG U+ 알뜰폰':06
  Future<Response> getOtpCode(
      String name, String birth, String backId, String telecom, String telNum) {
    String telecomCode = '';
    switch (telecom) {
      case 'SKT':
        telecomCode = '01';
        break;
      case 'KT':
        telecomCode = '02';
        break;
      case 'LG U+':
        telecomCode = '03';
        break;
      case 'SKT 알뜰폰':
        telecomCode = '04';
        break;
      case 'KT 알뜰폰':
        telecomCode = '05';
        break;
      case 'LG U+ 알뜰폰':
        telecomCode = '06';
        break;
    }

    /// birth: 8자리 ex) 19900110
    final registCode = birth.startsWith('0') ? '20$birth' : '19$birth';

    /// sex: 남: 1, 여: 2
    final sexCode = backId.startsWith('2') || backId.startsWith('4') ? 2 : 1;
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

  Future<Response> createUser(String name, String frontId, String backId,
      String telecom, String phoneNumber, String ci, String di) {
    return post(
        getURL('/users'),
        jsonEncode({
          'user': {
            'name': name,
            'frontId': frontId,
            'backId': backId,
            'telecom': telecom,
            'phoneNumber': phoneNumber,
            'ci': ci,
            'di': di
          }
        }));
  }

  Future<void> postMessage(String phoneNum, Chat message) async {
    final contact = <String, dynamic>{
      'message': message.message,
      'myself': message.myself,
      'time': message.time
    };
    await db
        .collection('contacts')
        .doc(phoneNum)
        .collection('inbox')
        .add(contact);
  }

  Future<List<Chat>> getMessage(String phoneNum) async {
    List<Chat> ref = [];
    try {
      await db
          .collection('contacts')
          .doc(phoneNum)
          .collection('inbox')
          .orderBy('time', descending: false)
          .get()
          .then((event) {
        for (var doc in event.docs) {
          ref.add(Chat.fromFireStore(doc));
        }
      });
    } catch (err) {
      debugPrint(err.toString());
    }
    return ref;
  }

  Future<Response> putAddress(int uid, String address) {
    return put(
        getURL('/users/address'), jsonEncode({'uid': uid, 'address': address}));
  }

  Future<Response> putBackId(int uid, String backId) {
    return put(
        getURL('/users/backid'), jsonEncode({'uid': uid, 'backId': backId}));
  }

  Future<Response> putCiDi(int uid, String ci, String di) {
    return put(
        getURL('/users/ci'), jsonEncode({'uid': uid, 'ci': ci, 'di': di}));
  }
}
