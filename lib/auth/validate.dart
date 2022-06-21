import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../shared/custom_button.dart';
import '../shared/custom_grid.dart';
import '../shared/custom_text.dart';

class ValidatePage extends StatefulWidget {
  const ValidatePage({Key? key}) : super(key: key);

  @override
  State<ValidatePage> createState() => _ValidatePageState();
}

class _ValidatePageState extends State<ValidatePage> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    goBack() {
      Get.back();
    }

    onPressed() {
      Get.toNamed('/');
    }

    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF5E3F74),
          elevation: 0,
          leading: IconButton(
            tooltip: "뒤로가기",
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: goBack,
          )),
      body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(children: [
            const SizedBox(height: 40),
            const Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  typoType: TypoType.h2,
                  text: '인증번호를 입력해주세요',
                )),
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return;
                }
                return null;
              },
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: '인증번호'),
            ),
            CustomButton(label: '확인', onPressed: onPressed, width: CustomW.w4)
          ])),
    );
  }
}
