import 'package:get/get.dart';

enum CustomW { w1, w2, w3, w4 }

const gridMargin = 16;
const gridGutter = 10;
final singleWidth = (Get.width - 2 * gridMargin - 3 * gridGutter) / 4;

final customW = {
  CustomW.w1: singleWidth,
  CustomW.w2: singleWidth * 2 + gridGutter,
  CustomW.w3: singleWidth * 3 + gridGutter * 2,
  CustomW.w4: Get.width - 2 * gridMargin,
};
