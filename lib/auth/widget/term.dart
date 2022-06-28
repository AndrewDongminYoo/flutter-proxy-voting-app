import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../shared/custom_color.dart';
import '../../shared/custom_grid.dart';
import '../../shared/custom_text.dart';

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
  final List agreeTerms = [false, false, false, false];
  bool showDetails = false;

  getAllAgreeTerms() {
    return agreeTerms.every((element) => element);
  }

  setAllAgreeTerms(value) {
    for (var i = 0; i < agreeTerms.length; i++) {
      agreeTerms[i] = value;
    }
    if (mounted) setState(() {});
  }

  openPage(int index) async {
    switch (index) {
      case 0:
        await launchUrl(Uri.parse(
            'https://bsidekr.notion.site/af50b14ac5f148ccabef47c89882dd17'));
        break;
      case 1:
        await launchUrl(Uri.parse(
            'https://bsidekr.notion.site/f951d82e310d45bc85ec533c0267c8eb'));
        break;
      case 2:
        await launchUrl(
            Uri.parse('https://safe.ok-name.co.kr/eterms/agreement002.jsp'));
        break;
      case 3:
        // await launchUrl(
        //     Uri.parse("https://safe.ok-name.co.kr/eterms/agreement001.jsp"));
        break;
      default:
        break;
    }
    return;
  }

  Widget _buildCheckBox(int index, String label) {
    return CheckboxListTile(
      value: agreeTerms[index],
      onChanged: (value) {
        if (mounted) {
          setState(() {
            agreeTerms[index] = value;
          });
        }
      },
      title: GestureDetector(
        onTap: () {
          openPage(index);
        },
        child: RichText(
            text: TextSpan(children: [
          TextSpan(
              text: label,
              style: TextStyle(color: customColor[ColorType.purple])),
          TextSpan(
              text: index != 3 ? '에 동의' : '',
              style: const TextStyle(color: Colors.black))
        ])),
      ),
      checkboxShape: const CircleBorder(),
      activeColor: customColor[ColorType.yellow],
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  Widget _buildTerms() {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildCheckBox(index, items[index]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return showDetails
        ? _buildTerms()
        : Align(
            alignment: Alignment.topCenter,
            child: Column(children: [
              CheckboxListTile(
                value: getAllAgreeTerms(),
                onChanged: setAllAgreeTerms,
                title: const Text('약관 모두 동의'),
                checkboxShape: const CircleBorder(),
                activeColor: customColor[ColorType.yellow],
                controlAffinity: ListTileControlAffinity.leading,
              ),
              InkWell(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      showDetails = true;
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  width: customW[CustomW.w3],
                  child: Ink(
                      child: const CustomText(
                    text: '약관 모두 보기',
                    typoType: TypoType.body,
                  )),
                ),
              ),
              const SizedBox(height: 50)
            ]),
          );
  }
}
