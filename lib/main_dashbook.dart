import 'package:dashbook/dashbook.dart';
import 'package:flutter/material.dart';

import 'shared/custom_text.dart';
import 'shared/custom_grid.dart';
import 'shared/custom_color.dart';
import 'shared/custom_button.dart';

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

  dashbook.storiesOf('Button').decorator(CenterDecorator()).add('default',
      (ctx) {
    return CustomButton(
      onPressed: () {},
      label: ctx.textProperty("text", "버튼"),
      width: ctx.listProperty("width", CustomW.w1, CustomW.values),
      bgColor:
          ctx.listProperty("bgColor", ColorType.deepPurple, ColorType.values),
      primaryColor: ctx.listProperty(
        "primaryColor",
        ColorType.purple,
        ColorType.values,
      ),
      textColor: ctx.listProperty(
        "typoType",
        ColorType.white,
        ColorType.values,
      ),
    );
  });

  runApp(dashbook);
}
