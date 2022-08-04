// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:bside/lib.dart' show Avatar, Campaign;

class CampaignLogoWidget extends StatelessWidget {
  const CampaignLogoWidget({
    Key? key,
    required this.campaign,
  }) : super(key: key);

  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: Get.width * 0.4),
      decoration: BoxDecoration(
        color: campaign.color,
        borderRadius: const BorderRadius.only(
            topRight: Radius.circular(80), bottomRight: Radius.circular(80)),
        gradient: SweepGradient(
          center: Alignment.center,
          colors: <Color>[
            const Color(0xFF572E67),
            const Color(0xFF7C299A),
            campaign.color,
            const Color(0xFF572E67),
          ],
          stops: const [0.125, 0.126, 0.6, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Align(
        heightFactor: 2,
        alignment: Alignment.center,
        child: Avatar(
          image: campaign.logoImg,
          radius: 40,
          backgroundColor: const Color(0xFFFFE0E9),
        ),
      ),
    );
  }
}
