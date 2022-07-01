// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/custom_appbar.dart';
import '../auth/auth.controller.dart';

class AddressDuplicationPage extends StatefulWidget {
  const AddressDuplicationPage({Key? key}) : super(key: key);

  @override
  State<AddressDuplicationPage> createState() => _AddressDuplicationPageState();
}

class _AddressDuplicationPageState extends State<AddressDuplicationPage> {
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  String _adress = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(text: '주소 중복 확인'),
        body: Align(
          alignment: Alignment.center,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            RadioListTile(
                value: '${authCtrl.user}',
                groupValue: _adress,
                onChanged: (value) {
                  if (mounted) {
                    setState(() {
                      _adress = '주소1';
                    });
                  }
                })
          ]),
        ));
  }
}
