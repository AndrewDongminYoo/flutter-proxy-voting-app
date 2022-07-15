// ignore_for_file: must_be_immutable

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../theme.dart';
import 'linear_percent_indicator.dart';

class HorizontalProgressBar extends LinearPercentIndicator {
  var color = Colors.transparent;
  var value = 0.0;

  HorizontalProgressBar({
    Key? key,
    required this.value,
    required this.color,
  }) : super(
          key: key,
          padding: EdgeInsets.zero,
          backgroundColor: customColor[ColorType.black],
          percent: value,
          animation: true,
          animationDuration: 500,
          lineHeight: 20,
          barRadius: const Radius.circular(12),
          progressColor: color,
        );
}

class VerticalProgressBar extends SizedBox {
  var color = Colors.transparent;
  var value = 0.0;

  VerticalProgressBar({
    Key? key,
    required this.value,
    required this.color,
    required int height,
  }) : super(
          key: key,
          child: RotatedBox(
            quarterTurns: 3,
            child: LinearPercentIndicator(
              padding: EdgeInsets.zero,
              backgroundColor: customColor[ColorType.white],
              percent: value,
              animation: true,
              animationDuration: 500,
              lineHeight: 30,
              barRadius: const Radius.circular(8),
              progressColor: color,
            ),
          ),
        );
}
