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
    var prefixText = "999999999";
    var mainContent = Expanded(
        child: Container(
      // margin: const EdgeInsets.symmetric(horizontal: 20),
      // padding: const EdgeInsets.symmetric(horizontal: 30),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 40,
            margin: EdgeInsets.all(7),
            decoration: BoxDecoration(
              border: Border.all(width: 3),
              borderRadius: const BorderRadius.all(
                Radius.circular(30),
              ),
            ),
            child: TextField(
                textAlign: TextAlign.center,
                textAlignVertical: TextAlignVertical.bottom,
                obscuringCharacter: '●',
                keyboardType: TextInputType.number,
                autofocus: true,
                onChanged: ((input) {}),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 5,
                      )),
                  hintText: '주민등록번호를 입력해주세요.',
                )),
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
        // TODO: 완료된 사인 업로드하고 유저 정보에 입력하고 다음 페이지 넘어가기
        // await _showSignature(context);
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
      titleString: "전자서명",
      helpText: helpText,
      informationString: informationString,
      mainContent: mainContent,
      subContentList: subContentList,
    );
  }
}
