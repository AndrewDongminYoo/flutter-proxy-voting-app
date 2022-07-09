// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_reaction_button/flutter_reaction_button.dart';

// 🌎 Project imports:
import '../../shared/custom_text.dart';
import '../../theme.dart';

final reactions = [
  Reaction<String>(
    value: 'happy',
    title: _buildTitle('기쁨'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/smile-face.gif'),
    icon: _buildReactionsIcon(
      'assets/images/smile-face.gif',
    ),
  ),
  Reaction<String>(
    value: 'angry',
    title: _buildTitle('화남'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/angry-face.gif'),
    icon: _buildReactionsIcon(
      'assets/images/angry-face.gif',
    ),
  ),
  Reaction<String>(
    value: 'love',
    title: _buildTitle('사랑'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/love-face.gif'),
    icon: _buildReactionsIcon(
      'assets/images/love-face.gif',
    ),
  ),
  Reaction<String>(
    value: 'sad',
    title: _buildTitle('슬픔'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/sad-face.gif'),
    icon: _buildReactionsIcon(
      'assets/images/sad-face.gif',
    ),
  ),
  Reaction<String>(
    value: 'surprise',
    title: _buildTitle('놀람'),
    previewIcon: _buildReactionsPreviewIcon('assets/images/flushed-face.gif'),
    icon: _buildReactionsIcon(
      'assets/images/flushed-face.gif',
    ),
  ),
];

Container _buildTitle(String title) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7.5, vertical: 2.5),
    decoration: BoxDecoration(
      color: Colors.red,
      borderRadius: BorderRadius.circular(15),
    ),
    child: CustomText(
      text: title,
      typoType: TypoType.boldLabel,
      colorType: ColorType.white,
    ),
  );
}

Padding _buildReactionsPreviewIcon(String path) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 5),
    child: Image.asset(path, height: 30),
  );
}

Image _buildReactionsIcon(String path) {
  return Image.asset(path, height: 20);
}
