// ๐ฆ Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

// ๐ฆ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// ๐ Project imports:
import '../../shared/shared.dart';
import '../../vote/vote.model.dart';

class StepperCard extends StatefulWidget {
  final VoteAgenda agenda;
  final int shareId;
  const StepperCard({
    Key? key,
    required this.shareId,
    required this.agenda,
  }) : super(key: key);

  @override
  State<StepperCard> createState() => _StepperCardState();
}

class _StepperCardState extends State<StepperCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(children: [
        customStep('์ฃผ์ฃผ๋ช๋ถ ๋์กฐ', widget.shareId != 0),
        customStep('์๊ฑดํฌํ', widget.agenda.voteAt != null),
        customStep('์ ์์๋ช', widget.agenda.signatureAt != null),
        customStep('์ ๋ถ์ฆ ์ฌ๋ณธ', widget.agenda.idCardAt != null),
        customStep('์ฃผ๋ฏผ๋ฒํธ ์๋ ฅ', widget.agenda.backIdAt != null),
      ]),
    );
  }

  Widget customStep(String title, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: Get.width,
      height: 50,
      child: Row(
        children: [
          StepperButton(active: active),
          Expanded(
            flex: 1,
            child: CustomText(
              text: title,
              textAlign: TextAlign.left,
            ),
          ),
          TextButton(
            onPressed: () {
              switch (title) {
                case ('์ฃผ์ฃผ๋ช๋ถ ๋์กฐ'):
                  goVoteNumCheck();
                  break;
                case ('์๊ฑดํฌํ'):
                  goVoteWithMemory();
                  break;
                case ('์ ์์๋ช'):
                  goVoteSign();
                  break;
                case ('์ ๋ถ์ฆ ์ฌ๋ณธ'):
                  goUploadIdCard();
                  break;
                case ('์ฃผ๋ฏผ๋ฒํธ ์๋ ฅ'):
                  goTakeIdNumber();
                  break;
              }
            },
            child: Row(
              children: const [
                Text(
                  '์์ ํ๊ธฐ',
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
