import 'package:flutter/material.dart';

import '../theme.dart';
class Avatar extends StatelessWidget {
  final String image;
  final double radius;
  final Color backgroundColor;
  final Alignment alignment;

  const Avatar({
    Key? key,
    required this.image,
    required this.radius,
    this.alignment = Alignment.center,
    this.backgroundColor = const Color(0xFFFFE0E9)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: CircleAvatar(
        foregroundImage: NetworkImage(image),
        radius: radius,
        backgroundColor: customColor[ColorType.white],
      ),
    );
  }
}
