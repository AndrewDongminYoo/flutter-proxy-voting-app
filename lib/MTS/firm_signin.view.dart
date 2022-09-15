// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter, TextInputType;
import 'package:get/get.dart';

// 🌎 Project imports:
import 'mts.controller.dart';
import '../shared/shared.dart';
import '../auth/widget/widget.dart';

class MTSLoginIdPage extends StatefulWidget {
  const MTSLoginIdPage({Key? key}) : super(key: key);

  @override
  State<MTSLoginIdPage> createState() => _MTSLoginIdPageState();
}

class _MTSLoginIdPageState extends State<MTSLoginIdPage> {
  final MtsController _mtsController = MtsController.get();

  String _securitiesID = '';
  String _securitiesPW = '';
  String _passNum = '';
  bool _passwordVisible = false;
  bool _buttonDisabled = true;
  bool get passwordVisible => _passwordVisible;
  void _setVisible(bool val) => _passwordVisible = val;

  Future<void> _onIDLoginPressed() async {
    try {
      _mtsController.setIDPW(_securitiesID, _securitiesPW, _passNum);
      await _mtsController.showMTSResult();
    } catch (e) {
      e.printInfo();
      e.printError();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
          '아이디 로그인에 실패했습니다.',
        )),
      );
    }
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
          child: loginWithIdAndPassword(),
        ));
  }

  // 아이디&비밀번호로 로그인하기 (인증서 로그인만 가능한 증권사도 있음!)
  Column loginWithIdAndPassword() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(
        text: '아이디로 증권사 연동하기',
        typoType: TypoType.h2Bold,
        isFullWidth: true,
      ),
      TextFormField(
        autofocus: true,
        initialValue: _securitiesID,
        onChanged: (String val) => {
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
          onChanged: (String val) => {
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
          onChanged: (String val) => {
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
    ]);
  }
}
