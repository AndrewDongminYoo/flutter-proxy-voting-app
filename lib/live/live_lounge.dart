// 🎯 Dart imports:
import 'dart:math' show min;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import '../shared/custom_text.dart';
import '../theme.dart';
import 'comments_sheet.dart';
import 'live_firebase.dart';
import 'widgets/aggr_graph_box.dart';
import 'widgets/scroll_appbody.dart';
import 'widgets/total_status.dart';

class LiveLounge extends StatefulWidget {
  const LiveLounge({Key? key}) : super(key: key);

  @override
  State<LiveLounge> createState() => _LiveLoungeState();
}

class _LiveLoungeState extends State<LiveLounge> with WidgetsBindingObserver {
  int notiVer = -1;
  String name = '';

  showCommentSheet() {
    Get.bottomSheet(CommentsSheet(name: name));
  }

  @override
  void initState() {
    super.initState();
    addCount();
    setupName();
  }

  @override
  void dispose() {
    super.dispose();
    subtractCount();
  }

  addCount() async {
    final ref = liveRef.doc('sm');
    var snapshot = await ref.get();
    ref.update({'liveUserCount': snapshot['liveUserCount'] + 1});
  }

  setupName() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('nickname') ?? '';
    debugPrint(name);
  }

  subtractCount() async {
    final ref = liveRef.doc('sm');
    var snapshot = await ref.get();
    ref.update({'liveUserCount': min(snapshot['liveUserCount'] - 1, 0)});
  }

  sendAlert(String title, String message) {
    Get.snackbar(
      title,
      message,
      icon: const Icon(Icons.campaign, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      backgroundColor: customColor[ColorType.deepPurple],
      margin: const EdgeInsets.only(bottom: 30),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  @override
  Widget build(BuildContext context) {
    const emptySpace = SizedBox(height: 20);
    // ignore: unused_local_variable
    final boxDecoration = BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: customColor[ColorType.white],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ]);

    Stream<DocumentSnapshot> agendaStream = liveRef.doc('sm').snapshots();

    agendaStream.listen((DocumentSnapshot snapshot) {
      if (snapshot['notiVer'] > notiVer) {
        notiVer = snapshot['notiVer'];
        EasyDebounce.debounce(
            'sendAlert',
            const Duration(milliseconds: 200),
            () => sendAlert(snapshot['notification']['title'],
                snapshot['notification']['message']));
      }
    });

    return ScrollAppBody(
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TotalStatus(),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomText(
              text: '의안 현황',
              typoType: TypoType.h2,
            ),
          ],
        ),
        emptySpace,
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemCount: 8,
          separatorBuilder: (context, separatorIndex) {
            return emptySpace;
          },
          itemBuilder: (context, itemIndex) {
            return CustomPanel(index: itemIndex);
          },
        ),
        const SizedBox(height: 100),
      ]),
      floatingButton: FloatingActionButton(
        onPressed: showCommentSheet,
        backgroundColor: customColor[ColorType.white],
        child: const Image(
            image: AssetImage('assets/images/chat-bubble.gif'),
            height: 45,
            width: 45),
      ),
      actions: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Image(
              image: AssetImage('assets/images/red_circle.gif'),
              height: 15,
              width: 15),
          SizedBox(width: 10),
          LiveUserCount(),
          SizedBox(width: 20)
        ],
      ),
    );
  }
}

class LiveUserCount extends StatefulWidget {
  const LiveUserCount({Key? key}) : super(key: key);

  @override
  State<LiveUserCount> createState() => _LiveUserCountState();
}

class _LiveUserCountState extends State<LiveUserCount> {
  final Stream<DocumentSnapshot> documentStream = liveRef.doc('sm').snapshots();
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: documentStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Align(
                alignment: Alignment.centerRight,
                child: CustomText(
                  text: '참여 집계 에러...',
                  typoType: TypoType.body,
                ));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Align(
                alignment: Alignment.centerRight,
                child:
                    CustomText(text: '참여인원 집계중...', typoType: TypoType.body));
          }
          var data = snapshot.data!;
          return Align(
              alignment: Alignment.centerRight,
              child: CustomText(
                  text: '라이브: ${data['liveUserCount']} 명',
                  typoType: TypoType.body));
        });
  }
}
