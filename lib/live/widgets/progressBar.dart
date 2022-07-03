import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../theme.dart';

class HorizontalProgressBar extends StatelessWidget {
  const HorizontalProgressBar(
      {Key? key, required this.value, required this.color})
      : super(key: key);

  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LinearPercentIndicator(
        padding: EdgeInsets.zero,
        backgroundColor: customColor[ColorType.black],
        percent: value,
        animation: true,
        animationDuration: 500,
        lineHeight: 20,
        barRadius: const Radius.circular(12),
        progressColor: color);
  }
}

class VerticalProgressBar extends StatelessWidget {
  const VerticalProgressBar(
      {Key? key,
      required this.value,
      required this.color,
      required this.height})
      : super(key: key);

  final double value;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
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
            progressColor: color),
      ),
    );
  }
}
