// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import 'mts.controller.dart';
import '../shared/shared.dart';
import '../auth/widget/widget.dart';

class MTSLoginCERTPage extends StatefulWidget {
  const MTSLoginCERTPage({Key? key}) : super(key: key);

  @override
  State<MTSLoginCERTPage> createState() => _MTSLoginCERTPageState();
}

class _MTSLoginCERTPageState extends State<MTSLoginCERTPage> {
  final MtsController _mtsController = MtsController.get();

  String _certificationID = '';
  String _certificationPW = '';
  String _certificationEX = '';
  bool _passwordVisible = false;
  bool _buttonDisabled = true;
  get passwordVisible => _passwordVisible;
  _setVisible(bool val) => _passwordVisible = val;

  _onCERTLoginPressed() async {
    _mtsController.setCERT(
        _certificationID, _certificationPW, _certificationEX);
    await _mtsController.showMTSResult();
  }

  @override
  void initState() {
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
          child: loginWithCertification(),
        ));
  }

  // 인증서&비밀번호&만료일자로 로그인하기
  Column loginWithCertification() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(
        text: '인증서로 증권사 연동하기',
        typoType: TypoType.h2Bold,
        isFullWidth: true,
      ),
      TextFormField(
        autofocus: true,
        initialValue: _certificationID,
        onChanged: (val) => {
          setState(() {
            _certificationID = val;
          })
        },
        style: authFormFieldStyle,
        keyboardType: TextInputType.name,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: '인증서 이름',
          helperText:
              'cn=이름,ou=RA센터,ou=ㅇㅇ은행,ou=등록기관,ou=licensedCA,o=SIGN,c=KR',
        ),
      ),
      TextFormField(
          initialValue: _certificationPW,
          onChanged: (val) => {
                setState(() {
                  _certificationPW = val;
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
              helperText: '인증서 비밀번호를 입력해주세요',
              suffixIcon: InkWell(
                onTap: () => setState(() {
                  _setVisible(!passwordVisible);
                }),
                child: passwordVisible
                    ? const Icon(Icons.remove_red_eye_outlined)
                    : const Icon(Icons.remove_red_eye),
              ))),
      TextFormField(
          initialValue: _certificationEX,
          onChanged: (val) => {
                setState(() {
                  if (RegExp(r'20[0-5]\d[0-1]\d[0-3]\d').hasMatch(val)) {
                    _certificationEX = val;
                    _buttonDisabled = false;
                  } else {
                    _buttonDisabled = true;
                  }
                })
              },
          maxLength: 8,
          autofocus: true,
          style: authFormFieldStyle,
          keyboardType: TextInputType.datetime,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: '인증서 만료일자',
            helperText: '인증서 만료일자를 입력해주세요',
          )),
      const SizedBox(height: 10),
      CustomButton(
        disabled: _buttonDisabled,
        label: '확인',
        onPressed: _onCERTLoginPressed,
      ),
    ]);
  }
}
