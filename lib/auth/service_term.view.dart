// π¦ Flutter imports:
import 'package:flutter/material.dart';

// π¦ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:url_launcher/url_launcher_string.dart';

// π Project imports:
import '../shared/shared.dart';
import '../theme.dart';

const items = [
  '[νμ]μλΉμ€ μ΄μ©μ½κ΄',
  '[νμ]κ°μΈμ λ³΄ μμ§ λ° μ΄μ©λμ',
  '[νμ]ν΅μ μ¬ λ³ΈμΈμΈμ¦',
  '[μ ν]μ€μκ° μ£Όμ£Όμ΄ν λ± κ΄κ³ μ± μ λ³΄μμ '
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
              text: index != 3 ? 'μ λμ' : '',
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
        label: 'νμΈ',
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
                  text: 'μ½κ΄ λͺ¨λ λμ',
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
                    text: 'μ½κ΄ λͺ¨λ λ³΄κΈ°',
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
