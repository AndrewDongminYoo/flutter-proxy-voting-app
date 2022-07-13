// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../shared/shared.dart';
import '../theme.dart';
import '../vote/vote.controller.dart';

class AddressDuplicationPage extends StatefulWidget {
  const AddressDuplicationPage({Key? key}) : super(key: key);

  @override
  State<AddressDuplicationPage> createState() => _AddressDuplicationPageState();
}

class _AddressDuplicationPageState extends State<AddressDuplicationPage> {
  final AuthController _authCtrl = AuthController.get();
  final VoteController _voteCtrl = VoteController.get();

  int _selected = 0;

  _onConfirmed(String address) {
    _authCtrl.setAddress(address);
    _voteCtrl.selectShareholder(_selected);
    jumpToCheckVoteNum();
  }

  _onSelectAddress(int index) {
    setState(() {
      _selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final addressList = _voteCtrl.addressList;
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
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: CustomCard(
                      content: RadioListTile(
                          activeColor: customColor[ColorType.yellow],
                          title: CustomText(text: addressList[index]),
                          value: addressList[index],
                          groupValue: addressList[_selected],
                          onChanged: (value) {
                            _onSelectAddress(index);
                          }),
                    ),
                  );
                },
              ),
              CustomButton(
                width: CustomW.w4,
                label: '확인',
                onPressed: () => _onConfirmed(addressList[_selected]),
              )
            ],
          )),
    );
  }
}
