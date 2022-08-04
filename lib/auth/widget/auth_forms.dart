// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show ExtensionBottomSheet, Get, GetNavigation;

// 🌎 Project imports:
import '../../shared/shared.dart';
import '../../theme.dart';
import 'card_formatter.dart';

enum FormStep { phoneNumber, koreanId, telecom, name }

const authFormFieldStyle = TextStyle(
  letterSpacing: 2.0,
  fontSize: 20,
  fontWeight: FontWeight.w900,
);

class PhoneNumberForm extends StatefulWidget {
  final Function(FormStep step, String value) nextForm;

  const PhoneNumberForm({
    Key? key,
    required this.nextForm,
  }) : super(key: key);

  @override
  State<PhoneNumberForm> createState() => _PhoneNumberFormState();
}

class _PhoneNumberFormState extends State<PhoneNumberForm> {
  bool _validation = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: true,
      inputFormatters: [
        CardFormatter(
          sample: 'xxx xxxx xxxx',
          separator: ' ',
        )
      ],
      style: authFormFieldStyle,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        floatingLabelStyle: TextStyle(
          color: _validation
              ? Colors.deepPurple
              : const Color.fromARGB(255, 255, 55, 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: _validation
                ? Colors.deepPurple
                : const Color.fromARGB(255, 255, 55, 0),
          ),
        ),
        border: const OutlineInputBorder(),
        labelText: '휴대폰번호',
        helperText: _validation ? '' : '숫자만 입력할 수 있습니다.',
        helperStyle: const TextStyle(
          color: Color.fromARGB(255, 255, 55, 0),
        ),
      ),
      onChanged: (text) {
        if (text.isEmpty) {
          setState(() {
            _validation = true;
          });
        } else {
          for (int i = 0; i < text.length; i++) {
            if (i == 3) {
              if (text[i] == ' ') {
                setState(() {
                  _validation = true;
                });
                continue;
              } else {
                setState(() {
                  _validation = false;
                });
                break;
              }
            } else if (i == 8) {
              if (text[i] == ' ') {
                setState(() {
                  _validation = true;
                });
                continue;
              } else {
                setState(() {
                  _validation = false;
                });
                break;
              }
            } else {
              if (RegExp(r'[0-9]').hasMatch(text[i])) {
                setState(() {
                  _validation = true;
                });
                continue;
              } else {
                setState(() {
                  _validation = false;
                });
                break;
              }
            }
          }
        }

        if (text.length >= 13 && _validation) {
          FocusScope.of(context).unfocus();
          widget.nextForm(FormStep.phoneNumber, text);
        }
      },
    );
  }
}

class KoreanIdForm extends StatefulWidget {
  final FocusNode focusNode;
  final Function(FormStep step, String value) nextForm;
  const KoreanIdForm({
    Key? key,
    required this.nextForm,
    required this.focusNode,
  }) : super(key: key);

  @override
  State<KoreanIdForm> createState() => _KoreanIdFormState();
}

class _KoreanIdFormState extends State<KoreanIdForm> {
  bool _validation = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      inputFormatters: [
        CardFormatter(
          sample: 'xxxxxx x',
          separator: ' ',
        ),
      ],
      style: authFormFieldStyle,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        floatingLabelStyle: TextStyle(
          color: _validation
              ? Colors.deepPurple
              : const Color.fromARGB(255, 255, 55, 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: _validation
                ? Colors.deepPurple
                : const Color.fromARGB(255, 255, 55, 0),
          ),
        ),
        border: const OutlineInputBorder(),
        labelText: '주민등록번호',
        helperText: _validation ? '생년월일 6자리와 뒷번호 1자리' : '숫자만 입력할 수 있습니다.',
        helperStyle: TextStyle(
          color: _validation
              ? Colors.deepPurple
              : const Color.fromARGB(255, 255, 55, 0),
        ),
      ),
      onChanged: (text) {
        if (text.isEmpty) {
          setState(() {
            _validation = true;
          });
        } else {
          for (int i = 0; i < text.length; i++) {
            if (i == 6) {
              if (text[6] == ' ') {
                setState(() {
                  _validation = true;
                });
              } else {
                setState(() {
                  _validation = false;
                });
                break;
              }
            } else {
              if (RegExp(r'[0-9]').hasMatch(text[i])) {
                setState(() {
                  _validation = true;
                });
              } else {
                setState(() {
                  _validation = false;
                });
                break;
              }
            }
          }
        }

        if (_validation && text.length >= 8) {
          FocusScope.of(context).unfocus();
          widget.nextForm(FormStep.koreanId, text);
        }
      },
    );
  }
}

