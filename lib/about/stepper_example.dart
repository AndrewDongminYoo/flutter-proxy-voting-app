// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../get_nav.dart';
import '../shared/custom_button.dart';
import '../vote/vote.model.dart';

class StepperComponent extends StatefulWidget {
  final VoteAgenda agenda;
  final int shareId;
  const StepperComponent({
    Key? key,
    required this.shareId,
    required this.agenda,
  }) : super(key: key);

  @override
  State<StepperComponent> createState() => _StepperComponentState();
}

class _StepperComponentState extends State<StepperComponent> {
  int _currentStep = 0;

  void tapped(int step) {
    setState(() {
      _currentStep = step;
    });
  }

  void continued() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void cancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(children: [
        customStep('주주명부 대조', widget.shareId != 0),
        customStep('안건투표', widget.agenda.voteAt != null),
        customStep('전자서명', widget.agenda.signatureAt != null),
        customStep('신분증 사본', widget.agenda.idCardAt != null),
        customStep('주민번호 입력', widget.agenda.backIdAt != null),
      ]),
    );
  }

  Widget customStep(title, active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: Get.width,
      height: 50,
      child: Row(
        children: [
          StepperButton(active: active),
          Expanded(
            flex: 1,
            child: Text(title),
          ),
          TextButton(
            onPressed: () {
              switch (title) {
                case ('주주명부 대조'):
                  goToCheckVoteNum();
                  break;
                case ('안건투표'):
                  goToVoteWithLastMemory();
                  break;
                case ('전자서명'):
                  goToSignature();
                  break;
                case ('신분증 사본'):
                  goToIDCard();
                  break;
                case ('주민번호 입력'):
                  goToIDNumber();
                  break;
              }
            },
            child: Row(
              children: const [
                Text(
                  '수정하기',
                  style: TextStyle(
                    color: Colors.black,
                    inherit: false,
                  ),
                ),
                SizedBox(width: 8.0),
                Icon(
                  CupertinoIcons.arrow_right_square,
                  color: Color(0xFF572E67),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
