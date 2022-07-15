// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

// 🌎 Project imports:
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
                text: '보유 주수',
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
