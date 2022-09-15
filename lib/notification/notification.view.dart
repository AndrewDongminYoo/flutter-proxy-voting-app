// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import '../theme.dart';
import 'notification.dart';

class NotificaitionCard extends StatefulWidget {
  const NotificaitionCard({Key? key}) : super(key: key);

  @override
  State<NotificaitionCard> createState() => _NotificaitionCardState();
}

class _NotificaitionCardState extends State<NotificaitionCard> {
  final NotiController _notificaitionCtrl = NotiController.get();

  void onTapCancel() {
    Navigator.of(context).pop();
  }

  void _onTabNotification(int index) {
    setState(() {
      _notificaitionCtrl.removeNotification(index);
      _notificaitionCtrl.getNotificationsLocal();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: customColor[ColorType.deepPurple]!, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          child: Column(
            children: [
              _notificaitionCtrl.notifications.isEmpty
                  ? _noNotification()
                  : _listView(),
              Divider(height: 0, color: customColor[ColorType.deepPurple]),
              IconButton(
                icon: const Icon(Icons.cancel_outlined),
                iconSize: 48,
                color: customColor[ColorType.deepPurple],
                onPressed: onTapCancel,
              )
            ],
          ),
        ));
  }

  Widget _listView() {
    return SizedBox(
      height: Get.height * 0.5,
      child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
                child: _notificationCard(index),
                onTap: () {
                  _onTabNotification(index);
                });
          },
          itemCount: _notificaitionCtrl.notifications.length),
    );
  }

  Widget _noNotification() {
    return Center(
        child: SizedBox(
      height: Get.height * 0.5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_rounded,
            color: customColor[ColorType.lightGrey],
            size: Get.height * 0.1,
          ),
          CustomText(
            text: '새로운 소식이 없습니다.',
            typoType: TypoType.body,
          )
        ],
      ),
    ));
  }

  Widget _notificationCard(int index) {
    return Column(children: [
      Divider(height: 0, color: customColor[ColorType.deepPurple]),
      Padding(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: Stack(children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(),
              Expanded(
                  child: Container(
                      margin: const EdgeInsets.only(left: 10),
                      child: _message(index))),
            ],
          ),
          Positioned(
              right: 0,
              child: CustomText(
                  typoType: TypoType.boldLabel,
                  text: _notificaitionCtrl.currentTime(
                      _notificaitionCtrl.notifications[index].createdAt)))
        ]),
      ),
      Divider(height: 0, color: customColor[ColorType.deepPurple]),
    ]);
  }

  Widget _avatar() {
    return const CircleAvatar(
      foregroundImage: AssetImage('assets/images/logo.png'),
      radius: 16,
    );
  }

  Widget _message(int index) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(
          typoType: TypoType.body,
          text: _notificaitionCtrl.notifications[index].title),
      CustomText(
          textAlign: TextAlign.start,
          typoType: TypoType.bodyLight,
          text: _notificaitionCtrl.notifications[index].body),
    ]);
  }
}
