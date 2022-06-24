import 'package:get/get.dart';
// import 'notice_button.dart';
import 'package:flutter/material.dart';

import '../shared/back_button.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color bgColor;
  const CustomAppBar({
    Key? key,
    required this.title,
    this.bgColor = const Color(0xFF572E67),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: SizedBox(
        width: Get.width,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CustomBackButton(),
            Text(title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ))
          ],
        ),
      ),
      leadingWidth: 200,
      toolbarHeight: 80,
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
