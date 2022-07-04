// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../theme.dart';

class StatusBox extends StatelessWidget {
  const StatusBox({Key? key, required this.text, required this.color})
      : super(key: key);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 25,
      decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.all(Radius.circular(10))),
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
}
