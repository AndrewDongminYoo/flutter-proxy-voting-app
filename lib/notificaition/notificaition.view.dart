// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../shared/custom_appbar.dart';
import '../shared/custom_text.dart';

class NotificaitionPage extends StatefulWidget {
  const NotificaitionPage({Key? key}) : super(key: key);

  @override
  State<NotificaitionPage> createState() => _NotificaitionPageState();
}

class _NotificaitionPageState extends State<NotificaitionPage> {
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
        itemCount: 15);
  }

  Widget listViewItem(int index) {
    return Container(
      margin: const EdgeInsets.only(left: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Avatar(image:'images/logo.png'),
          message(index),
          timeAndDate(index)
        ],
      ),
    );
  }

  Widget message(int index) {
    return CustomText(typoType: TypoType.body, text: 'test');
  }

  Widget timeAndDate(int index) {
    return Container(
      margin: const EdgeInsets.only(top: 5),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CustomText(typoType: TypoType.bodyLight, text: '23-01-2021'),
        CustomText(typoType: TypoType.bodyLight, text: '07:10')
      ]),
    );
  }
}
