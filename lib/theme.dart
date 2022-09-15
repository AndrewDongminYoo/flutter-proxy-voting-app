// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

const int _gridMargin = 16;
const int _gridGutter = 10;
final double _singleWidth = (Get.width - 2 * _gridMargin - 3 * _gridGutter) / 4;

enum CustomW { w1, w2, w3, w4 }

final Map<CustomW, double> customW = {
  CustomW.w1: _singleWidth,
  CustomW.w2: _singleWidth * 2 + _gridGutter,
  CustomW.w3: _singleWidth * 3 + _gridGutter * 2,
  CustomW.w4: Get.width - 2 * _gridMargin,
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
  white54,
  black,
  red
}

final Map<ColorType, Color> customColor = {
  ColorType.deepPurple: const Color(0xFF572E66),
  ColorType.purple: const Color(0xFF7C299A),
  ColorType.orange: const Color(0xFFDC721E),
  ColorType.yellow: const Color(0xFFEEB304),
  ColorType.blue: const Color(0xFF1054DB),
  ColorType.grey: const Color(0xFFAAAAAA),
  ColorType.lightGrey: const Color(0xFFE9E9E9),
  ColorType.white: const Color(0xFFFFFFFF),
  ColorType.white54: const Color(0x89FFFFFF),
  ColorType.black: const Color(0xFF1C2833),
  ColorType.red: const Color(0xFFC70039),
};
