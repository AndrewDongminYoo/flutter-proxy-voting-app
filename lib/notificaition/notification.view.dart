// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/custom_appbar.dart';
import '../shared/custom_text.dart';
import 'notification.controller.dart';

class NotificaitionPage extends StatefulWidget {
  const NotificaitionPage({Key? key}) : super(key: key);

  @override
  State<NotificaitionPage> createState() => _NotificaitionPageState();
}

class _NotificaitionPageState extends State<NotificaitionPage> {
  NotificationController notificaitionCtrl =
      Get.isRegistered<NotificationController>()
          ? Get.find()
          : Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: '알림', isNoticePage: true),
      body: listView(),
    );
  }

  Widget listView() {
    return ListView.separated(
        itemBuilder: (context, index) {
          return listViewItem(index);
        },
        separatorBuilder: (context, index) {
          return const Divider(height: 0);
        },
        itemCount: notificaitionCtrl.notifications.length);
  }

  Widget listViewItem(int index) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          avatar(),
          Expanded(
              child: Container(
            margin: const EdgeInsets.only(left: 10),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              message(index),
              CustomText(
                  typoType: TypoType.bodyLight,
                  text: notificaitionCtrl.currentTime(
                      notificaitionCtrl.notifications[index].createdAt)),
            ]),
          )),
          IconButton(
            icon: const Icon(Icons.close,
                color: Colors.black, semanticLabel: 'Close modal'),
            onPressed: () {
              setState(() {
                notificaitionCtrl.removeNotification(index);
              });
            },
          )
        ],
      ),
    );
  }

  Widget avatar() {
    return const CircleAvatar(
      foregroundImage: AssetImage('assets/images/logo.png'),
      radius: 25,
    );
  }

  Widget message(int index) {
    return CustomText(
        typoType: TypoType.body,
        text: notificaitionCtrl.notifications[index].title);
  }
}
