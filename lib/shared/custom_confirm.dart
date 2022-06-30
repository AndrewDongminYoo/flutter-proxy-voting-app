// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';
import 'custom_button.dart';
import 'custom_text.dart';

class CustomConfirm extends StatelessWidget {
  final String buttonLabel;
  final String message;
  final String okLabel;
  final Function() onConfirm;

  const CustomConfirm({
    Key? key,
    required this.buttonLabel,
    required this.message,
    required this.okLabel,
    required this.onConfirm,
  }) : super(key: key);

  onPress() {
    Get.bottomSheet(confirmBody(),
        backgroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)));
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
        label: buttonLabel,
        width: CustomW.w4,
        bgColor: ColorType.deepPurple,
        onPressed: onPress);
  }

  Widget confirmBody() {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(children: [
        const SizedBox(height: 20),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: CustomText(
              text: message,
              typoType: TypoType.h2,
            ),
          ),
          IconButton(
            onPressed: () {
              Get.back();
            },
            splashRadius: 20.0,
            iconSize: 16.0,
            padding: const EdgeInsets.all(0.0),
            constraints: const BoxConstraints(minHeight: 20.0, minWidth: 20.0),
            icon: const Icon(Icons.close,
                color: Colors.black, semanticLabel: '창 닫기'),
          )
        ]),
        const SizedBox(height: 36),
        CustomButton(
          label: okLabel,
          onPressed: onConfirm,
          width: CustomW.w4,
        ),
      ]),
    );
  }
}
