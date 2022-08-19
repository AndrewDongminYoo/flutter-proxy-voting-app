import 'package:flutter/material.dart';

import '../shared/custom_appbar.dart';
import '../shared/custom_button.dart';
import 'mts.controller.dart';

class SecureCheck extends StatefulWidget {
  const SecureCheck({Key? key}) : super(key: key);

  @override
  State<SecureCheck> createState() => _SecureCheckState();
}

class _SecureCheckState extends State<SecureCheck> {
  final MtsController _mtsController = MtsController.get();
  String functionName = '';
  String returnValue = '';

  _onPressed() async {
    var res = await _mtsController.getTheResult(functionName);
    returnValue = res.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: '함수테스트'),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            TextFormField(
              autofocus: true,
              keyboardType: TextInputType.name,
              initialValue: functionName,
              onChanged: (value) => {functionName = value},
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '함수 이름을 입력하세요.',
                helperText: '함수 이름을 입력하세요.',
              ),
            ),
            CustomButton(
              label: '확인',
              onPressed: _onPressed,
            ),
            Text(returnValue),
          ],
        ),
      ),
    );
  }
}
