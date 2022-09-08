// 🎯 Dart imports:
import 'dart:math' show min;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import 'auth.dart';

const headlines = [
  '휴대폰번호를\n입력해주세요',
  '주민번호를\n입력해주세요',
  '통신사를\n선택해주세요',
  '이름을\n입력해주세요',
  '정보를\n확인해주세요'
];

class AuthSignUpPage extends StatefulWidget {
  @override
  State<AuthSignUpPage> createState() => _AuthSignUpPageState();
  const AuthSignUpPage({Key? key}) : super(key: key);
}

class _AuthSignUpPageState extends State<AuthSignUpPage> {
  // controller and nodes
  final FocusNode _nameNode = FocusNode();
  final FocusNode _koreanIdNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneCtrl = TextEditingController();
  final AuthController _authCtrl = AuthController.get();
  final ScrollController controller = ScrollController();

  // variables
  int _curStep = 0;
  String _userName = '';
  String _frontId = '';
  String _backId = '';
  String _telecom = '';
  String _phoneNumber = '';

  _newUser() {
    _authCtrl.user = User(
      _userName,
      _frontId,
      _backId,
      _telecom,
      _phoneNumber,
    );
    _authCtrl.getOtpCode(_authCtrl.user);
    goAuthValidNew();
  }

  _existingUser() {
    final User user = _authCtrl.user;
    _authCtrl.getOtpCode(user);
    goAuthValidOld();
  }

  _nextForm(FormStep step, String value) {
    switch (step) {
      case FormStep.phoneNumber:
        final String tempPhoneNum = value.removeAllWhitespace;
        _authCtrl.getUserInfo(tempPhoneNum);
        _phoneNumber = tempPhoneNum;
        _koreanIdNode.requestFocus();
        break;
      case FormStep.koreanId:
        final List<String> valueList = value.split(' ');
        _frontId = valueList[0];
        _backId = valueList[1];
        if (_authCtrl.user.frontId == _frontId) {
          _existingUser();
          return;
        }
        Get.bottomSheet(TelcomModal(nextForm: _nextForm),
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)));
        break;
      case FormStep.telecom:
        _telecom = value;
        _phoneCtrl.value = TextEditingValue(text: value);
        _nameNode.requestFocus();
        break;
      case FormStep.name:
        _userName = value;
        break;
      default:
        break;
    }
    setState(() {
      _curStep += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(text: '캠페인', bgColor: const Color(0xFFFAFAFA)),
        body: Unfocused(
            child: Form(
                key: _formKey,
                child: FocusScope(
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: CustomText(
                                typoType: TypoType.h1Bold,
                                text: headlines[min(4, _curStep)],
                                textAlign: TextAlign.left,
                              )),
                          Expanded(
                              child: SingleChildScrollView(
                                  controller: controller,
                                  child: Column(children: [
                                    const SizedBox(height: 60),
                                    _curStep >= 3
                                        ? NameForm(
                                            nextForm: _nextForm,
                                            focusNode: _nameNode)
                                        : Container(),
                                    const SizedBox(height: 40),
                                    _curStep >= 2
                                        ? TelecomForm(
                                            nextForm: _nextForm,
                                            telecom: _telecom,
                                            phoneCtrl: _phoneCtrl)
                                        : Container(),
                                    const SizedBox(height: 40),
                                    _curStep >= 1
                                        ? KoreanIdForm(
                                            nextForm: _nextForm,
                                            focusNode: _koreanIdNode)
                                        : Container(),
                                    const SizedBox(height: 40),
                                    PhoneNumberForm(nextForm: _nextForm),
                                    const SizedBox(height: 40),
                                    _curStep >= 4
                                        ? ServiceTerm(
                                            controller: controller,
                                            newUserFunc: _newUser,
                                          )
                                        : Container(),
                                  ])))
                        ]))))));
  }
}
