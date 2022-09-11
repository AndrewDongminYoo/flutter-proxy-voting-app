// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

class LoadingScreen extends Dialog {
  LoadingScreen({
    Key? key,
  }) : super(
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
