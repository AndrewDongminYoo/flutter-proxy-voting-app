// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'campaign.model.dart';

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
              child: Text(
                campaign.koName,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => {onPress(campaign)},
              child: Text(
                campaign.moderator,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, height: 1),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => {onPress(campaign)},
              child: Text(
                campaign.date,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
}
