import 'package:bside/shared/custom_color.dart';
import 'package:flutter/material.dart';

enum TypoType { h1Bold, h1, h2Bold, h2, body, bodyLight, label }

class TypoStyle {
  final FontWeight fontWeight;
  final double fontSize;

  TypoStyle({required this.fontWeight, required this.fontSize});
}

final typoStyle = {
  TypoType.h1Bold: TypoStyle(fontWeight: FontWeight.w800, fontSize: 24),
  TypoType.h1: TypoStyle(fontWeight: FontWeight.w700, fontSize: 24),
  TypoType.h2Bold: TypoStyle(fontWeight: FontWeight.w700, fontSize: 18),
  TypoType.h2: TypoStyle(fontWeight: FontWeight.w400, fontSize: 18),
  TypoType.body: TypoStyle(fontWeight: FontWeight.w400, fontSize: 14),
  TypoType.bodyLight: TypoStyle(fontWeight: FontWeight.w300, fontSize: 14),
  TypoType.label: TypoStyle(fontWeight: FontWeight.w300, fontSize: 11),
};

class CustomText extends StatelessWidget {
  const CustomText(
      {Key? key,
      required this.typoType,
      required this.text,
      this.textAlign = TextAlign.center,
      this.colorType = ColorType.black})
      : super(key: key);

  final String text;
  final TypoType typoType;
  final TextAlign textAlign;
  final ColorType colorType;

  @override
  Widget build(BuildContext context) {
    final style = typoStyle[typoType]!;
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: customColor[colorType],
        fontWeight: style.fontWeight,
        fontSize: style.fontSize,
      ),
    );
  }
}
