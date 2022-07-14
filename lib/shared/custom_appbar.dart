// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

// 🌎 Project imports:

import '../notification/notification.dart';
import '../theme.dart';
import 'shared.dart';

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
  final _notificaitionCtrl = NotificationController.get();

  _onPressNotification() {
    _showAnimatedDialog(
      context: context,
      builder: (BuildContext context) {
        return const NotificaitionCard();
      },
      curve: Curves.fastOutSlowIn,
      duration: const Duration(seconds: 1),
    );
    if (_notificaitionCtrl.encodedPushAlrams.isNotEmpty) {
      _notificaitionCtrl.getNotificationsLocal();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.notifications_rounded),
      color: customColor[ColorType.white],
      onPressed: _onPressNotification,
    );
  }
}

_showAnimatedDialog<T extends Object?>({
  required BuildContext context,
  bool barrierDismissible = true,
  required WidgetBuilder builder,
  Curve curve = Curves.linear,
  Duration? duration,
  Alignment alignment = Alignment.center,
  Color? barrierColor,
  Axis? axis = Axis.horizontal,
}) {
  assert(debugCheckHasMaterialLocalizations(context));

  final ThemeData theme = Theme.of(context);

  return showGeneralDialog(
    context: context,
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      final Widget pageChild = Builder(builder: builder);
      return SafeArea(
        top: false,
        child: Builder(builder: (BuildContext context) {
          return Theme(data: theme, child: pageChild);
        }),
      );
    },
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    transitionDuration: duration ?? const Duration(milliseconds: 400),
    transitionBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return Wrap(
        children: [
          SlideTransition(
            transformHitTests: false,
            position: Tween<Offset>(
              begin: const Offset(0.0, -1.0),
              end: const Offset(0.0, 0),
            ).chain(CurveTween(curve: curve)).animate(animation),
            child: child,
          ),
        ],
      );
    },
  );
}
