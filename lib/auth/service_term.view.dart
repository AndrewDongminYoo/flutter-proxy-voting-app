// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:url_launcher/url_launcher_string.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import '../theme.dart';

const items = [
  '[필수]서비스 이용약관',
  '[필수]개인정보 수집 및 이용동의',
  '[필수]통신사 본인인증',
  '[선택]실시간 주주총회 등 광고성 정보수신'
];

class ServiceTerm extends StatefulWidget {
  final ScrollController controller;
  final dynamic Function() newUserFunc;
  const ServiceTerm({
    Key? key,
    required this.controller,
    required this.newUserFunc,
  }) : super(key: key);

  @override
  State<ServiceTerm> createState() => _ServiceTermState();
}

class _ServiceTermState extends State<ServiceTerm> {
  final List<bool> _agreeTerms = [false, false, false, false];
  bool _showDetails = false;

  bool _getAllAgreeTerms() {
    return _agreeTerms.every((element) => element);
  }

  void _setAllAgreeTerms(bool? value) {
    for (int i = 0; i < _agreeTerms.length; i++) {
      _agreeTerms[i] = value!;
    }
    if (mounted) setState(() {});
  }

  dynamic _openPage(int index) async {
    switch (index) {
      case 0:
        await launchUrlString(
            'https://www.notion.so/donminzzi/f29cdc00386e40c3be426d7f8566f3e9');
        break;
      case 1:
        await launchUrlString(
            'https://www.notion.so/donminzzi/bd9ea120ddf34d4b88a7bfac41dfb6af');
        break;
      case 2:
        await launchUrlString(
            'https://www.notion.so/donminzzi/8f807abf669b4f9b881ce61b46547493');
        break;
      // case 3:
      //   await launchUrlString(
      //       'https://www.notion.so/donminzzi/CS-535bf8db896e466ebfd48368c927e39d');
      //   break;
      default:
        break;
    }
    return;
  }

  Widget _buildCheckBox(int index, String label) {
    return CheckboxListTile(
      value: _agreeTerms[index],
      onChanged: (bool? value) {
        if (mounted) {
          setState(() {
            _agreeTerms[index] = value!;
          });
        }
      },
      title: GestureDetector(
        onTap: () {
          _openPage(index);
        },
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
              text: label,
              style: TextStyle(color: customColor[ColorType.purple])),
          TextSpan(
              text: index != 3 ? '에 동의' : '',
              style: const TextStyle(color: Colors.black)),
        ])),
      ),
      checkboxShape: const CircleBorder(),
      activeColor: customColor[ColorType.yellow],
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildTerms() {
    return Column(
      children: [
        ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return _buildCheckBox(index, items[index]);
            }),
        const SizedBox(height: 50),
        (_agreeTerms[0] && _agreeTerms[1] && _agreeTerms[2])
            ? _confirmButton()
            : Container(),
      ],
    );
  }

  Widget _confirmButton() {
    if (widget.controller.hasClients) {
      widget.controller.animateTo(Get.height * 0.4,
          duration: const Duration(milliseconds: 500), curve: Curves.ease);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: CustomButton(
        label: '확인',
        onPressed: widget.newUserFunc,
        width: CustomW.w4,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _showDetails
        ? _buildTerms()
        : Align(
            alignment: Alignment.topCenter,
            child: Column(children: [
              CheckboxListTile(
                value: _getAllAgreeTerms(),
                onChanged: _setAllAgreeTerms,
                title: CustomText(
                  text: '약관 모두 동의',
                  textAlign: TextAlign.left,
                ),
                checkboxShape: const CircleBorder(),
                activeColor: customColor[ColorType.yellow],
                controlAffinity: ListTileControlAffinity.leading,
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    _showDetails = true;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  width: customW[CustomW.w3],
                  child: Ink(
                      child: CustomText(
                    text: '약관 모두 보기',
                    typoType: TypoType.body,
                  )),
                ),
              ),
              const SizedBox(height: 50),
              (_agreeTerms[0] && _agreeTerms[1] && _agreeTerms[2])
                  ? _confirmButton()
                  : Container()
            ]),
          );
  }
}
