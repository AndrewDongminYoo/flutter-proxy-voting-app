// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:

import '../notification/notification.dart';
import '../theme.dart';
import 'shared.dart';

// ignore: must_be_immutable
class CustomAppBar extends AppBar {
  final String text;
  final Color bgColor;
  final bool isNoticePage;
  CustomAppBar({
    Key? key,
    required this.text,
    this.isNoticePage = false,
    this.bgColor = const Color(0xFF572E67),
  }) : super(
          key: key,
          leading: SizedBox(
            width: Get.width,
            child: Row(
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
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Navigator.canPop(context)
        ? IconButton(
            key: key,
            icon: const Icon(
              CupertinoIcons.arrow_left_square,
              color: Colors.white,
            ),
            splashRadius: 20.0,
            iconSize: 24.0,
            tooltip: '뒤로가기',
            onPressed: goBack,
          )
        : const SizedBox(
            height: 24.0,
            width: 24.0,
          );
  }
}

class NotificiationBtn extends StatefulWidget {
  const NotificiationBtn({Key? key}) : super(key: key);

  @override
  State<NotificiationBtn> createState() => _NotificiationBtnState();
}

class _NotificiationBtnState extends State<NotificiationBtn> {
  final NotificationController _notificaitionCtrl =
      NotificationController.get();
  _onPressIconBtn() {
    goToNotificationPage();
    if (_notificaitionCtrl.encodedPushAlrams.isNotEmpty) {
      _notificaitionCtrl.getNotificationsLocal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_rounded),
      color: customColor[ColorType.white],
      onPressed: _onPressIconBtn,
    );
  }
}
