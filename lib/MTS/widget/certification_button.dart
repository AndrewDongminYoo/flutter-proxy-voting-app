import 'package:flutter/material.dart';

import '../../theme.dart';

class UnderlinedButton extends InkWell {
  final CustomW width;
  final Color textColor;
  final String label;
  final double height;
  final Function() onPressed;

  UnderlinedButton({
    Key? key,
    this.width = CustomW.w1,
    this.height = 58.0,
    this.textColor = Colors.black,
    required this.label,
    required this.onPressed,
  }) : super(
          key: key,
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28.0),
          child: Container(
              height: height,
              width: customW[width],
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black,
                    width: 0.8,
                  ),
                ),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )),
        );
}
