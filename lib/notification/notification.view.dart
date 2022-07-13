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
  NotificationController notificaitionCtrl = NotificationController.get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: '알림', isNoticePage: true),
      body: notificaitionCtrl.notifications.isEmpty
          ? noNotification()
          : listView(),
    );
  }

  Widget listView() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return notificationCard(index);
        },
        separatorBuilder: (context, index) {
          return const Divider(height: 0);
        },
        itemCount: notificaitionCtrl.notifications.length);
  }

  Widget noNotification() {
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

  Widget notificationCard(int index) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          avatar(),
          Expanded(
              child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: message(index))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              cancelBtn(index),
              CustomText(
                  typoType: TypoType.boldLabel,
                  text: notificaitionCtrl.currentTime(
                      notificaitionCtrl.notifications[index].createdAt))
            ],
          )
        ],
      ),
    ));
  }

  Widget cancelBtn(int index) {
    return InkWell(
      child: const Icon(Icons.close,
          color: Colors.black, semanticLabel: 'Close modal'),
      onTap: () {
        setState(() {
          notificaitionCtrl.removeNotification(index);
        });
      },
    );
  }

  Widget avatar() {
    return const CircleAvatar(
      foregroundImage: AssetImage('assets/images/logo.png'),
      radius: 25,
    );
  }

  Widget message(int index) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(
          typoType: TypoType.body,
          text: notificaitionCtrl.notifications[index].title),
      CustomText(
          typoType: TypoType.bodyLight,
          text: notificaitionCtrl.notifications[index].body),
    ]);
  }
}
