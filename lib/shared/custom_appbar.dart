// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:

import '../theme.dart';
import 'custom_text.dart';
import 'custom_nav.dart';
// import 'notice_button.dart';

class CustomAppBar extends AppBar {
  final String text;
  final Color bgColor;
  final bool withoutBack;
  final bool isNoticePage;

  CustomAppBar({
    Key? key,
    required this.text,
    this.isNoticePage = false,
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
                      CustomText(
                          text: text,
                          typoType: TypoType.body,
                          colorType: ColorType.white),
                    ],
                  ),
          ),
          leadingWidth: 200,
          toolbarHeight: 80,
          backgroundColor: bgColor,
          elevation: 0,
          actions: [
            !isNoticePage ? const NotificiationBtn() : const SizedBox()
          ],
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

class NotificiationBtn extends StatefulWidget {
  const NotificiationBtn({Key? key}) : super(key: key);

  @override
  State<NotificiationBtn> createState() => _NotificiationBtnState();
}

class _NotificiationBtnState extends State<NotificiationBtn> {
  onPressIconBtn() {
    goToNotificationPage();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_rounded),
      color: customColor[ColorType.white],
      onPressed: onPressIconBtn,
    );
  }
}
