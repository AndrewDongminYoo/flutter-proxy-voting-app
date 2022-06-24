import 'package:flutter/material.dart';

import 'custom_grid.dart';
import 'custom_color.dart';

class CustomButton extends StatelessWidget {
  final CustomW width;
  final ColorType bgColor;
  final ColorType textColor;
  final String label;
  final Function() onPressed;

  const CustomButton(
      {Key? key,
      this.width = CustomW.w4,
      this.bgColor = ColorType.deepPurple,
      this.textColor = ColorType.white,
      required this.label,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        child: InkWell(
          onTap: onPressed,
          child: Ink(
              height: 55,
              width: customW[width],
              decoration: BoxDecoration(
                  color: customColor[bgColor],
                  borderRadius: BorderRadius.circular(24)),
              child: Center(
                child: Text(label,
                    style: TextStyle(
                        color: customColor[textColor],
                        fontSize: 18,
                        fontWeight: FontWeight.w400)),
              )),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatelessWidget {
  final CustomW width;
  final ColorType textColor;
  final String label;
  final Function() onPressed;

  const CustomOutlinedButton(
      {Key? key,
      this.width = CustomW.w1,
      this.textColor = ColorType.white,
      required this.label,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
          height: 55,
          width: customW[width],
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: customColor[textColor]!),
              borderRadius: BorderRadius.circular(24)),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  color: customColor[textColor],
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
          )),
    );
  }
}
