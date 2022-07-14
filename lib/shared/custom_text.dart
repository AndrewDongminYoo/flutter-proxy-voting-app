// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';

enum TypoType {
  h1Title,
  h1Bold,
  h1,
  h2Bold,
  h2,
  body,
  bodyLight,
  bodySmaller,
  label,
  boldLabel
}

class TypoStyle {
  final FontWeight fontWeight;
  final double fontSize;
  final double letterSpacing;

  TypoStyle({
    required this.fontWeight,
    required this.fontSize,
    required this.letterSpacing,
  });
}

final typoStyle = {
  TypoType.h1Title:
      TypoStyle(fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: 0.48),
  TypoType.h1Bold:
      TypoStyle(fontWeight: FontWeight.w800, fontSize: 24, letterSpacing: 0.48),
  TypoType.h1:
      TypoStyle(fontWeight: FontWeight.w700, fontSize: 24, letterSpacing: 0.48),
  TypoType.h2Bold:
      TypoStyle(fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: 0.32),
  TypoType.h2:
      TypoStyle(fontWeight: FontWeight.w400, fontSize: 18, letterSpacing: 0.32),
  TypoType.body:
      TypoStyle(fontWeight: FontWeight.w400, fontSize: 16, letterSpacing: 0.28),
  TypoType.bodyLight:
      TypoStyle(fontWeight: FontWeight.w300, fontSize: 16, letterSpacing: 0.28),
  TypoType.bodySmaller:
      TypoStyle(fontWeight: FontWeight.w300, fontSize: 14, letterSpacing: 0.28),
  TypoType.label:
      TypoStyle(fontWeight: FontWeight.w300, fontSize: 11, letterSpacing: 0.16),
  TypoType.boldLabel:
      TypoStyle(fontWeight: FontWeight.w500, fontSize: 11, letterSpacing: 0.16),
};

class CustomText extends SizedBox {
  final String text;
  final TypoType typoType;
  final TextAlign textAlign;
  final ColorType colorType;
  final bool isFullWidth;
  final bool inherit;

  CustomText({
    Key? key,
    required this.text,
    this.typoType = TypoType.body,
    this.isFullWidth = false,
    this.inherit = true,
    this.textAlign = TextAlign.center,
    this.colorType = ColorType.black,
  }) : super(
          key: key,
          width: isFullWidth ? Get.width : null,
          child: Text(
            text,
            textAlign: textAlign,
            style: TextStyle(
                inherit: inherit,
                color: customColor[colorType],
                fontWeight: typoStyle[typoType]!.fontWeight,
                fontSize: typoStyle[typoType]!.fontSize,
                letterSpacing: typoStyle[typoType]!.letterSpacing),
            overflow: TextOverflow.visible,
          ),
        );
}
