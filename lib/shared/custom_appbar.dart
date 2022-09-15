// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// 🌎 Project imports:
import '../notification/notification.dart';
import '../theme.dart';
import 'shared.dart';

// 🌎 Project imports:

class CustomAppBar extends AppBar {
  final String text;
  final Color bgColor;
  final bool isNoticePage;
  final Widget? helpButton;
  CustomAppBar({
    Key? key,
    required this.text,
    this.isNoticePage = false,
    this.bgColor = const Color(0xFF572E67),
    this.helpButton,
  }) : super(
          key: key,
          leading: SizedBox(
            width: Get.width,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomBackButton(
                    color: bgColor == Colors.transparent
                        ? const Color(0xFF572E67)
                        : Colors.white),
                CustomText(
                  text: text,
                  typoType: TypoType.body,
                  colorType: ColorType.white,
                ),
              ],
            ),
          ),
          leadingWidth: 200,
          toolbarHeight: 80,
          backgroundColor: bgColor,
          elevation: 0,
          actions: [
            helpButton ??
                (!isNoticePage ? const NotificiationBtn() : const SizedBox())
          ],
        );
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    Key? key,
    this.color = Colors.white,
  }) : super(key: key);

  final Color color;
  @override
  Widget build(BuildContext context) {
    return Navigator.canPop(context)
        ? IconButton(
            key: key,
            icon: Icon(
              CupertinoIcons.arrow_left_square,
              color: color,
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
  final NotiController _notificaitionCtrl = NotiController.get();

  void _onPressNotification() {
    _showAnimatedDialog(
      context: context,
      builder: (BuildContext context) {
        return const NotificaitionCard();
      },
      curve: Curves.fastOutSlowIn,
      duration: const Duration(seconds: 1),
    );
    setState(() {
      _notificaitionCtrl.getNotificationsLocal();
    });
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

Future<T?> _showAnimatedDialog<T extends Object?>({
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
