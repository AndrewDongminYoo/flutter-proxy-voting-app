import 'package:flutter/material.dart';
import 'signature.upload.dart';
import 'common_app_body.dart';
import 'package:get/get.dart';

class TakeBackNumberPage extends StatefulWidget {
  const TakeBackNumberPage({Key? key}) : super(key: key);

  @override
  State<TakeBackNumberPage> createState() => _TakeBackNumberPageState();
}

class _TakeBackNumberPageState extends State<TakeBackNumberPage> {
  final CustomSignatureController _controller =
      Get.isRegistered<CustomSignatureController>()
          ? Get.find()
          : Get.put(CustomSignatureController());

  @override
  Widget build(BuildContext context) {
    var thirty = (Get.height) % 3;
    var helpText = '주민등록번호를 입력해주세요.';
    var informationString =
        '입력해주신 주민등록번호는 안전하게 암호화되며 주주명부 확인 및 위임장 작성 용도 이외에는 절대로 활용되지 않습니다. 해당 정보는 주주총회 이후 즉시 폐기됩니다.';
    var mainContent = Column(children: [
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        alignment: Alignment.center,
        foregroundDecoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const TextField(
          obscuringCharacter: '•',
          keyboardType: TextInputType.number,
        ),
      ),
      const Text('관련법상 위임장에는 주민등록번호 전체가 포함되어야 효력이 인정됩니다.'),
    ]);
    return AppBodyPage(
      titleString: "전자서명",
      helpText: helpText,
      informationString: informationString,
      mainContent: mainContent,
      subContentList: const Text(''),
    );
  }
}
