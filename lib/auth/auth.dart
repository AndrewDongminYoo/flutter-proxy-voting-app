import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'auth.controller.dart';
import '../shared/custom_text.dart';
import '../shared/custom_grid.dart';
import '../shared/custom_button.dart';

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
  final _formKey = GlobalKey<FormState>();
  int curStep = 0;
  String header = headlines[0];
  final AuthController _controller = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  onPressed() {
    _controller.signUp();
    Get.toNamed('/validate');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Align(
                alignment: Alignment.centerLeft,
                child: CustomText(
                  typoType: TypoType.h2,
                  text: header,
                )),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: '휴대폰번호'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: '주민등록번호'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: '통신사'),
            ),
            TextFormField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(), labelText: '이름'),
            ),
            CustomButton(label: '확인', onPressed: onPressed, width: CustomW.w4,)
          ],
        ),
      )),
    );
  }
}