class TelecomForm extends StatefulWidget {
  final String telecom;
  final TextEditingController phoneCtrl;
  final Function(FormStep step, String value) nextForm;
  const TelecomForm({
    Key? key,
    required this.nextForm,
    required this.telecom,
    required this.phoneCtrl,
  }) : super(key: key);

  @override
  State<TelecomForm> createState() => _TelecomFormState();
}

class _TelecomFormState extends State<TelecomForm> {
  void openBottomSheet() {
    Get.bottomSheet(
      TelcomModal(nextForm: widget.nextForm),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: openBottomSheet,
      child: TextFormField(
        enableSuggestions: true,
        controller: widget.phoneCtrl,
        style: authFormFieldStyle,
        enabled: false,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '통신사',
        ),
      ),
    );
  }
}

class TelcomModal extends StatelessWidget {
  final Function(FormStep step, String value) nextForm;
  const TelcomModal({
    Key? key,
    required this.nextForm,
  }) : super(key: key);

  Widget _buildTelecomItem(String item) {
    return InkWell(
      onTap: () {
        nextForm(FormStep.telecom, item);
        goBack();
      },
      child: Container(
        width: customW[CustomW.w4],
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: CustomText(
          typoType: TypoType.h1Bold,
          text: item,
          colorType: ColorType.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      height: Get.height * 0.5,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            CustomText(
              typoType: TypoType.h1Bold,
              text: '통신사 선택',
            ),
            const SizedBox(height: 20),
            _buildTelecomItem('SKT'),
            _buildTelecomItem('KT'),
            _buildTelecomItem('LG U+'),
            _buildTelecomItem('SKT 알뜰폰'),
            _buildTelecomItem('KT 알뜰폰'),
            _buildTelecomItem('LG U+ 알뜰폰'),
          ],
        ),
      ),
    );
  }
}

class NameForm extends StatefulWidget {
  final FocusNode focusNode;
  final Function(FormStep step, String value) nextForm;
  const NameForm({
    Key? key,
    required this.focusNode,
    required this.nextForm,
  }) : super(key: key);

  @override
  State<NameForm> createState() => _NameFormState();
}

class _NameFormState extends State<NameForm> {
  bool _validation = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: widget.focusNode,
      autofocus: true,
      style: authFormFieldStyle,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: _validation
                ? Colors.deepPurple
                : const Color.fromARGB(255, 255, 55, 0),
          ),
        ),
        floatingLabelStyle: TextStyle(
          color: _validation
              ? Colors.deepPurple
              : const Color.fromARGB(255, 255, 55, 0),
        ),
        labelText: '이름',
        helperText: _validation ? '' : '한글만 입력할 수 있습니다.',
        helperStyle: TextStyle(
          color: _validation
              ? Colors.deepPurple
              : const Color.fromARGB(255, 255, 55, 0),
        ),
      ),
      onChanged: (text) {
        if (text.isEmpty) {
          setState(() {
            _validation = true;
          });
        } else {
          for (int i = 0; i < text.length; i++) {
            if (RegExp(r'^[ㄱ-ㅎ가-힣]*$').hasMatch(text[i])) {
              setState(() {
                _validation = true;
              });
            } else {
              setState(() {
                _validation = false;
              });
              break;
            }
          }
          if (_validation && text.length >= 2) {
            widget.nextForm(FormStep.name, text);
          }
        }
      },
    );
  }
}
