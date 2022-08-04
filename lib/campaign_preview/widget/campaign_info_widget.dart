// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

// 🌎 Project imports:
import 'package:bside/lib.dart'
    show
        Campaign,
        ColorType,
        CustomButton,
        CustomText,
        CustomW,
        TypoType,
        goBack;

class CampaignInfoWidget extends StatelessWidget {
  const CampaignInfoWidget({
    Key? key,
    required this.campaign,
  }) : super(key: key);

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: Get.height * 0.05,
      right: 12,
      child: Material(
        color: const Color.fromARGB(0, 0, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 24),
            CustomText(
              text: campaign.koName,
              typoType: TypoType.h1Title,
              colorType: ColorType.white,
            ),
            const SizedBox(height: 16),
            CustomText(
              text: campaign.moderator,
              colorType: ColorType.white,
              typoType: TypoType.body,
            ),
            const SizedBox(height: 16),
            CustomText(
              text: campaign.date,
              colorType: ColorType.white,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: CustomButton(
                label: '돌아가기',
                fontSize: 16,
                onPressed: () {
                  goBack();
                },
                bgColor: ColorType.white,
                textColor: ColorType.deepPurple,
                width: CustomW.w1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
