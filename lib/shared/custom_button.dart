// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';

class CustomButton extends ClipRRect {
  final ColorType bgColor;
  final ColorType textColor;
  final String label;
  final CustomW width;
  final double height;
  final double fontSize;
  final Function() onPressed;

  CustomButton({
    Key? key,
    this.width = CustomW.w4,
    this.bgColor = ColorType.deepPurple,
    this.textColor = ColorType.white,
    this.fontSize = 20,
    this.height = 55.0,
    required this.label,
    required this.onPressed,
  }) : super(
          key: key,
          borderRadius: BorderRadius.circular(28.0),
          child: Material(
            child: InkWell(
              onTap: onPressed,
              child: Ink(
                height: height,
                width: customW[width],
                decoration: BoxDecoration(
                  color: customColor[bgColor],
                  borderRadius: BorderRadius.circular(28.0),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: customColor[textColor],
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
}

class CustomOutlinedButton extends InkWell {
  final CustomW width;
  final ColorType textColor;
  final String label;
  final double height;
  final Function() onPressed;

  CustomOutlinedButton({
    Key? key,
    this.width = CustomW.w1,
    this.height = 55.0,
    this.textColor = ColorType.white,
    required this.label,
    required this.onPressed,
  }) : super(
          key: key,
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28.0),
          child: Ink(
              height: height,
              width: customW[width],
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: customColor[textColor]!,
                ),
                borderRadius: BorderRadius.circular(28.0),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: customColor[textColor],
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )),
        );
}

class AnimatedButton extends ClipRRect {
  final CustomW width;
  final double height;
  final ColorType bgColor;
  final ColorType textColor;
  final String label;
  final Function() onPressed;
  bool isLoading = false;

  AnimatedButton({
    super.key,
    this.width = CustomW.w4,
    this.height = 55.0,
    this.bgColor = ColorType.deepPurple,
    this.textColor = ColorType.white,
    required this.label,
    required this.onPressed,
    bool isLoading = false,
  }) : super(
          borderRadius: BorderRadius.circular(28.0),
          child: MaterialButton(
            onPressed: () async {
              isLoading = true;
              await onPressed();
              isLoading = false;
            },
            elevation: 4.0,
            minWidth: Get.width - 32,
            height: 55.0,
            color: const Color(0xFF572E67),
            child: (!isLoading
                ? Text(
                    label,
                    style: TextStyle(
                      color: customColor[textColor],
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                : const CupertinoActivityIndicator(
                    color: Colors.white,
                  )),
          ),
        );
}

class StepperButton extends ElevatedButton {
  final bool active;

  StepperButton({
    Key? key,
    required this.active,
  }) : super(
          key: key,
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(20, 20),
            primary:
                !active ? const Color(0xFFDC721E) : const Color(0xFF572E67),
            shape: const CircleBorder(),
          ),
          child: !active
              ? const Icon(
                  Icons.warning_amber_sharp,
                  color: Colors.white,
                )
              : const Icon(
                  Icons.check,
                  color: Colors.white,
                ),
        );
}
