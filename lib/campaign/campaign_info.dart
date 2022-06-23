import 'package:flutter/material.dart';

import 'campaign.model.dart';

class CampaignInfo extends StatelessWidget {
  const CampaignInfo(
      {Key? key,
      required this.campaign})
      : super(key: key);
  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      const SizedBox(height: 24),
      Text(
        campaign.companyName,
        style: const TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 16),
      Text(
        campaign.moderator,
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1),
      ),
      const SizedBox(height: 16),
      Text(
        campaign.date,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      const SizedBox(height: 16),
    ]);
  }
}
