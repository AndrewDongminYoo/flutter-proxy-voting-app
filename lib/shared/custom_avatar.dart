import 'package:flutter/material.dart';

import '../theme.dart';

class Avatar extends Align {
  final Alignment align;
  final String image;
  final double radius;
  final Color backgroundColor;

  Avatar(
      {Key? key,
      required this.image,
      required this.radius,
      this.align = Alignment.center,
      this.backgroundColor = const Color(0xFFFFE0E9)})
      : super(
          key: key,
          alignment: align,
          child: CircleAvatar(
            foregroundImage: NetworkImage(image),
            radius: radius,
            backgroundColor: customColor[ColorType.white],
          ),
        );
}
