import 'package:bside/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class EnhanceIcon extends StatelessWidget {
  EnhanceIcon({
    super.key,
    required this.icon,
    this.alignment,
  });

  IconData icon;
  Alignment? alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 45,
      width: 45,
      margin: alignment == Alignment.bottomRight
          ? EdgeInsets.only(left: Get.width * 0.7)
          : null,
      decoration: BoxDecoration(
        color: customColor[ColorType.deepPurple],
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
