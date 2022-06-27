import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'widget/term.dart';
import 'auth.controller.dart';
import '../shared/unfocused.dart';
import '../shared/custom_text.dart';
import '../shared/custom_grid.dart';
import '../shared/custom_color.dart';
import '../shared/custom_appbar.dart';
import '../shared/custom_button.dart';
import '../shared/card_formatter.dart';

const headlines = [
  '휴대폰번호를\n입력해주세요',
  '주민번호를\n입력해주세요',
  '통신사를\n선택해주세요',
  '이름을\n입력해주세요',
  '정보를\n확인해주세요'
];

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final AuthController _authCtrl = Get.find();

  final _focusNodes = List.generate(4, (index) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  int curStep = 0;

  String userName = '';
  String frontBackId = '';
  String telecom = '';
  String phoneNumber = '';

  String header = headlines[0];
  final phoneCtrl = TextEditingController();
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
    final valueList = frontBackId.split(' ');
    _authCtrl.getOtpCode(userName, valueList[0], valueList[1], telecom,
        phoneNumber.replaceAll(' ', ''));
    Get.toNamed('/validate', arguments: 'newUser');
  }

  skipForExistingUser() {
    Get.toNamed('/validate', arguments: 'existingUser');
  }

  void nextStep() {
    switch (curStep) {
      case 0:
        curStep = 1;
        _authCtrl.getUserInfo(phoneNumber.replaceAll(' ', ''));
        _focusNodes[1].requestFocus();
        break;
      case 1:
        curStep = 2;
        final valueList = frontBackId.split(' ');
        if (_authCtrl.user != null && _authCtrl.user!.frontId == valueList[0]) {
          skipForExistingUser();
          return;
        } else {
          Get.bottomSheet(telecomList(),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)));
        }
        break;
      case 2:
        curStep = 3;
        _focusNodes[3].requestFocus();
        break;
      case 3:
        curStep = 4;
        break;
    }
    setState(() {});
  }

  void bottomSheetOpen() {
    Get.bottomSheet(
      telecomList(),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
    curStep += 1;
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

  Widget nameForm() {
    return TextFormField(
      focusNode: _focusNodes[3],
      autofocus: true,
      style: style,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '이름',
      ),
      onChanged: (text) {
        if (text.length >= 2) {
          nextStep();
        }
        userName = text;
      },
    );
  }

  Widget telecomItem(String item) {
    return InkWell(
      onTap: () {
        setState(() {
          telecom = item;
          phoneCtrl.value = TextEditingValue(text: item);
          Get.back();
          nextStep();
        });
      },
      child: Container(
        width: customW[CustomW.w4],
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: CustomText(
          typoType: TypoType.h1Bold,
          text: item,
          colorType: ColorType.grey,
        ),
      ),
    );
  }

  Widget telecomList() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          Container(
            height: 6,
            width: 50,
            decoration: const BoxDecoration(
              color: Color(0xFFEEEDEF),
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const CustomText(
            typoType: TypoType.h1Bold,
            text: '통신사 선택',
          ),
          const SizedBox(height: 30),
          telecomItem('SKT'),
          telecomItem('KT'),
          telecomItem('LG U+'),
          telecomItem('SKT 알뜰폰'),
          telecomItem('KT 알뜰폰'),
          telecomItem('LG U+ 알뜰폰'),
        ],
      ),
    );
  }

  Widget koreanIdForm(BuildContext context) {
    return TextFormField(
      focusNode: _focusNodes[1],
      inputFormatters: [
        CardFormatter(
          sample: 'xxxxxx x',
          separator: ' ',
        ),
      ],
      autofocus: true,
      style: style,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '주민등록번호',
          helperText: '생년월일 6자리와 뒷번호 1자리'),
      onChanged: (text) {
        if (text.length >= 8) {
          FocusScope.of(context).unfocus();
          nextStep();
        }
        frontBackId = text;
      },
    );
  }

  Widget phoneNumberForm(BuildContext context) {
    return TextFormField(
        inputFormatters: [
          CardFormatter(
            sample: 'xxx xxxx xxxx',
            separator: ' ',
          )
        ],
        autofocus: true,
        style: const TextStyle(
          letterSpacing: 2.0,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '휴대폰번호',
        ),
        onChanged: (text) {
          if (text.length >= 13) {
            FocusScope.of(context).unfocus();
            nextStep();
          }
          phoneNumber = text;
        });
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
                        text: headlines[curStep],
                        textAlign: TextAlign.left,
                      )),
                  Expanded(
                      child: SingleChildScrollView(
                          child: Column(
                    children: [
                      const SizedBox(height: 60),
                      curStep >= 3 ? nameForm() : Container(),
                      const SizedBox(height: 40),
                      curStep >= 2
                          ? GestureDetector(
                              onTap: bottomSheetOpen,
                              child: TextFormField(
                                enableSuggestions: true,
                                controller: phoneCtrl,
                                style: style,
                                enabled: false,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: '통신사'),
                              ),
                            )
                          : Container(),
                      const SizedBox(height: 40),
                      curStep >= 1 ? koreanIdForm(context) : Container(),
                      const SizedBox(height: 40),
                      phoneNumberForm(context),
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
