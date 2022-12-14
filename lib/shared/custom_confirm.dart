// ๐ฆ Flutter imports:
import 'package:flutter/material.dart';

// ๐ฆ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// ๐ Project imports:
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
            semanticLabel: '์ฐฝ ๋ซ๊ธฐ',
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

// JS์ Window.confirm() ์ฐธ๊ณ 
// ํ์ธ ๋ฒํผ์ ๋๋ฅด๋ฉด ํจ์ ์คํ์ ๋ฉ์ธ์ง์ ํจ๊ป ๋ชจ๋ฌ ๋ํ ์์๋ฅผ ๋์๋๋ค.
// CustomWindowConfirm์ ์ ์ฌํ์ง๋ง ๋ชจ๋ฌ์ ์คํํ๋ ๋ฒํผ UI๊น์ง ํฌํจ๋ UI Component.
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

// JS์ Window.confirm() ์ฐธ๊ณ 
// ํจ์ ์คํ์ ๋ฉ์ธ์ง์ ํจ๊ป ๋ชจ๋ฌ ๋ํ ์์๋ฅผ ๋์๋๋ค.
// CustomConfirmWithButton์ ์ ์ฌํ์ง๋ง, ๋ชจ๋ฌ๋ง ๋์ฐ๋ ํจ์.
void customWindowConfirm(
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
