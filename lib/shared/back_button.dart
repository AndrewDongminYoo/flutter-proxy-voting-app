import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(
        IconData(
          0xf05bc,
          fontFamily: 'MaterialIcons',
        ),
      ),
      tooltip: "뒤로가기",
      onPressed: () => Get.back(),
    );
  }
}
