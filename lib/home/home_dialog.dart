import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../shared/custom_text.dart';
import '../shared/custom_button.dart';
import '../shared/custom_grid.dart';

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
      alignment: Alignment.bottomCenter,
      insetPadding: EdgeInsets.zero,
      titlePadding: const EdgeInsets.fromLTRB(24, 5, 24, 10),
      title: Row(
        children: [
          const Expanded(
            child: CustomText(
              // text: '서비스 이용을 위해\n본인인증이 필요해요.',
              text: '오픈 준비중입니다',
              typoType: TypoType.h2,
            ),
          ),
          IconButton(
            onPressed: onClose,
            iconSize: 16.0,
            icon: const Icon(Icons.close,
                color: Colors.black, semanticLabel: '창 닫기'),
          )
        ],
      ),
      // content: CustomButton(label: '인증하러가기', onPressed: onPressed),
      content: CustomButton(
        label: '확인',
        onPressed: onPressed,
        width: CustomW.w4,
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    );
  }
}
