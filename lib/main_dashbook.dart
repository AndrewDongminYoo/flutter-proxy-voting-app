import 'shared/custom_color.dart';
import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';
import 'package:bside/shared/custom_text.dart';

void main() {
  final dashbook = Dashbook();

  dashbook.storiesOf('Text').decorator(CenterDecorator()).add('default', (ctx) {
    return SizedBox(
        width: 300,
        child: CustomText(
          text: ctx.textProperty("text", "다람쥐 현 쳇바퀴에 타고파"),
          colorType:
              ctx.listProperty("color", ColorType.black, ColorType.values),
          textAlign: ctx.listProperty(
            "text align",
            TextAlign.center,
            TextAlign.values,
          ),
          typoType:
              ctx.listProperty("typoType", TypoType.body, TypoType.values),
        ));
  });

  runApp(dashbook);
}
