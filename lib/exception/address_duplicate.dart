// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';
import '../auth/auth.controller.dart';
import '../shared/back_button.dart';
import '../shared/custom_button.dart';
import '../vote/vote.controller.dart';

class AddressDuplicationPage extends StatefulWidget {
  const AddressDuplicationPage({Key? key}) : super(key: key);

  @override
  State<AddressDuplicationPage> createState() => _AddressDuplicationPageState();
}

class _AddressDuplicationPageState extends State<AddressDuplicationPage> {
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  int selected = 0;

  onConfirmed(String address) {
    authCtrl.setAddress(address);
    voteCtrl.selectShareholder(selected);
    Get.offNamed('/checkvotenum');
  }

  @override
  Widget build(BuildContext context) {
    final addressList = voteCtrl.addressList();

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
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: addressList.length,
                itemBuilder: (BuildContext context, int index) {
                  return RadioListTile(
                      title: Text(addressList[index]),
                      value: addressList[index],
                      groupValue: addressList[selected],
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            selected = index;
                          });
                        }
                      });
                },
              ),
              CustomButton(
                  width: CustomW.w4,
                  label: '확인',
                  onPressed: () => onConfirmed(addressList[selected]))
            ],
          )),
    );
  }
}
