// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import '../auth/widget/auth_forms.dart';
import '../theme.dart';
import '../shared/shared.dart';
import 'mts.dart';

class MTSLoginCertPage extends StatefulWidget {
  const MTSLoginCertPage({Key? key}) : super(key: key);

  @override
  State<MTSLoginCertPage> createState() => _MTSLoginCertPageState();
}

class _MTSLoginCertPageState extends State<MTSLoginCertPage> {
  final MtsController _mtsController = MtsController.get();
  String _certId = '';
  String _certPW = '';
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
        goMTSLoginCert();
      }
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
              // TODO: 헬프버튼
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
                (cert) => CertificationCard(
                  item: cert,
                  onPressed: () {
                    _mtsController.setCertification(cert);
                    setState(() {
                      certificationList.removeWhere((e) => e != cert);
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
              autofocus: true,
              initialValue: _certId,
              onChanged: (val) => {
                setState(() {
                  _certId = val;
                })
              },
              style: authFormFieldStyle,
              keyboardType: TextInputType.name,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '증권사 아이디',
                helperText: '아이디를 입력해주세요',
              ),
            )
          : Container(),
      showInputElement
          ? TextFormField(
              initialValue: _certPW,
              onChanged: (val) => {
                setState(() {
                  _certPW = val;
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
              onFieldSubmitted: (password) async => {
                _mtsController.setCertPW(password),
                _mtsController.setCertID(_certId),
                await _mtsController.showMTSResult(),
              },
            )
          : CustomButton(
              onPressed: () {
                certificationList.clear();
                _mtsController.emptyCerts();
                goMTSLoginCert();
              },
              label: '공동인증서 삭제',
            ),
    ]);
  }
}
