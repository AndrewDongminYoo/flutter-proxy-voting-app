import 'package:bside/shared/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../campaign/campaign.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/custom_appbar.dart';
import '../shared/custom_button.dart';
import '../shared/custom_color.dart';
import '../shared/custom_grid.dart';
import '../shared/custom_text.dart';

class NotShareholderPage extends StatefulWidget {
  const NotShareholderPage({Key? key}) : super(key: key);
  @override
  State<NotShareholderPage> createState() => _NotShareholderPageState();
}

class _NotShareholderPageState extends State<NotShareholderPage> {
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());
  onPressedMail() {}
  @override
  Widget build(BuildContext context) {
    Campaign campaign = _controller.campaign;

    return Scaffold(
        appBar: const CustomAppBar(title: '캠페인'),
        body: SizedBox(
          child: ListView(
            children: [
              Temp(campaign: campaign),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    const CustomText(
                        typoType: TypoType.h1, text: 'sjcho0070@naver.com'),
                    const SizedBox(
                      height: 50,
                    ),
                    const CustomText(
                        typoType: TypoType.h1, text: '010-8697-1669'),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomButton(
                      label: '뒤로가기',
                      bgColor: ColorType.deepPurple,
                      onPressed: () => Get.back(),
                      width: CustomW.w4,
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class Temp extends StatefulWidget {
  Temp({
    Key? key,
    required this.campaign,
  }) : super(key: key);

  final Campaign campaign;

  @override
  State<Temp> createState() => _TempState();
}

class _TempState extends State<Temp> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 400,
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
                ])),
        child: Column(children: <Widget>[
          Container(
              margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
              child: const CustomText(
                  typoType: TypoType.h1, text: '', colorType: ColorType.white)),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Align(
              child: CircleAvatar(
                foregroundImage: NetworkImage(widget.campaign.logoImg),
                radius: 40,
                backgroundColor: customColor[ColorType.white],
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: const CustomText(
                  typoType: TypoType.h1,
                  text: '주주명부에 등록되어있지 않습니다.',
                  colorType: ColorType.white)),
          const CustomText(
              typoType: TypoType.bodyLight,
              text: '주주가 맞으실 경우 문의해주시길 바랍니다.',
              colorType: ColorType.white),
        ]));
  }
}
