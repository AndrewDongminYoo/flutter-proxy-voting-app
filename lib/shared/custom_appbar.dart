// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:

import '../notification/notification.dart';
import '../theme.dart';
import 'shared.dart';
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
  // TODO: offNamed로 결과페이지에 도달했을 때, 사실상 동작하지 않는 뒤로가기 버튼이 여전히 보임.
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
  NotificationController notificaitionCtrl =
      Get.isRegistered<NotificationController>()
          ? Get.find()
          : Get.put(NotificationController());
  onPressIconBtn() {
    goToNotificationPage();
    if (notificaitionCtrl.encodedPushAlrams.isNotEmpty) {
      notificaitionCtrl.getNotificationsLocal();
    }
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
