// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

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
  String _certPin = '';
  bool _buttonDisabled = true;
  List<RKSWCertItem> certificationList = [];
  bool passwordVisible = false;
  bool showInputElement = false;
  bool needsIdToSignIn = false;

  void _setVisible(bool status) {
    passwordVisible = status;
  }

  @override
  void initState() {
    super.initState();
    needsIdToSignIn = _mtsController.needId;
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
        goMTSImportCert();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    .map((cert) => CertificationCard(
                        item: cert,
                        onPressed: () {
                          _mtsController.setCertification(cert);
                          setState(() {
                            certificationList.removeWhere((e) => e != cert);
                            showInputElement = true;
                          });
                        }))
                    .toList())),
        needsIdToSignIn
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
                  if (needsIdToSignIn)
                    {
                      _mtsController.setID(_certId),
                    },
                  await _mtsController.showMTSResult(),
                },
              )
            : CustomButton(
                onPressed: () {
                  certificationList.clear();
                  _mtsController.emptyCerts();
                  goMTSImportCert();
                },
                label: '공동인증서 삭제',
              ),
        showInputElement
            ? TextFormField(
                initialValue: _certPin,
                onChanged: (val) => {
                      setState(() {
                        if (val.length == 4) {
                          _certPin = val;
                          _buttonDisabled = false;
                        } else {
                          _buttonDisabled = true;
                        }
                      })
                    },
                autofocus: true,
                style: authFormFieldStyle,
                obscureText: true,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                maxLength: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '계좌 비밀번호',
                  helperText: 'PIN번호를 입력해주세요',
                ))
            : Container(),
        const SizedBox(height: 10),
        CustomButton(
          label: '확인',
          disabled: _buttonDisabled,
          onPressed: () {
            _mtsController.setCertPW(_certPW);
            if (needsIdToSignIn) {
              _mtsController.setID(_certId);
            }
            _mtsController.setPin(_certPin);
            _mtsController.showMTSResult();
          },
        ),
      ],
    );
  }
}
