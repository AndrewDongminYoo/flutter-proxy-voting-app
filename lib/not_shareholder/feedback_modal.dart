import 'package:bside/shared/custom_color.dart';
import 'package:bside/shared/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared/card_formatter.dart';
import '../shared/custom_button.dart';
import '../shared/custom_grid.dart';

class FeedBackModal extends StatelessWidget {
  const FeedBackModal({Key? key}) : super(key: key);

  onClose() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(left: 25, right: 25),
      title: Row(children: [
        const CustomText(typoType: TypoType.h2, text: '무엇이든 물어보세요'),
        const Spacer(),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close,
              color: Colors.black, semanticLabel: 'Close modal'),
        )
      ]),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      content: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              phoneNumberForm(),
              feedbackForm(),
              const SizedBox(height: 10),
              CustomButton(
                label: '접수',
                bgColor: ColorType.deepPurple,
                onPressed: () {},
                width: CustomW.w3,
              )
            ],
          )),
    );
  }
}

Widget phoneNumberForm() {
  return TextFormField(
      inputFormatters: [CardFormatter(sample: 'xxx xxxx xxxx', separator: " ")],
      autofocus: true,
      style: const TextStyle(
          letterSpacing: 2.0, fontSize: 18, fontWeight: FontWeight.w700),
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: '회신 받은 연락처'),
      onChanged: (text) {
        if (text.length >= 13) {}
      });
}

Widget feedbackForm() {
  String comment = '';
  return TextField(
    // minLines: 5,
    controller: TextEditingController(text: '문의내용:'),
    maxLines: 8,
    onChanged: (val) {
      comment = val;
    },
    style: const TextStyle(height: 1),
    decoration: InputDecoration(
      focusColor: Colors.transparent,
      hintText: '문의내용:',
      hintStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      labelStyle: TextStyle(color: customColor[ColorType.deepPurple]),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        // borderSide: BorderSide(width: 1, color: ColorType),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
        // borderSide: BorderSide(width: 1, color: Palette.primaryColor),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10.0)),
      ),
    ),
  );
}
