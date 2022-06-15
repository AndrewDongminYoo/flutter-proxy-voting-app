import 'package:flutter/material.dart';

import '../models/campaign.dart';

class CampaignInfo extends StatelessWidget {
  const CampaignInfo(
      {Key? key,
      required this.campaign})
      : super(key: key);
  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(
        campaign.companyName,
        style: const TextStyle(
            color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
      ),
      Text(
        campaign.moderator,
        style: const TextStyle(color: Colors.white, fontSize: 16, height: 2),
      ),
      Text(
        campaign.date,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    ]);
  }
}
