// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        CupertinoIcons.arrow_left_square,
        color: Colors.white,
      ),
      splashRadius: 20.0,
      iconSize: 24.0,
      tooltip: '뒤로가기',
      onPressed: () => Get.back(),
    );
  }
}
