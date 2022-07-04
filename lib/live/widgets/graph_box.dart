// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import '../../shared/custom_text.dart';
import '../../theme.dart';
import '../firebase.dart';
import '../live.model.dart';
import 'progress_bar.dart';
import 'reaction.dart';
import 'status_box.dart';

class CustomPanel extends StatefulWidget {
  const CustomPanel({Key? key, required this.index}) : super(key: key);
  final int index;

  @override
  State<CustomPanel> createState() => _CustomPanelState();
}

class _CustomPanelState extends State<CustomPanel> {
  bool isNoticed = false;
  bool isExpanded = false;

  sendAlert(String title) {
    Get.snackbar(
      '안내',
      '$title이 집계중입니다.',
      icon: const Icon(Icons.campaign, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      backgroundColor: customColor[ColorType.deepPurple],
      margin: const EdgeInsets.only(bottom: 30),
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
    setState(() {
      isExpanded = true;
    });
  }

  getDecoration(int status) {
    return BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: customColor[ColorType.white],
        boxShadow: [
          BoxShadow(
            color: status == 1
                ? customColor[ColorType.deepPurple] as Color
                : Colors.grey.withOpacity(0.5),
            spreadRadius: status == 1 ? 2 : 1,
            blurRadius: status == 1 ? 5 : 1,
          ),
        ]);
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot> agendaStream = liveRef
        .doc('sm')
        .collection('agenda')
        .doc((widget.index + 1).toString())
        .snapshots();

    agendaStream.listen((DocumentSnapshot snapshot) {
      if (snapshot['status'] == 1 && isNoticed == false) {
        isNoticed = true;
        EasyDebounce.debounce('sendAlert', const Duration(milliseconds: 200),
            () => sendAlert(snapshot['title']));
      }
    });

    return StreamBuilder<DocumentSnapshot>(
        stream: agendaStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading');
          }
          var liveAgenda = LiveAgenda.fromJson(snapshot.data!);
          liveAgenda.index = widget.index;
          return Container(
            padding: const EdgeInsets.all(8),
            decoration: getDecoration(liveAgenda.status),
            child: ExpansionPanelList(
              elevation: 0,
              animationDuration: const Duration(milliseconds: 1000),
              children: [
                ExpansionPanel(
                    isExpanded: isExpanded,
                    headerBuilder: (context, isExpanded) {
                      return GraphBoxHeader(liveAgenda: liveAgenda);
                    },
                    body: GraphBoxBody(liveAgenda: liveAgenda))
              ],
              expansionCallback: (panelIndex, value) {
                setState(() {
                  isExpanded = !value;
                });
              },
            ),
          );
        });
  }
}

class GraphBoxHeader extends StatelessWidget {
  const GraphBoxHeader({Key? key, required this.liveAgenda}) : super(key: key);
  final LiveAgenda liveAgenda;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                text: liveAgenda.title,
                typoType: TypoType.body,
              ),
              const SizedBox(
                width: 10,
              ),
              StatusBox(
                  text: liveAgenda.getStatus(),
                  color: liveAgenda.getStatusColor())
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          CustomText(text: liveAgenda.subTitle, typoType: TypoType.body),
        ],
      ),
    );
  }
}

class GraphBoxBody extends StatelessWidget {
  const GraphBoxBody({Key? key, required this.liveAgenda}) : super(key: key);
  final LiveAgenda liveAgenda;

  Widget labelWithCircle(Color color, String text, bool isLeft) {
    return Row(
      mainAxisAlignment:
          isLeft ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(
          width: 3,
        ),
        CustomText(text: text, typoType: TypoType.h2)
      ],
    );
  }

  Widget getRichText(int voteCount, bool isBold, Color color) {
    var f = NumberFormat('###,###,###,###');

    return RichText(
      overflow: TextOverflow.visible,
      text: TextSpan(
        children: [
          TextSpan(
            text: f.format(voteCount),
            style: TextStyle(
                fontSize: isBold ? 14.0 : 12.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: color),
          ),
          TextSpan(
            text: '표',
            style: TextStyle(
                fontSize: isBold ? 14.0 : 12.0,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: Colors.black),
          ),
        ],
      ),
    );
  }

  addReaction(String value) {
    liveRef
        .doc('sm')
        .collection('agenda')
        .doc((liveAgenda.index + 1).toString())
        .update({'reaction.$value': liveAgenda[value] + 1});
  }

  @override
  Widget build(BuildContext context) {
    const emptySpace = SizedBox(
      height: 10,
    );

    return SizedBox(
        width: Get.width,
        child: Column(
          children: [
            Row(children: [
              const SizedBox(width: 5),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      emptySpace,
                      labelWithCircle(Colors.blue, '찬성', true),
                      emptySpace,
                      getRichText(liveAgenda.totalFor, true, Colors.blue),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          emptySpace,
                          VerticalProgressBar(
                              value: liveAgenda.forPercentage,
                              color: Colors.blue,
                              height: 100),
                          CustomText(
                              text: liveAgenda.forPercentage == 0
                                  ? '(0%)'
                                  : '(${(liveAgenda.forPercentage * 100).round()}%)',
                              typoType: TypoType.body)
                        ],
                      ),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          emptySpace,
                          VerticalProgressBar(
                              value: liveAgenda.againstPercentage,
                              color: Colors.red,
                              height: 100),
                          CustomText(
                              text: liveAgenda.againstPercentage == 0
                                  ? '(0%)'
                                  : '(${(liveAgenda.againstPercentage * 100).round()}%)',
                              typoType: TypoType.body)
                        ],
                      ),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      emptySpace,
                      labelWithCircle(Colors.red, '반대', false),
                      emptySpace,
                      getRichText(liveAgenda.totalAgainst, true, Colors.red),
                    ],
                  )),
              const SizedBox(width: 5),
            ]),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ReactionButton(
                  onReactionChanged: (String? value) {
                    addReaction(value!);
                  },
                  reactions: reactions,
                  initialReaction: Reaction<String>(
                    value: null,
                    icon: const Icon(Icons.emoji_emotions_outlined, size: 25),
                  ),
                  boxColor: ColorType.white as Color,
                  // boxPosition: Position.TOP,
                  boxRadius: 10,
                  boxDuration: const Duration(milliseconds: 500),
                  itemScaleDuration: const Duration(milliseconds: 200),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    liveAgenda.reactionHappy > 0
                        ? _buildReactionsIcon('assets/images/smile-face.gif',
                            liveAgenda.reactionHappy)
                        : Container(),
                    const SizedBox(width: 10),
                    liveAgenda.reactionAngry > 0
                        ? _buildReactionsIcon('assets/images/angry-face.gif',
                            liveAgenda.reactionAngry)
                        : Container(),
                    const SizedBox(width: 10),
                    liveAgenda.reactionLove > 0
                        ? _buildReactionsIcon('assets/images/love-face.gif',
                            liveAgenda.reactionLove)
                        : Container(),
                    const SizedBox(width: 10),
                    liveAgenda.reactionSad > 0
                        ? _buildReactionsIcon('assets/images/sad-face.gif',
                            liveAgenda.reactionSad)
                        : Container(),
                    const SizedBox(width: 10),
                    liveAgenda.reactionSurprise > 0
                        ? _buildReactionsIcon('assets/images/flushed-face.gif',
                            liveAgenda.reactionSurprise)
                        : Container(),
                  ],
                ))
              ],
            )
          ],
        ));
  }
}

Row _buildReactionsIcon(String path, int number) {
  return Row(
    children: [
      Image.asset(path, height: 25),
      CustomText(
        text: ' $number',
        typoType: TypoType.body,
      )
    ],
  );
}
