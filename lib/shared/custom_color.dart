import 'package:flutter/material.dart';

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
