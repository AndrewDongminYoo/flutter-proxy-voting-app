// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import '../mts/mts.controller.dart';
import '../shared/shared.dart';
import '../auth/widget/widget.dart';
import '../theme.dart';

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
  String _certificationID = '';
  String _certificationPW = '';
  String _certificationEX = '';
  String _passNum = '';
  bool _passwordVisible = false;
  bool _buttonDisabled = true;
  get passwordVisible => _passwordVisible;
  _setVisible(bool val) => _passwordVisible = val;

  toggleIDLogin() {
    setState(() {
      isIDLogin = !isIDLogin;
      _securitiesID = '';
      _securitiesPW = '';
      _passNum = '';
      _certificationID = '';
      _certificationPW = '';
      _certificationEX = '';
    });
  }

  _onIDLoginPressed() async {
    _mtsController.setIDPW(_securitiesID, _securitiesPW, _passNum);
    await _mtsController.showMTSResult();
  }

  _onCERTLoginPressed() async {
    _mtsController.setCERT(
        _certificationID, _certificationPW, _certificationEX);
    await _mtsController.showMTSResult();
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
          child:
              isIDLogin ? loginWithIdAndPassword() : loginWithCertification(),
        ));
  }

  // 아이디&비밀번호로 로그인하기 (인증서 로그인만 가능한 증권사도 있음!)
  Column loginWithIdAndPassword() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  if (val.length == 4) {
                    _passNum = val;
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
          )),
      const SizedBox(height: 10),
      CustomButton(
        label: '확인',
        disabled: _buttonDisabled,
        onPressed: _onIDLoginPressed,
      ),
      const SizedBox(height: 10),
      CustomButton(
        label: '인증서로 로그인하기',
        bgColor: ColorType.orange,
        onPressed: toggleIDLogin,
      )
    ]);
  }

  // 인증서&비밀번호&만료일자로 로그인하기
  Column loginWithCertification() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(
        text: '증권사 연동하기',
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
      const SizedBox(height: 10),
      CustomButton(
        label: '아이디로 로그인하기',
        bgColor: ColorType.orange,
        disabled: !_mtsController.securitiesFirm.canLoginWithID,
        onPressed: toggleIDLogin,
      )
    ]);
  }
}
