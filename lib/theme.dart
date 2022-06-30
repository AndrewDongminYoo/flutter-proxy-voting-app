// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

const gridMargin = 16;
const gridGutter = 10;
final singleWidth = (Get.width - 2 * gridMargin - 3 * gridGutter) / 4;

enum CustomW { w1, w2, w3, w4 }

final customW = {
  CustomW.w1: singleWidth,
  CustomW.w2: singleWidth * 2 + gridGutter,
  CustomW.w3: singleWidth * 3 + gridGutter * 2,
  CustomW.w4: Get.width - 2 * gridMargin,
};

enum ColorType {
  deepPurple,
  purple,
  orange,
  yellow,
  blue,
  grey,
  lightGrey,
  white,
  black
}

final customColor = {
  ColorType.deepPurple: const Color(0xFF572E66),
  ColorType.purple: const Color(0xFF7C299A),
  ColorType.orange: const Color(0xFFDC721E),
  ColorType.yellow: const Color(0xFFEEB304),
  ColorType.blue: const Color(0xFF1054DB),
  ColorType.grey: const Color(0xFFAAAAAA),
  ColorType.lightGrey: const Color(0xFFE9E9E9),
  ColorType.white: const Color(0xFFFFFFFF),
};
