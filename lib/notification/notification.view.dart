// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';
import '../shared/shared.dart';
import 'notification.dart';

class NotificaitionPage extends StatefulWidget {
  const NotificaitionPage({Key? key}) : super(key: key);

  @override
  State<NotificaitionPage> createState() => _NotificaitionPageState();
}

class _NotificaitionPageState extends State<NotificaitionPage> {
  final NotificationController _notificaitionCtrl =
      NotificationController.get();

  _onTabNotification(int index) {
    setState(() {
      _notificaitionCtrl.removeNotification(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: '알림', isNoticePage: true),
      body: _notificaitionCtrl.notifications.isEmpty
          ? _noNotification()
          : _listView(),
    );
  }

  Widget _listView() {
    return ListView.builder(
        itemBuilder: (context, index) {
          return InkWell(
              child: _notificationCard(index),
              onTap: () {
                _onTabNotification(index);
              });
        },
        itemCount: _notificaitionCtrl.notifications.length);
  }

  Widget _noNotification() {
    return Center(
        child: SizedBox(
      height: Get.height * 0.5,
      child: Column(
        children: [
          Icon(
            Icons.notifications_rounded,
            color: customColor[ColorType.lightGrey],
            size: Get.height * 0.3,
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
      padding: const EdgeInsets.all(10.0),
      child: CustomCard(
          content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _avatar(),
          Expanded(
              child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: _message(index))),
          CustomText(
              typoType: TypoType.boldLabel,
              text: _notificaitionCtrl.currentTime(
                  _notificaitionCtrl.notifications[index].createdAt))
        ],
      )),
    );
  }

  Widget _avatar() {
    return const CircleAvatar(
      foregroundImage: AssetImage('assets/images/logo.png'),
      radius: 25,
    );
  }

  Widget _message(int index) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(
          typoType: TypoType.body,
          text: _notificaitionCtrl.notifications[index].title),
      CustomText(
          typoType: TypoType.bodyLight,
          text: _notificaitionCtrl.notifications[index].body),
    ]);
  }
}
