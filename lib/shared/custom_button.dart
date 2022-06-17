import 'package:flutter/material.dart';

import 'custom_grid.dart';
import 'custom_color.dart';

class CustomButton extends StatelessWidget {
  final CustomW width;
  final ColorType bgColor;
  final ColorType primaryColor;
  final ColorType textColor;
  final String label;
  final Function() onPressed;

  const CustomButton(
      {Key? key,
      this.width = CustomW.w1,
      this.bgColor = ColorType.deepPurple,
      this.primaryColor = ColorType.purple,
      this.textColor = ColorType.white,
      required this.label,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onPressed,
        child: Container(
            height: 40,
            width: customW[width],
            decoration: BoxDecoration(
                color: customColor[bgColor],
                borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(label,
                  style: TextStyle(
                      color: customColor[textColor],
                      fontSize: 18,
                      fontWeight: FontWeight.w400)),
            )));
  }
}
