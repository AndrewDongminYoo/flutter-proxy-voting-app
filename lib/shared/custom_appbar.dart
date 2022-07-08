// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'get_nav.dart';

class CustomAppBar extends AppBar {
  final String text;
  final Color bgColor;
  final bool withoutBack;
  CustomAppBar({
    Key? key,
    required this.text,
    this.bgColor = const Color(0xFF572E67),
    this.withoutBack = false,
  }) : super(
          key: key,
          leading: SizedBox(
            width: Get.width,
            child: withoutBack
                ? Container()
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CustomBackButton(),
                      Text(text,
                          style: const TextStyle(
                            color: Colors.white,
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

  @override
  Size get preferredSize {
    return const Size.fromHeight(56.0);
  }
}

class CustomBackButton extends IconButton {
  const CustomBackButton({
    Key? key,
  }) : super(
          key: key,
          icon: const Icon(
            CupertinoIcons.arrow_left_square,
            color: Colors.white,
          ),
          splashRadius: 20.0,
          iconSize: 24.0,
          tooltip: '뒤로가기',
          onPressed: goBack,
        );
}

class NoticeButton extends IconButton {
  NoticeButton({
    Key? key,
  }) : super(
          key: key,
          icon: const Icon(Icons.notifications_rounded),
          onPressed: () {
            // TODO: 알림 탭 구현
          },
        );
}
