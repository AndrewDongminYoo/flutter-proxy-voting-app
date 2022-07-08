// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../get_nav.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const IconButton(
      icon: Icon(
        CupertinoIcons.arrow_left_square,
        color: Colors.white,
      ),
      splashRadius: 20.0,
      iconSize: 24.0,
      tooltip: '뒤로가기',
      onPressed: goBack,
    );
  }
}
