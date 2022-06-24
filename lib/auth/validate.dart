import 'dart:async';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

import 'auth.controller.dart';
import '../shared/unfocused.dart';
import '../shared/custom_grid.dart';
import '../shared/back_button.dart';
import '../shared/custom_text.dart';
import '../shared/custom_button.dart';

class ValidatePage extends StatefulWidget {
  const ValidatePage({Key? key}) : super(key: key);

  @override
  State<ValidatePage> createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  final AuthController _controller = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();
  Timer? timer;
  String otpCode = "";
  int remainingOtpTime = 180;
  bool isOtpTimerExpired = false;
  bool isIdentificationCompleted = false;

  validate(String text) async {
    FocusScope.of(context).unfocus();
    await _controller.validateOtpCode(_controller.user!.phoneNum, text);
    if (_controller.isVerified) {
      timer!.cancel();
      Get.offNamedUntil('/campaign', (route) => route.settings.name == '/');
    }
  }

  onPressed() {
    if (_controller.isVerified) {
      timer!.cancel();
      Get.offNamedUntil('/campaign', (route) => route.settings.name == '/');
    }
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() {
    remainingOtpTime = 180;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingOtpTime > 0) {
        setState(() {
          remainingOtpTime--;
        });
      } else {
        isOtpTimerExpired = true;
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5E3F74),
        elevation: 0,
        leading: const CustomBackButton(),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Unfocused(
          child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(children: [
                const SizedBox(height: 40),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: CustomText(
                      typoType: TypoType.h1,
                      text: '인증번호를 입력해주세요',
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
                      border: OutlineInputBorder(), labelText: '인증번호'),
                  onChanged: (String text) {
                    if (text.length >= 6) {
                      otpCode = text;
                      validate(text);
                    }
                  },
                ),
                const SizedBox(height: 10),
                Center(
                    child: CustomText(
                  text:
                      "${remainingOtpTime ~/ 60} : ${intl.NumberFormat("00").format(remainingOtpTime - (remainingOtpTime ~/ 60) * 60)}",
                  typoType: TypoType.body,
                )),
                const SizedBox(height: 40),
                CustomButton(
                    label: '확인', onPressed: onPressed, width: CustomW.w4)
              ])),
        ),
      ),
    );
  }
}
