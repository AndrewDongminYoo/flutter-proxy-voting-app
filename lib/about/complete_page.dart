import 'package:bside/campaign/campaign.model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import '../campaign/campaign.controller.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';
import 'address.dart';

class CompleteWidget extends StatefulWidget {
  const CompleteWidget({
    Key? key,
    required this.bottom,
    double? containerHeight,
  }) : super(key: key);
  final String bottom;

  @override
  State<CompleteWidget> createState() => _CompleteWidgetState();
}

class _CompleteWidgetState extends State<CompleteWidget> {
  double? containerHeight;
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());

  @override
  Widget build(BuildContext context) {
    Campaign campaign = _controller.campaign;
    return Container(
      width: Get.width,
      height: 500,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff60457A),
            Color(0xff80A1DF),
          ],
        ),
      ),
      child: Column(children: <Widget>[
        const Spacer(),
        CustomText(
          typoType: TypoType.h1,
          text: campaign.companyName,
          colorType: ColorType.white,
        ),
        const Spacer(),
        Align(
          child: CircleAvatar(
            foregroundImage: NetworkImage(campaign.logoImg),
            radius: 40,
            backgroundColor: customColor[ColorType.white],
          ),
        ),
        const Spacer(),
        CustomText(
          typoType: TypoType.h1,
          text: widget.bottom,
          colorType: ColorType.white,
        ),
        const Address()
      ]),
    );
  }
}
