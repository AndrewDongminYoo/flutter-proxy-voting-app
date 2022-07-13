// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher_string.dart';

// 🌎 Project imports:
import '../../shared/custom_button.dart';
import '../../shared/custom_nav.dart';
import '../../theme.dart';
import '../../shared/custom_text.dart';
import '../auth.dart';

const items = [
  '[필수]서비스 이용약관',
  '[필수]개인정보 수집 및 이용동의',
  '[필수]통신사 본인인증',
  '[선택]실시간 주주총회 등 광고성 정보수신'
];

class ServiceTerm extends StatefulWidget {
  const ServiceTerm({Key? key}) : super(key: key);

  @override
  State<ServiceTerm> createState() => _ServiceTermState();
}

class _ServiceTermState extends State<ServiceTerm> {
  final List _agreeTerms = [false, false, false, false];
  bool _showDetails = false;
  final AuthController _authCtrl = AuthController.get();
  final ScrollController _controller = ScrollController();

  _newUser() {
    _authCtrl.user;
    _authCtrl.getOtpCode(_authCtrl.user);
    goToValidateNew();
  }

  _getAllAgreeTerms() {
    return _agreeTerms.every((element) => element);
  }

  _setAllAgreeTerms(value) {
    for (var i = 0; i < _agreeTerms.length; i++) {
      _agreeTerms[i] = value;
    }
    if (mounted) setState(() {});
  }

  _openPage(int index) async {
    switch (index) {
      case 0:
        await launchUrlString(
            'https://bsidekr.notion.site/af50b14ac5f148ccabef47c89882dd17');
        break;
      case 1:
        await launchUrlString(
            'https://bsidekr.notion.site/f951d82e310d45bc85ec533c0267c8eb');
        break;
      case 2:
        await launchUrlString(
            'https://safe.ok-name.co.kr/eterms/agreement002.jsp');
        break;
      // case 3:
      //   await launchUrlString(
      //       'https://safe.ok-name.co.kr/eterms/agreement001.jsp');
      //   break;
      default:
        break;
    }
    return;
  }

  Widget _buildCheckBox(int index, String label) {
    return CheckboxListTile(
      value: _agreeTerms[index],
      onChanged: (value) {
        if (mounted) {
          setState(() {
            _agreeTerms[index] = value;
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
            itemBuilder: (context, index) {
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
    if (mounted) {
      if (_controller.hasClients) {
        _controller.animateTo(240.0,
            duration: const Duration(milliseconds: 500), curve: Curves.ease);
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: CustomButton(
        label: '확인',
        onPressed: _newUser,
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
