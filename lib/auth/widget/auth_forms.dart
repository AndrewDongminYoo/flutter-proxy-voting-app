import 'package:bside/shared/custom_color.dart';
import 'package:bside/shared/custom_grid.dart';
import 'package:bside/shared/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/card_formatter.dart';

enum FormStep { phoneNumber, koreanId, telecom, name }

const formFieldStyle = TextStyle(
  letterSpacing: 2.0,
  fontSize: 20,
  fontWeight: FontWeight.w900,
);

class PhoneNumberForm extends StatefulWidget {
  final Function(FormStep step, String value) nextForm;
  const PhoneNumberForm({Key? key, required this.nextForm}) : super(key: key);

  @override
  State<PhoneNumberForm> createState() => _PhoneNumberFormState();
}

class _PhoneNumberFormState extends State<PhoneNumberForm> {
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
        style: formFieldStyle,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '휴대폰번호',
        ),
        onChanged: (text) {
          if (text.length >= 13) {
            FocusScope.of(context).unfocus();
            widget.nextForm(FormStep.phoneNumber, text);
          }
        });
  }
}

class KoreanIdForm extends StatefulWidget {
  final FocusNode focusNode;
  final Function(FormStep step, String value) nextForm;
  const KoreanIdForm(
      {Key? key, required this.nextForm, required this.focusNode})
      : super(key: key);

  @override
  State<KoreanIdForm> createState() => _KoreanIdFormState();
}

class _KoreanIdFormState extends State<KoreanIdForm> {
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
      style: formFieldStyle,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '주민등록번호',
          helperText: '생년월일 6자리와 뒷번호 1자리'),
      onChanged: (text) {
        if (text.length >= 8) {
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
  const TelecomForm({Key? key, required this.nextForm, required this.telecom, required this.phoneCtrl})
      : super(key: key);

  @override
  State<TelecomForm> createState() => _TelecomFormState();
}

class _TelecomFormState extends State<TelecomForm> {
  void openBottomSheet() {
    Get.bottomSheet(
      TelcomModal(nextForm: widget.nextForm),
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
        style: formFieldStyle,
        enabled: false,
        decoration: const InputDecoration(
            border: OutlineInputBorder(), labelText: '통신사'),
      ),
    );
  }
}

class TelcomModal extends StatelessWidget {
  final Function(FormStep step, String value) nextForm;
  const TelcomModal({Key? key, required this.nextForm}) : super(key: key);

  Widget _buildTelecomItem(String item) {
    return InkWell(
      onTap: () {
        nextForm(FormStep.telecom, item);
        Get.back();
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

  @override
  Widget build(BuildContext context) {
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
          _buildTelecomItem('SKT'),
          _buildTelecomItem('KT'),
          _buildTelecomItem('LG U+'),
          _buildTelecomItem('SKT 알뜰폰'),
          _buildTelecomItem('KT 알뜰폰'),
          _buildTelecomItem('LG U+ 알뜰폰'),
        ],
      ),
    );
  }
}

class NameForm extends StatelessWidget {
  final FocusNode focusNode;
  final Function(FormStep step, String value) nextForm;
  const NameForm({Key? key, required this.focusNode, required this.nextForm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      autofocus: true,
      style: formFieldStyle,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '이름',
      ),
      onChanged: (text) {
        if (text.length >= 2) {
          nextForm(FormStep.name, text);
        }
      },
    );
  }
}
