// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class Unfocused extends Builder {
  final Widget child;

  Unfocused({
    Key? key,
    required this.child,
  }) : super(
          key: key,
          builder: (context) {
            return GestureDetector(
              key: key,
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              child: child,
            );
          },
        );
}
