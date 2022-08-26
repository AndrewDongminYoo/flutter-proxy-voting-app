// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import '../mts/mts.controller.dart';
import '../shared/shared.dart';
import '../auth/widget/widget.dart';

class SecuritiesPage extends StatefulWidget {
  const SecuritiesPage({Key? key}) : super(key: key);

  @override
  State<SecuritiesPage> createState() => _SecuritiesPageState();
}

class _SecuritiesPageState extends State<SecuritiesPage> {
  final MtsController _mtsController = MtsController.get();

  bool isIDLogin = true;
  String _securitiesID = '';
  String _securitiesPW = '';
  String _passNum = '';
  bool _visible = false;
  get passwordVisible => _visible;
  _setVisible(bool val) => _visible = val;

  _onPressed() async {
    _mtsController.setIDPW(_securitiesID, _securitiesPW);
    List<String> res = await _mtsController.loadMTSDataAndProcess(_passNum);
    List<Text> children = res.map((e) => Text(e)).toList();
    Get.isDialogOpen! ? goBack() : null;
    Get.bottomSheet(Container(
        padding: const EdgeInsets.all(36),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            )),
        child: ListView(children: children)));
  }

  @override
  void initState() {
    isIDLogin = _mtsController.securitiesFirm.canLoginWithID;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          text: '연동하기',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: isIDLogin
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: '증권사 연동하기',
                      typoType: TypoType.h2Bold,
                      isFullWidth: true,
                    ),
                    TextFormField(
                      autofocus: true,
                      initialValue: _securitiesID,
                      onChanged: (val) => {
                        setState(() {
                          _securitiesID = val;
                        })
                      },
                      style: authFormFieldStyle,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: '증권사 아이디',
                        helperText: '아이디를 입력해주세요',
                      ),
                    ),
                    TextFormField(
                        initialValue: _securitiesPW,
                        onChanged: (val) => {
                              setState(() {
                                _securitiesPW = val;
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
                            labelText: '증권사 비밀번호',
                            helperText: '비밀번호를 입력해주세요',
                            suffixIcon: InkWell(
                              onTap: () => setState(() {
                                _setVisible(!passwordVisible);
                              }),
                              child: passwordVisible
                                  ? const Icon(Icons.remove_red_eye_outlined)
                                  : const Icon(Icons.remove_red_eye),
                            ))),
                    TextFormField(
                        initialValue: _passNum,
                        onChanged: (val) => {
                              setState(() {
                                _passNum = val;
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
                        )),
                    CustomButton(
                      label: '확인',
                      onPressed: _onPressed,
                    )
                  ],
                )
              : const Text('인증서로 로그인하기 구현하기'),
        ));
  }
}
