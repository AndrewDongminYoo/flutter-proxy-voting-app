// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import '../auth/auth.controller.dart';
import '../vote/vote.controller.dart';
import 'sign_appbody.dart';

class TakeBackNumberPage extends StatefulWidget {
  const TakeBackNumberPage({Key? key}) : super(key: key);

  @override
  State<TakeBackNumberPage> createState() => _TakeBackNumberPageState();
}

class _TakeBackNumberPageState extends State<TakeBackNumberPage> {
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());
  late String frontId = '';
  late String backId = '1';

  @override
  void initState() {
    if (authCtrl.isLogined) {
      frontId = authCtrl.user.frontId;
      backId = authCtrl.user.backId;
    }
    super.initState();
  }

  onConfirmed() {
    if (backId.length == 7) {
      authCtrl.putBackId(backId);
      voteCtrl.trackBackId();
      jumpToResult();
    }
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
          Padding(
            padding: const EdgeInsets.all(8),
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.black,
                          width: 4,
                          style: BorderStyle.solid,
                        ),
                      ),
                      labelText: '생년월일',
                    ),
                  ),
                ),
                CustomText(
                  text: '  -  ',
                  typoType: TypoType.h1Bold,
                ),
                SizedBox(
                  width: Get.width / 2,
                  child: TextFormField(
                    maxLength: 7,
                    decoration: const InputDecoration(
                        labelText: '주민등록번호 뒷자리',
                        border: OutlineInputBorder(),
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
          CustomText(
            text: '관련법상 위임장에는 주민등록번호 전체가 포함되어야 효력이 인정됩니다.',
            typoType: TypoType.label,
          ),
        ],
      ),
    ));
    var subContentList = CustomButton(
      label: '등록',
      onPressed: onConfirmed,
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
