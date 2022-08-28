// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import 'mts.controller.dart';

class RaonSecureTest extends StatefulWidget {
  const RaonSecureTest({Key? key}) : super(key: key);

  @override
  State<RaonSecureTest> createState() => _RaonSecureTestState();
}

class _RaonSecureTestState extends State<RaonSecureTest> {
  final MtsController _mtsController = MtsController.get();
  String functionName = '';
  String returnValue = '';

  _onPressed() async {
    dynamic res = await _mtsController.getTheResult(functionName);
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
