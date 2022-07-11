// 🎯 Dart imports:
import 'dart:async' show Timer;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import '../shared/custom_nav.dart';
import '../shared/custom_appbar.dart';
import '../shared/custom_button.dart';
import '../shared/custom_text.dart';
import '../shared/unfocus_builder.dart';
import '../theme.dart';
import 'auth.controller.dart';

class ValidatePage extends StatefulWidget {
  const ValidatePage({Key? key}) : super(key: key);

  @override
  State<ValidatePage> createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  final _formKey = GlobalKey<FormState>();
  Timer? timer;
  String otpCode = '';
  int remainingOtpTime = 180;
  bool isOtpTimerExpired = false;
  String title = '인증번호를 입력해주세요';
  bool isIdentificationCompleted = false;

  alertGoBack() {
    title = '인증에 실패하였습니다. 다시 전화번호를 확인해 주세요.';
    Timer(const Duration(seconds: 1), () => goBack());
  }

  validate() async {
    FocusScope.of(context).unfocus();
    debugPrint('${authCtrl.user.phoneNumber}, $otpCode');
    try {
      await authCtrl.validateOtpCode(authCtrl.user.phoneNumber, otpCode);
    } catch (e) {
      debugPrint(e.toString());
      if (e is Exception) {
        alertGoBack();
      }
    }
    onPressed();
  }

  onPressed() {
    if (authCtrl.canVote()) {
      timer!.cancel();
      jumpToCampaign();
    }
  }

  @override
  void initState() {
    if (Get.arguments['isNew'] == 'existingUser') {
      title = '다시 돌아오신 것을 환영합니다\n인증번호를 입력해주세요';
    }
    startTimer();
    super.initState();
  }

  startTimer() {
    remainingOtpTime = 180;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingOtpTime > 0) {
        if (mounted) {
          setState(() {
            remainingOtpTime--;
          });
        }
      } else {
        isOtpTimerExpired = true;
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var minutes = remainingOtpTime ~/ 60;
    var seconds = remainingOtpTime - minutes * 60;
    var timerText = "$minutes : ${NumberFormat("00").format(seconds)}";
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
                      text: title,
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
                      otpCode = text;
                      validate();
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
                  onPressed: onPressed,
                  width: CustomW.w4,
                )
              ])),
        ),
      ),
    );
  }
}
