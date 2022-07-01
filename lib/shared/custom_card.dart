// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:bside/theme.dart';

class CustomCard extends StatelessWidget {
  final ColorType bgColor;
  final Widget child;

  const CustomCard({
    Key? key,
    this.bgColor = ColorType.purple,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: customColor[bgColor]),
      child: child,
    );
  }
}
