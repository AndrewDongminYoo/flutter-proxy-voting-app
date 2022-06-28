import '../vote/vote.model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StepperComponent extends StatefulWidget {
  final VoteAgenda agenda;
  final int sharesNum;
  const StepperComponent({
    Key? key,
    required this.sharesNum,
    required this.agenda,
  }) : super(key: key);

  @override
  State<StepperComponent> createState() => _StepperComponentState();
}

class _StepperComponentState extends State<StepperComponent> {
  int _currentStep = 0;

  void tapped(int step) {
    if (mounted) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  void continued() {
    if (_currentStep < 3) {
      if (mounted) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void cancel() {
    if (_currentStep > 0) {
      if (mounted) {
        setState(() {
          _currentStep--;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(children: [
        customStep('주주명부 대조', widget.sharesNum > 0),
        customStep('안건투표', widget.agenda.voteAt != null),
        customStep('전자서명', widget.agenda.signatureAt != null),
        customStep('신분증 사본', widget.agenda.idCardAt != null),
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
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(20, 20),
              primary:
                  !active ? const Color(0xFFDC721E) : const Color(0xFF572E67),
              shape: const CircleBorder(),
            ),
            child: !active
                ? const Icon(Icons.warning_amber_sharp)
                : const Icon(Icons.check),
          ),
          Expanded(
            flex: 1,
            child: Text(title),
          ),
          TextButton(
            onPressed: () {
              switch (title) {
                case ('주주명부 대조'):
                  Get.toNamed('/checkvotenum', arguments: widget.sharesNum);
                  break;
                case ('안건투표'):
                  Get.toNamed('/vote', arguments: widget.agenda);
                  break;
                case ('전자서명'):
                  Get.toNamed('/signature',
                      arguments: widget.agenda.signatureAt);
                  break;
                case ('신분증 사본'):
                  Get.toNamed('/idcard', arguments: widget.agenda.idCardAt);
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
                  Icons.arrow_circle_right_outlined,
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
