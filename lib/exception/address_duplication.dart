import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/auth.controller.dart';
import '../shared/back_button.dart';
import '../shared/custom_color.dart';

class AddressDuplicationPage extends StatefulWidget {
  const AddressDuplicationPage({Key? key}) : super(key: key);

  @override
  State<AddressDuplicationPage> createState() => _AddressDuplicationPageState();
}

class _AddressDuplicationPageState extends State<AddressDuplicationPage> {
  final AuthController _controller = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  String _adress = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: customColor[ColorType.deepPurple],
          elevation: 0,
          leading: const CustomBackButton(),
          title: const Text('주소 중복 확인'),
        ),
        body: Align(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            RadioListTile(
                value: '${_controller.user}',
                groupValue: _adress,
                onChanged: (value) {
                  setState(() {
                    _adress = '주소1';
                  });
                })
          ]),
        ));
  }
}
