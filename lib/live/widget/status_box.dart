// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../shared/custom_text.dart';
import '../../theme.dart';

class StatusBox extends Container {
  final String text;
  final Color boxColor;

  StatusBox({
    Key? key,
    required this.text,
    required this.boxColor,
  }) : super(
          key: key,
          width: 60,
          height: 25,
          decoration: BoxDecoration(
            color: boxColor,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Center(
            child: CustomText(
              text: text,
              colorType: ColorType.white,
              typoType: TypoType.label,
            ),
          ),
        );
}
