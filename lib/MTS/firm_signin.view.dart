// 🐦 Flutter imports:
import 'package:flutter/material.dart';

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

  String _securitiesID = '';
  String _securitiesPW = '';
  bool _visible = false;
  get visible => _visible;
  setVisible(bool val) => _visible = val;

  onPressed() {
    _mtsController.setIDPW(_securitiesID, _securitiesPW);
    _mtsController.loadMTSDataAndProcess();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          text: '연동하기',
        ),
        body: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
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
                inputFormatters: [
                  CardFormatter(
                    sample: 'xxxxxxxxxx',
                    separator: '',
                  ),
                ],
                style: authFormFieldStyle,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: '아이디',
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
                  inputFormatters: [
                    CardFormatter(
                      sample: 'xxxxxxxxxx',
                      separator: '',
                    ),
                  ],
                  style: authFormFieldStyle,
                  obscureText: !visible,
                  keyboardType: visible
                      ? TextInputType.visiblePassword
                      : TextInputType.text,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: '비밀번호',
                      helperText: '비밀번호를 입력해주세요',
                      suffixIcon: InkWell(
                        onTap: () => setState(() {
                          setVisible(!visible);
                        }),
                        child: visible
                            ? const Icon(Icons.remove_red_eye_outlined)
                            : const Icon(Icons.remove_red_eye),
                      ))),
              CustomButton(
                label: '확인',
                onPressed: onPressed,
              )
            ],
          ),
        ));
  }
}
