import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'custom_grid.dart';
import 'custom_color.dart';

class CustomButton extends StatefulWidget {
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
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Material(
        child: InkWell(
          onTap: widget.onPressed,
          child: Ink(
            height: 55,
            width: customW[widget.width],
            decoration: BoxDecoration(
              color: customColor[widget.bgColor],
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: customColor[widget.textColor],
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomOutlinedButton extends StatefulWidget {
  final CustomW width;
  final ColorType textColor;
  final String label;
  final Function() onPressed;

  const CustomOutlinedButton({
    Key? key,
    this.width = CustomW.w1,
    this.textColor = ColorType.white,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<CustomOutlinedButton> createState() => _CustomOutlinedButtonState();
}

class _CustomOutlinedButtonState extends State<CustomOutlinedButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Ink(
          height: 55,
          width: customW[widget.width],
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: customColor[widget.textColor]!),
              borderRadius: BorderRadius.circular(24)),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                  color: customColor[widget.textColor],
                  fontSize: 18,
                  fontWeight: FontWeight.w400),
            ),
          )),
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final CustomW width;
  final ColorType bgColor;
  final ColorType textColor;
  final String label;
  final Function() onPressed;
  final bool isLoading;

  const AnimatedButton({
    Key? key,
    this.width = CustomW.w4,
    this.bgColor = ColorType.deepPurple,
    this.textColor = ColorType.white,
    required this.label,
    required this.onPressed,
    required this.isLoading,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: MaterialButton(
        onPressed: widget.onPressed,
        elevation: 4.0,
        minWidth: Get.width - 32,
        height: 50.0,
        color: const Color(0xFF572E67),
        child: animatedChild(),
      ),
    );
  }

  Widget animatedChild() {
    if (!widget.isLoading) {
      return Text(
        widget.label,
        style: TextStyle(
          color: customColor[widget.textColor],
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      );
    } else {
      return const CupertinoActivityIndicator(
        color: Colors.white,
      );
    }
  }
}
