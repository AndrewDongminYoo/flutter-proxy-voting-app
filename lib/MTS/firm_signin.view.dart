// π¦ Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, TextInputFormatter, TextInputType;
import 'package:get/get.dart';

// π Project imports:
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
          'μμ΄λ λ‘κ·ΈμΈμ μ€ν¨νμ΅λλ€.',
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
          text: 'μ°λνκΈ°',
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: loginWithIdAndPassword(),
        ));
  }

  // μμ΄λ&λΉλ°λ²νΈλ‘ λ‘κ·ΈμΈνκΈ° (μΈμ¦μ λ‘κ·ΈμΈλ§ κ°λ₯ν μ¦κΆμ¬λ μμ!)
  Column loginWithIdAndPassword() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(
        text: 'μμ΄λλ‘ μ¦κΆμ¬ μ°λνκΈ°',
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
          labelText: 'μ¦κΆμ¬ μμ΄λ',
          helperText: 'μμ΄λλ₯Ό μλ ₯ν΄μ£ΌμΈμ',
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
              labelText: 'μ¦κΆμ¬ λΉλ°λ²νΈ',
              helperText: 'λΉλ°λ²νΈλ₯Ό μλ ₯ν΄μ£ΌμΈμ',
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
            labelText: 'κ³μ’ λΉλ°λ²νΈ',
            helperText: 'PINλ²νΈλ₯Ό μλ ₯ν΄μ£ΌμΈμ',
          )),
      const SizedBox(height: 10),
      CustomButton(
        label: 'νμΈ',
        disabled: _buttonDisabled,
        onPressed: _onIDLoginPressed,
      ),
    ]);
  }
}
