// 🎯 Dart imports:
import 'dart:async' show Timer;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import '../theme.dart';
import '../utils/exceptions.dart';
import 'auth.controller.dart';

class ValidatePage extends StatefulWidget {
  const ValidatePage({Key? key}) : super(key: key);

  @override
  State<ValidatePage> createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  final AuthController _authCtrl = AuthController.get();
  final _formKey = GlobalKey<FormState>();
  Timer? _timer;
  String _otpCode = '';
  Duration _remainingOtpTime = const Duration(minutes: 3);
  String _title = '인증번호를 입력해주세요';

  @override
  void initState() {
    if (Get.arguments['isNew'] == 'existingUser') {
      _title = '다시 돌아오신 것을 환영합니다\n인증번호를 입력해주세요';
    }
    _startTimer();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel();
    }
    super.dispose();
  }

  _alertGoBack(String exception) {
    Get.bottomSheet(
      confirmBody(exception, '뒤로가기', () => backToSignUp()),
      backgroundColor: Colors.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  _onPressed() {
    setState(() {
      _timer!.cancel();
    });
    if (_authCtrl.canVote) {
      jumpToCampaign();
    }
  }

  _validate() async {
    FocusScope.of(context).unfocus();
    debugPrint('${_authCtrl.user.phoneNumber}, $_otpCode');
    try {
      await _authCtrl.validateOtpCode(_authCtrl.user.phoneNumber, _otpCode);
    } catch (e) {
      debugPrint(e.toString());
      if (e is CustomException) {
        _alertGoBack(e.message);
      }
    }
    _onPressed();
  }

  _startTimer() {
    var seconds = const Duration(seconds: 1);
    _timer = Timer.periodic(seconds, (timer) => _setCountDown());
  }

  _setCountDown() {
    setState(() {
      final seconds = _remainingOtpTime.inSeconds - 1;
      if (seconds < 0) {
        _timer!.cancel();
        _alertGoBack('시간이 초과되었습니다. 전화번호를 다시 입력해주세요.');
      } else {
        _remainingOtpTime = Duration(seconds: seconds);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    var minutes = _remainingOtpTime.inMinutes;
    var seconds = _remainingOtpTime.inSeconds - minutes * 60;
    var timerText = '${strDigits(minutes)} : ${strDigits(seconds)}';
    return Scaffold(
      appBar: CustomAppBar(text: ''),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Unfocused(
          child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(children: [
                const SizedBox(height: 40),
                Align(
                    alignment: Alignment.center,
                    child: CustomText(
                      typoType: TypoType.h1,
                      text: _title,
                    )),
                const SizedBox(height: 40),
                TextFormField(
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return;
                    }
                    return null;
                  },
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '인증번호',
                  ),
                  onChanged: (String text) {
                    if (text.length >= 6) {
                      _otpCode = text;
                      _validate();
                    }
                  },
                ),
                const SizedBox(height: 10),
                Center(
                    child: CustomText(
                  text: timerText,
                  typoType: TypoType.body,
                )),
                const SizedBox(height: 40),
                CustomButton(
                  label: '확인',
                  onPressed: _onPressed,
                  width: CustomW.w4,
                )
              ])),
        ),
      ),
    );
  }
}
