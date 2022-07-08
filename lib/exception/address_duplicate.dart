// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../shared/custom_appbar.dart';
import '../shared/custom_button.dart';
import '../theme.dart';
import '../shared/get_nav.dart';
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
    jumpToCheckVoteNum();
  }

  @override
  Widget build(BuildContext context) {
    final addressList = voteCtrl.addressList();

    return Scaffold(
      appBar: CustomAppBar(text: '캠페인'),
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
                        setState(() {
                          selected = index;
                        });
                      });
                },
              ),
              CustomButton(
                width: CustomW.w4,
                label: '확인',
                onPressed: () => onConfirmed(addressList[selected]),
              )
            ],
          )),
    );
  }
}
