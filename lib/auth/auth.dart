import '../shared/card_formatter.dart';
import '../shared/custom_color.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../shared/custom_appbar.dart';
import '../shared/custom_button.dart';
import 'auth.controller.dart';
import '../shared/unfocused.dart';
import '../shared/custom_text.dart';
import '../shared/custom_grid.dart';

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
  final FocusScopeNode _node = FocusScopeNode();
  final AuthController _controller = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  final _formKey = GlobalKey<FormState>();
  int curStep = 0;
  String userName = "";
  String frontBackId = "";
  String telecom = '';
  String phoneNumber = "";
  String header = headlines[0];
  final telecomController = TextEditingController();
  final commonStyle = const TextStyle(
      letterSpacing: 2.0, fontSize: 18, fontWeight: FontWeight.bold);

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  onPressed() {
    final valueList = frontBackId.split(' ');

    _controller.getOtpCode(userName, valueList[0], valueList[1], telecom,
        phoneNumber.replaceAll(' ', ''));
    Get.toNamed('/validate');
  }

  onNext() {
    // TODO: Focus 전환 필요
    print('onNext: $curStep');
    // FocusScope.of(Get.context!).unfocus();
    // FocusManager.instance.primaryFocus?.unfocus();
    switch (curStep) {
      case 0:
        curStep += 1;
        _controller.getUserInfo(phoneNumber.replaceAll(' ', ''));
        break;
      case 1:
        Get.bottomSheet(telecomList(),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)));
        curStep += 1;
        break;
      case 2:
        Get.back();
        curStep += 1;
        break;
      case 3:
        curStep += 1;
        break;
    }
    setState(() {});
  }

  void textFieldOnTap() {
    Get.bottomSheet(telecomList(),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
  }

  Widget confirmButton() {
    return CustomButton(
      label: '확인',
      onPressed: onPressed,
      width: CustomW.w4,
    );
  }

  Widget nameForm() {
    return TextFormField(
      autofocus: true,
      style: commonStyle,
      decoration:
          const InputDecoration(border: OutlineInputBorder(), labelText: '이름'),
      onChanged: (text) {
        if (text.length >= 2) {
          onNext();
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
          telecomController.value = TextEditingValue(text: item);
          onNext();
        });
      },
      child: Container(
        width: customW[CustomW.w4],
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: CustomText(
            typoType: TypoType.h1Bold, text: item, colorType: ColorType.grey),
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
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          const SizedBox(height: 30),
          const CustomText(typoType: TypoType.h1Bold, text: '통신사 선택'),
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
      inputFormatters: [CardFormatter(sample: 'xxxxxx x', separator: " ")],
      autofocus: true,
      style: commonStyle,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '주민등록번호',
          helperText: '생년월일 6자리와 뒷번호 1자리'),
      onChanged: (text) {
        if (text.length >= 8) {
          FocusScope.of(context).unfocus();
          onNext();
        }
        frontBackId = text;
      },
    );
  }

  Widget phoneNumberForm(BuildContext context) {
    return TextFormField(
        inputFormatters: [
          CardFormatter(sample: 'xxx xxxx xxxx', separator: " ")
        ],
        autofocus: true,
        style: const TextStyle(
            letterSpacing: 2.0, fontSize: 18, fontWeight: FontWeight.w700),
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), labelText: '휴대폰번호'),
        onChanged: (text) {
          if (text.length >= 13) {
            FocusScope.of(context).unfocus();
            onNext();
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
              node: _node,
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
                            ? TextFormField(
                                autofocus: true,
                                enableSuggestions: true,
                                controller: telecomController,
                                style: commonStyle,
                                onTap: () {
                                  textFieldOnTap();
                                },
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: '통신사'),
                              )
                            : Container(),
                        const SizedBox(height: 40),
                        curStep >= 1 ? koreanIdForm(context) : Container(),
                        const SizedBox(height: 40),
                        phoneNumberForm(context),
                        const SizedBox(height: 40),
                        // curStep >= 4 ? ServiceTerm() : Container(),
                        curStep >= 4
                            ? CustomButton(
                                label: '확인',
                                onPressed: onPressed,
                                width: CustomW.w4,
                              )
                            : Container()
                      ],
                    )))
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
