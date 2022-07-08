// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

class LoadingScreen extends Dialog {
  LoadingScreen({Key? key})
      : super(
          key: key,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: Get.width,
            height: Get.height,
            color: Colors.grey.withOpacity(0.7),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
}
