// π¦ Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// π¦ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// π Project imports:
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

  Future<void> loadCertList() async {
    Set<RKSWCertItem>? response = await _mtsController.loadCertList();
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
          text: 'μ°λνκΈ°',
          bgColor: Colors.transparent,
          helpButton: IconButton(
            icon: Icon(
              Icons.help,
              color: customColor[ColorType.deepPurple],
            ),
            onPressed: () {
              // TODO: ν¬νλ²νΌ
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
          text: 'κ³΅λμΈμ¦μ μ ν',
          typoType: TypoType.h1Title,
          textAlign: TextAlign.start,
          isFullWidth: true,
        ),
        CustomText(
          text:
              'μ¦κΆμ¬ μ°λμ μν΄ κ³΅λμΈμ¦μλ₯Ό μ νν΄μ£ΌμΈμ.\nμΌλΆ μ¦κΆμ¬μ κ²½μ° κ³΅λμΈμ¦μμ μ¦κΆμ¬ IDλ₯Ό\nλͺ¨λ μκ΅¬ν  μλ μμ΅λλ€.',
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
                    .map((RKSWCertItem cert) => CertificationCard(
                        item: cert,
                        onPressed: () {
                          _mtsController.setCertification(cert);
                          setState(() {
                            certificationList
                                .removeWhere((RKSWCertItem e) => e != cert);
                            showInputElement = true;
                          });
                        }))
                    .toList())),
        needsIdToSignIn
            ? TextFormField(
                autofocus: true,
                initialValue: _certId,
                onChanged: (String val) => {
                  setState(() {
                    _certId = val;
                  })
                },
                style: authFormFieldStyle,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'μ¦κΆμ¬ μμ΄λ',
                  helperText: 'μμ΄λλ₯Ό μλ ₯ν΄μ£ΌμΈμ',
                ),
              )
            : Container(),
        showInputElement
            ? TextFormField(
                initialValue: _certPW,
                onChanged: (String val) => {
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
                  labelText: 'μΈμ¦μ λΉλ°λ²νΈ',
                  helperText: 'λΉλ°λ²νΈλ₯Ό μλ ₯ν΄μ£ΌμΈμ',
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
                label: 'κ³΅λμΈμ¦μ μ­μ ',
              ),
        showInputElement
            ? TextFormField(
                initialValue: _certPin,
                onChanged: (String val) => {
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
                  labelText: 'κ³μ’ λΉλ°λ²νΈ',
                  helperText: 'PINλ²νΈλ₯Ό μλ ₯ν΄μ£ΌμΈμ',
                ))
            : Container(),
        const SizedBox(height: 10),
        CustomButton(
          label: 'νμΈ',
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
