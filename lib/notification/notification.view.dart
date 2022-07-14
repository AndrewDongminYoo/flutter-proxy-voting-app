import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

// 🌎 Project imports:
import '../theme.dart';
import '../shared/shared.dart';
import 'notification.dart';

class NotificaitionCard extends StatefulWidget {
  const NotificaitionCard({Key? key}) : super(key: key);

  @override
  State<NotificaitionCard> createState() => _NotificaitionCardState();
}

class _NotificaitionCardState extends State<NotificaitionCard> {
  final NotificationController _notificaitionCtrl =
      NotificationController.get();

  onTapCancel() {
    Navigator.of(context).pop();
  }

  _onTabNotification(int index) {
    setState(() {
      _notificaitionCtrl.removeNotification(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: customColor[ColorType.deepPurple]!, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            _notificaitionCtrl.notifications.isEmpty
                ? _noNotification()
                : _listView(),
            IconButton(
              icon: const Icon(Icons.cancel_outlined),
              iconSize: 48,
              color: customColor[ColorType.deepPurple],
              onPressed: onTapCancel,
            )
          ],
        ));
  }

  Widget _listView() {
    return SizedBox(
      height: Get.height * 0.5,
      child: ListView.builder(
          itemBuilder: (context, index) {
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
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: Column(children: [
        Divider(color: customColor[ColorType.deepPurple]),
        Stack(children: [
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
        Divider(color: customColor[ColorType.deepPurple]),
      ]),
    );
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
