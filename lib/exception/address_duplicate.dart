import 'package:bside/shared/custom_button.dart';
import 'package:bside/shared/custom_grid.dart';
import "package:flutter/material.dart";
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
  String _address = '';
  var addressList = [
    '서울시 송파구 아무로 12-2길 32, 송파아크 로펠리스 타워 102동 708호',
    '서울시 송파구 아무로 12-2길 32, 송파아크 로펠리스 타워 102동 707호',
    '서울시 송파구 아무로 12-2길 32, 송파아크 로펠리스 타워 102동 7079호',
    '서울시 송파구 아무로 12-2길 32, 송파아크 로펠리스 타워 102동 800호',
    '서울시 송파구 아무로 12-2길 32, 송파아크 로펠리스 타워 102동 7080호',
  ];

  onConfirmed() {
    _controller.setAddress(_address);
    Get.offNamed('/checkvotenum');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: customColor[ColorType.deepPurple],
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text('주소 중복 확인'),
      ),
      body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: addressList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return RadioListTile(
                        title: Text(addressList[index]),
                        value: addressList[index],
                        groupValue: _address,
                        onChanged: (value) {
                          setState(() {
                            _address = addressList[index];
                          });
                        });
                  },
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(_address),
                ),
              ),
              CustomButton(
                  width: CustomW.w4, label: '확인', onPressed: onConfirmed)
            ],
          )),
    );
  }
}
