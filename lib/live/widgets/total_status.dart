// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 🌎 Project imports:
import '../../shared/custom_text.dart';
import '../../shared/progress_bar.dart';
import '../../theme.dart';
import '../live_firebase.dart';
import '../live.model.dart';
import 'lounge_header.dart';
import 'status_box.dart';

class TotalStatus extends StatelessWidget {
  TotalStatus({Key? key}) : super(key: key);
  final Stream<DocumentSnapshot> _statusStream = liveRef.doc('sm').snapshots();
  final NumberFormat f = NumberFormat('###,###,###,###');

  Widget cardWrapper(Widget body) {
    return Container(
        width: Get.width,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            color: customColor[ColorType.white],
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 0.5,
                blurRadius: 3,
              ),
            ]),
        child: body);
  }

  // String readTimestamp(Timestamp timestamp) => timeago.format(timestamp.toDate(), locale: 'ko');
  String readTimestamp(Timestamp timestamp) => '';

  @override
  Widget build(BuildContext context) {
    const emptySpace = SizedBox(height: 30);
    return StreamBuilder<DocumentSnapshot>(
        stream: _statusStream,
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LiveLoungeHeader();
          }
          var live = LiveLounge.fromJson(snapshot.data!);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              emptySpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CustomText(
                    text: '22년 에스엠 주주총회',
                    typoType: TypoType.body,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  StatusBox(
                    color: live.getTotalStatusColor(),
                    text: live.getTotalStatus(),
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const CustomText(
                text: '일시 : 3월 31일 (목) 오전 9시',
                typoType: TypoType.body,
              ),
              const SizedBox(
                height: 5,
              ),
              const CustomText(
                text: '장소 : 성동구 왕십리로 83-21 에스엠 본사 2층',
                typoType: TypoType.body,
              ),
              emptySpace,
              emptySpace,
              // PreVote Status
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const CustomText(
                    text: '사전 집계 현황',
                    typoType: TypoType.body,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  StatusBox(
                    text: live.getPreVoteStatus(),
                    color: live.getPreVoteColor(),
                  )
                ],
              ),
              emptySpace,
              // PreVote Graph
              cardWrapper(Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: '출석 주식수: ${f.format(live.preVoteCompany)} 주',
                        typoType: TypoType.body,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const CustomText(
                            text: '집계 이력 : ',
                            typoType: TypoType.body,
                          ),
                          CustomText(
                            text: readTimestamp(live.updatedAt),
                            typoType: TypoType.body,
                          )
                        ],
                      ),
                    ],
                  ))),
              const SizedBox(
                height: 10,
              ),
              const CustomText(
                typoType: TypoType.body,
                text: '* 사전집계현황은 변동 가능성이 높고 정확하지 않은 정보일 수 있습니다.',
              ),
              emptySpace,
              emptySpace,
            ],
          );
        });
  }
}

class HorizontalBarWrapper extends StatefulWidget {
  final String label;
  final Color mainColor;
  final int targetVote;
  final int totalVote;
  final bool updated;

  const HorizontalBarWrapper(
      {Key? key,
      required this.label,
      required this.mainColor,
      required this.targetVote,
      required this.totalVote,
      required this.updated})
      : super(key: key);

  @override
  State<HorizontalBarWrapper> createState() => _HorizontalBarWrapperState();
}

class _HorizontalBarWrapperState extends State<HorizontalBarWrapper> {
  @override
  Widget build(BuildContext context) {
    var f = NumberFormat('###,###,###,###');
    double percentage =
        widget.targetVote / (widget.totalVote == 0 ? 10 : widget.totalVote);
    return Column(
      children: [
        Row(
          children: [
            CustomText(
              text: widget.label,
              typoType: TypoType.body,
            ),
            const SizedBox(width: 15),
            CustomText(
              text:
                  '${f.format(widget.targetVote)}표 (${(percentage * 100).round()}%)',
              typoType: TypoType.body,
            ),
            const Spacer(),
            widget.updated
                ? const CustomText(
                    text: '+ ',
                    typoType: TypoType.body,
                    colorType: ColorType.red,
                  )
                : Container()
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        HorizontalProgressBar(
          value: percentage,
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
