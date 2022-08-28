// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../shared/custom_text.dart';
import '../../theme.dart';
import '../campaign.model.dart';

class CampaignInfo extends Column {
  final Campaign campaign;
  final Function(Campaign) onPress;

  CampaignInfo({
    Key? key,
    required this.campaign,
    required this.onPress,
  }) : super(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => {onPress(campaign)},
              child: CustomText(
                text: campaign.koName,
                typoType: TypoType.h1Title,
                colorType: ColorType.white,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => {onPress(campaign)},
              child: CustomText(
                text: campaign.moderator,
                colorType: ColorType.white,
                typoType: TypoType.body,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => {onPress(campaign)},
              child: CustomText(
                text: campaign.date,
                colorType: ColorType.white,
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
}
