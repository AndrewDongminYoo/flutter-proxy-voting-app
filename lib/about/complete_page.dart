import 'package:bside/campaign/campaign.model.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import '../about/address.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';

class CompleteWidget extends StatelessWidget {
  CompleteWidget({
    Key? key,
    required this.campaign,
    double? containerHeight,
  }) : super(key: key);
  final Campaign campaign;
  double? containerHeight;

  @override
  Widget build(BuildContext context) {
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
        const CustomText(
          typoType: TypoType.h1,
          text: '안녕하세요!',
          colorType: ColorType.white,
        ),
        const CustomText(
          typoType: TypoType.h1,
          text: '소재우 주주님',
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
          text: campaign.companyName,
          colorType: ColorType.white,
        ),
        const Address()
      ]),
    );
  }
}
