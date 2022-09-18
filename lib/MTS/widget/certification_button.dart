// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart';

// 🌎 Project imports:
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

void showActions(
  BuildContext context,
  List<UnderlinedButton> actions,
) {
  Get.bottomSheet(Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 80,
    ),
    height: Get.height * 0.5,
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: actions,
      ),
    ),
  ));
}
