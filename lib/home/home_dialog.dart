import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../shared/custom_text.dart';
import '../shared/custom_button.dart';

class HomeDialog extends StatelessWidget {
  const HomeDialog({Key? key}) : super(key: key);

  void onClose() {
    Get.back();
  }

  void onPressed() {
    // Get.toNamed('/signup');
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomText(
            // text: '서비스 이용 전에 간단한\n회원가입이 필요해요',
            text: '오픈 준비중입니다',
            typoType: TypoType.h2,
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close,
                color: Colors.black, semanticLabel: '창 닫기'),
          )
        ],
      ),
      // content: CustomButton(label: '회원가입', onPressed: onPressed),
      content: CustomButton(label: '확인', onPressed: onPressed),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
}
