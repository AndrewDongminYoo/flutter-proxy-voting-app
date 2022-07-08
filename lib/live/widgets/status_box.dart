// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
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
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: customColor[ColorType.white],
              ),
            ),
          ),
        );
}
