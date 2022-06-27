import '../vote/vote.controller.dart';

import '../auth/auth.data.dart';
import 'package:flutter/material.dart';
import '../auth/auth.controller.dart';
import 'common_app_body.dart';
import 'package:get/get.dart';

class TakeBackNumberPage extends StatefulWidget {
  const TakeBackNumberPage({Key? key}) : super(key: key);

  @override
  State<TakeBackNumberPage> createState() => _TakeBackNumberPageState();
}

class _TakeBackNumberPageState extends State<TakeBackNumberPage> {
  final AuthController _authCtrl = Get.find();
  late String frontId = '';
  late String backId = '';

  @override
  void initState() {
    if (_authCtrl.isLogined) {
      User? user = _authCtrl.user;
      if (user != null) {
        frontId = user.frontId;
      }
    }
    super.initState();
  }

  onConfirmed() {
    _authCtrl.putBackId(backId);
    Get.offAllNamed('/result');
  }

  @override
  Widget build(BuildContext context) {
    var helpText = '주민등록번호를 입력해주세요.';
    var informationString =
        '입력해주신 주민등록번호는 안전하게 암호화되며 주주명부 확인 및 위임장 작성 용도 이외에는 절대로 활용되지 않습니다. 해당 정보는 주주총회 이후 즉시 폐기됩니다.';
    var mainContent = Expanded(
        child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              border: Border.all(width: 3),
              borderRadius: const BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: Get.width / 4,
                  child: TextFormField(
                    initialValue: frontId,
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.right,
                    readOnly: true,
                  ),
                ),
                const Text('-', style: TextStyle(fontSize: 20)),
                SizedBox(
                  width: Get.width / 3,
                  child: TextFormField(
                    maxLength: 7,
                    decoration: const InputDecoration(
                        counterStyle: TextStyle(
                          height: double.minPositive,
                        ),
                        counterText: ''),
                    textAlignVertical: TextAlignVertical.center,
                    textAlign: TextAlign.left,
                    initialValue: backId,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    autofocus: true,
                    onChanged: ((input) {
                      backId = input;
                    }),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '관련법상 위임장에는 주민등록번호 전체가 포함되어야 효력이 인정됩니다.',
            style: TextStyle(fontSize: 11),
          ),
        ],
      ),
    ));
    var subContentList = ElevatedButton(
      style: ElevatedButton.styleFrom(
        fixedSize: Size(Get.width - 30, 50),
        primary: const Color(0xFF572E67),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      onPressed: () async {
        onConfirmed();
      },
      child: const Text(
        '등록',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );

    return AppBodyPage(
      titleString: '전자서명',
      helpText: helpText,
      informationString: informationString,
      mainContent: mainContent,
      subContentList: subContentList,
    );
  }
}
