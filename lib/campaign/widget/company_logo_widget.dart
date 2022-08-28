// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class CompanyLogoWidget extends StatelessWidget {
  const CompanyLogoWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String assetName = 'assets/images/bside_logo.png';
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 35, 0, 10),
        width: 56,
        height: 20,
        child: Image.asset(assetName),
      ),
    );
  }
}
