// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../shared/shared.dart';
import '../theme.dart';
import '../vote/vote.controller.dart';

class AddressDedupePage extends StatefulWidget {
  const AddressDedupePage({Key? key}) : super(key: key);

  @override
  State<AddressDedupePage> createState() => _AddressDedupePageState();
}

class _AddressDedupePageState extends State<AddressDedupePage> {
  final AuthController _authCtrl = AuthController.get();
  final VoteController _voteCtrl = VoteController.get();

  int _selected = 0;

  void _onConfirmed(String address) {
    _authCtrl.setAddress(address);
    _voteCtrl.selectShareholder(_selected);
    jumpVoteNumCheck();
  }

  void _onSelectAddress(int index) {
    setState(() {
      _selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<String> addressList = _voteCtrl.addressList;
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
                  List<String> arr = [];
                  RegExp regExp =
                      RegExp(r'^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$');
                  for (int i = 0; i < addressList[index].length; i++) {
                    if (addressList[index][i] == ' ' &&
                        regExp.hasMatch(addressList[index][i + 1])) {
                      arr.add('${addressList[index].substring(0, i)}...');
                      break;
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: CustomCard(
                      content: RadioListTile(
                          activeColor: customColor[ColorType.yellow],
                          title: CustomText(text: arr[0]),
                          value: addressList[index],
                          groupValue: addressList[_selected],
                          onChanged: (String? value) {
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
