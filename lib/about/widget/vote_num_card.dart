// π¦ Flutter imports:
import 'package:flutter/material.dart';

// π¦ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// π Project imports:
import '../../shared/shared.dart';
import '../../theme.dart';
import '../../vote/vote.controller.dart';

class VioletCard extends StatelessWidget {
  VioletCard({Key? key}) : super(key: key);
  final VoteController _voteController = VoteController.get();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Color(0xff582E66),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
                typoType: TypoType.body,
                text: 'λ³΄μ  μ£Όμ',
                colorType: ColorType.white),
            const SizedBox(height: 21),
            CustomText(
                typoType: TypoType.bodyLight,
                text: _voteController.shareholder.sharesNum.toString(),
                colorType: ColorType.white)
          ],
        ),
      ),
    );
  }
}
