import 'custom_text.dart';
// import 'notice_button.dart';
import 'package:flutter/material.dart';

import '../shared/back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color bgColor;
  const CustomAppBar(
      {Key? key, required this.title, this.bgColor = const Color(0xFF572E67)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const CustomBackButton(),
        CustomText(text: title, typoType: TypoType.h2Bold)
      ]),
      leadingWidth: 106,
      backgroundColor: bgColor,
      elevation: 0,
      // actions: const [
      //   NoticeButton(),
      // ],
    );
  }

  @override
  Size get preferredSize {
    return const Size.fromHeight(56.0);
  }
}