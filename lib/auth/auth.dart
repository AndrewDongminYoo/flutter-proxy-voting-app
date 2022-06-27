import 'dart:math';

import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'widget/term.dart';
import 'auth.controller.dart';
import 'widget/auth_forms.dart';
import '../shared/unfocused.dart';
import '../shared/custom_text.dart';
import '../shared/custom_grid.dart';
import '../shared/custom_appbar.dart';
import '../shared/custom_button.dart';

const headlines = [
  '휴대폰번호를\n입력해주세요',
  '주민번호를\n입력해주세요',
  '통신사를\n선택해주세요',
  '이름을\n입력해주세요',
  '정보를\n확인해주세요'
];

class AuthPage extends StatefulWidget {
  @override
  State<AuthPage> createState() => _AuthPageState();
  const AuthPage({Key? key}) : super(key: key);
}

class _AuthPageState extends State<AuthPage> {
  // controller and nodes
  final nameNode = FocusNode();
  final koreanIdNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final phoneCtrl = TextEditingController();
  final AuthController _authCtrl = Get.find();

  // variables
  int curStep = 0;
  String userName = '';
  String frontId = '';
  String backId = '';
  String telecom = '';
  String phoneNumber = '';
  String header = headlines[0];

  final style = const TextStyle(
    letterSpacing: 2.0,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  @override
  void dispose() {
    super.dispose();
  }

  void onPressed() {
    _authCtrl.getOtpCode(userName, frontId, backId, telecom, phoneNumber);
    Get.toNamed('/validate', arguments: 'newUser');
  }

  skipForExistingUser() {
    Get.toNamed('/validate', arguments: 'existingUser');
  }

  void nextForm(FormStep step, String value) {
    switch (step) {
      case FormStep.phoneNumber:
        final tempPhoneNum = value.replaceAll(' ', '');
        _authCtrl.getUserInfo(tempPhoneNum);
        phoneNumber = tempPhoneNum;
        koreanIdNode.requestFocus();
        break;
      case FormStep.koreanId:
        final valueList = value.split(' ');
        frontId = valueList[0];
        backId = valueList[1];
        if (_authCtrl.user != null && _authCtrl.user!.frontId == frontId) {
          skipForExistingUser();
          return;
        }
        Get.bottomSheet(TelcomModal(nextForm: nextForm),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)));
        break;
      case FormStep.telecom:
        telecom = value;
        phoneCtrl.value = TextEditingValue(text: value);
        nameNode.requestFocus();
        break;
      case FormStep.name:
        userName = value;
        break;
      default:
        break;
    }
    setState(() {
      curStep += 1;
    });
  }

  Widget confirmButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: CustomButton(
        label: '확인',
        onPressed: onPressed,
        width: CustomW.w4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '캠페인', bgColor: Color(0xFFFAFAFA)),
      body: Unfocused(
        child: Form(
          key: _formKey,
          child: FocusScope(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Align(
                      alignment: Alignment.centerLeft,
                      child: CustomText(
                        typoType: TypoType.h1Bold,
                        text: headlines[min(4, curStep)],
                        textAlign: TextAlign.left,
                      )),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                    children: [
                      const SizedBox(height: 60),
                      curStep >= 3
                          ? NameForm(nextForm: nextForm, focusNode: nameNode)
                          : Container(),
                      const SizedBox(height: 40),
                      curStep >= 2
                          ? TelecomForm(
                              nextForm: nextForm,
                              telecom: telecom,
                              phoneCtrl: phoneCtrl)
                          : Container(),
                      const SizedBox(height: 40),
                      curStep >= 1
                          ? KoreanIdForm(
                              nextForm: nextForm, focusNode: koreanIdNode)
                          : Container(),
                      const SizedBox(height: 40),
                      PhoneNumberForm(nextForm: nextForm),
                      const SizedBox(height: 40),
                      curStep >= 4 ? const ServiceTerm() : Container(),
                      curStep >= 4 ? confirmButton() : Container()
                    ],
                  )))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
