import 'package:bside/theme.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EnhanceIcon extends StatelessWidget {
  EnhanceIcon({
    super.key,
    required this.icon,
  });

  IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: customColor[ColorType.deepPurple],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
