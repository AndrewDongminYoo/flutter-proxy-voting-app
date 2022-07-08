// 🎯 Dart imports:
import 'dart:convert' show jsonEncode;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get_connect.dart';

// 🌎 Project imports:
import '../contact_us/contact_us.model.dart';
import 'auth.data.dart';

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
  Future<Response> getOtpCode(
    String name,
    String birth,
    String backId,
    String telecom,
    String telNum,
  ) {
    /// 'SKT':01, 'KT':02, 'LG U+':03, 'SKT 알뜰폰':04, 'KT 알뜰폰':05, 'LG U+ 알뜰폰':06
    final telecomCode = setTelecom(telecom);

    /// birth: 8자리 ex) 19900110
    final registCode =
        birth.startsWith(RegExp('[0-1]')) ? '20$birth' : '19$birth';

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

  String setTelecom(telecom) {
    switch (telecom) {
      case 'SKT':
        return '01';
      case 'KT':
        return '02';
      case 'LG U+':
        return '03';
      case 'SKT 알뜰폰':
        return '04';
      case 'KT 알뜰폰':
        return '05';
      case 'LG U+ 알뜰폰':
        return '06';
      default:
        return '00';
    }
  }

  Future<Response> putPassCode(String telNum, String otpNo) {
    return put(lambdaURL, jsonEncode({'telNum': telNum, 'otpNo': otpNo}));
  }

  /// postPassCode는 putPassCode 호출 이후 3초 뒤에 호출 권장
  Future<Response> getResult(String telNum) {
    return post(lambdaResultURL, jsonEncode({'telNum': telNum}));
  }

  Future<Response> createUser(String name, String frontId, String backId,
      String telecom, String phoneNumber, String ci, String di) async {
    final user = User(
      name,
      frontId,
      backId,
      telecom,
      phoneNumber,
    );
    return post(
        getURL('/users'),
        jsonEncode({
          'user': user,
        }));
  }

  Future<Response> putAddress(int uid, String address) async {
    return await put(
        getURL('/users/address'), jsonEncode({'uid': uid, 'address': address}));
  }

  Future<Response> putBackId(int uid, String backId) async {
    return await put(
        getURL('/users/backid'), jsonEncode({'uid': uid, 'backId': backId}));
  }

  Future<Response> putCiDi(int uid, String ci, String di) async {
    return await put(
        getURL('/users/ci'), jsonEncode({'uid': uid, 'ci': ci, 'di': di}));
  }

  /// MESSAGE PART
  Future<void> postMessage(String phoneNumber, Chat message) async {
    final contact = <String, dynamic>{
      'message': message.message,
      'myself': message.myself,
      'time': message.time
    };
    await db
        .collection('contacts')
        .doc(phoneNumber)
        .collection('inbox')
        .add(contact);
  }

  Future<List<Chat>> getMessage(String phoneNumber) async {
    List<Chat> ref = [];
    try {
      await db
          .collection('contacts')
          .doc(phoneNumber)
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
}
