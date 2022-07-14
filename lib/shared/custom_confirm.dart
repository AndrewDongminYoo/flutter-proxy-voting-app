// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';
import 'shared.dart';

Widget confirmBody(String message, String okLabel, void Function() onConfirm) {
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
          onPressed: onConfirm,
          splashRadius: 20.0,
          iconSize: 16.0,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(
            minHeight: 20.0,
            minWidth: 20.0,
          ),
          icon: const Icon(
            Icons.close,
            color: Colors.black,
            semanticLabel: '창 닫기',
          ),
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

// JS의 Window.confirm() 참고
// 확인 버튼을 누르면 함수 실행시 메세지와 함께 모달 대화 상자를 띄웁니다.
// CustomWindowConfirm와 유사하지만 모달을 실행하는 버튼 UI까지 포함된 UI Component.
class CustomConfirmWithButton extends StatelessWidget {
  final String buttonLabel;
  final String message;
  final String okLabel;
  final Function() onConfirm;

  const CustomConfirmWithButton({
    Key? key,
    required this.buttonLabel,
    required this.message,
    required this.okLabel,
    required this.onConfirm,
  }) : super(key: key);

  _onPress() {
    customWindowConfirm(message, okLabel, onConfirm);
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
        label: buttonLabel,
        width: CustomW.w4,
        bgColor: ColorType.deepPurple,
        onPressed: _onPress);
  }
}

// JS의 Window.confirm() 참고
// 함수 실행시 메세지와 함께 모달 대화 상자를 띄웁니다.
// CustomConfirmWithButton와 유사하지만, 모달만 띄우는 함수.
customWindowConfirm(
  String message,
  String okLabel,
  void Function() onConfirm,
) {
  Get.bottomSheet(
    confirmBody(message, okLabel, onConfirm),
    backgroundColor: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );
}
