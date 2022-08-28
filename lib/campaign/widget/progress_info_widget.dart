// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../campaign/campaign.model.dart';
import 'progress_icon_widget.dart';

class ProgressInfoWidget extends StatelessWidget {
  const ProgressInfoWidget({
    Key? key,
    required this.progress,
    required this.progressState,
    required this.campaign,
  }) : super(key: key);

  final List progress;
  final int progressState;
  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(25, 15, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Material(
            color: const Color.fromARGB(0, 0, 0, 0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 30, 0),
              child: Text(
                campaign.slogan,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontFamily: 'NanumSquareRoundOTF',
                  fontSize: 24,
                  color: Colors.white,
                  letterSpacing: 0.96,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 3,
              ),
            ),
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.start,
            children: [
              Material(
                color: const Color.fromARGB(0, 0, 0, 0),
                child: Text(
                  'ooo명이 참여중 | ${progress[progressState]} ',
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                ),
              ),
              ProgressIconWidget(progressState: progressState),
            ],
          )
        ],
      ),
    );
  }
}
