import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../shared/custom_color.dart';
import '../../shared/custom_text.dart';
import '../../vote/vote.controller.dart';

class VioletCard extends StatelessWidget {
  VioletCard({Key? key}) : super(key: key);
  final VoteController _voteController = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());
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
            const CustomText(
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
