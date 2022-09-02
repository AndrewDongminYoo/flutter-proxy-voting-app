// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import '../auth/widget/auth_forms.dart';
import '../theme.dart';
import 'mts.dart';
import '../shared/shared.dart';

class MTSLoginCERTPage extends StatefulWidget {
  const MTSLoginCERTPage({Key? key}) : super(key: key);

  @override
  State<MTSLoginCERTPage> createState() => _MTSLoginCERTPageState();
}

class _MTSLoginCERTPageState extends State<MTSLoginCERTPage> {
  final MtsController _mtsController = MtsController.get();
  String certificationPassword = '';
  List<RKSWCertItem> certificationList = [];
  bool passwordVisible = false;
  bool showInputElement = false;

  void _setVisible(bool status) {
    passwordVisible = status;
  }

  @override
  void initState() {
    super.initState();
    loadCertList();
  }

  loadCertList() async {
    List<RKSWCertItem>? response = await _mtsController.loadCertList();
    setState(() {
      if (response != null && response.isNotEmpty) {
        for (RKSWCertItem element in response) {
          certificationList.add(element);
        }
      } else {
        goToMtsLoginWithCert();
      }
      print(certificationList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          text: '연동하기',
          bgColor: Colors.transparent,
          helpButton: IconButton(
            icon: Icon(
              Icons.help,
              color: customColor[ColorType.deepPurple],
            ),
            onPressed: () {
              // TODO: 뭐 넣지..
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: loginWithCertification(),
        ));
  }

  Column loginWithCertification() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(
        text: '공동인증서 선택',
        typoType: TypoType.h1Title,
        textAlign: TextAlign.start,
        isFullWidth: true,
      ),
      CustomText(
        text:
            '증권사 연동을 위해 공동인증서를 선택해주세요.\n일부 증권사의 경우 공동인증서와 증권사 ID를\n모두 요구할 수도 있습니다.',
        typoType: TypoType.body,
        textAlign: TextAlign.start,
        isFullWidth: true,
      ),
      Container(
        width: Get.width,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: certificationList
              .map(
                (certification) => CertificationCard(
                  item: certification,
                  onPressed: () {
                    _mtsController.setCertification(certification);
                    setState(() {
                      certificationList.removeWhere((e) => e != certification);
                      showInputElement = true;
                    });
                  },
                ),
              )
              .toList(),
        ),
      ),
      showInputElement
          ? TextFormField(
              initialValue: certificationPassword,
              onChanged: (val) => {
                setState(() {
                  certificationPassword = val;
                })
              },
              autofocus: true,
              style: authFormFieldStyle,
              obscureText: !passwordVisible,
              keyboardType: passwordVisible
                  ? TextInputType.visiblePassword
                  : TextInputType.text,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: '인증서 비밀번호',
                helperText: '비밀번호를 입력해주세요',
                suffixIcon: InkWell(
                  onTap: () => setState(() {
                    _setVisible(!passwordVisible);
                  }),
                  child: passwordVisible
                      ? const Icon(Icons.remove_red_eye_outlined)
                      : const Icon(Icons.remove_red_eye),
                ),
              ),
              onFieldSubmitted: (value) => {
                _mtsController.setCertPassword(value),
                _mtsController.showMTSResult(),
              },
            )
          : Container(),
    ]);
  }
}
