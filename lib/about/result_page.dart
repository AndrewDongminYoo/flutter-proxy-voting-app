import 'similar_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../campaign/campaign.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());
  @override
  Widget build(BuildContext context) {
    Campaign campaign = _controller.campaign;

    var blueBackGroundWidgets = <Widget>[
      Container(
          margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
          child: CustomText(
              typoType: TypoType.h1,
              text: campaign.companyName,
              colorType: ColorType.white)),
      Container(
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Align(
          child: CircleAvatar(
            foregroundImage: NetworkImage(campaign.logoImg),
            radius: 40,
            backgroundColor: customColor[ColorType.white],
          ),
        ),
      ),
      Container(
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: const CustomText(
              typoType: TypoType.h1,
              text: '수고하셨습니다.',
              colorType: ColorType.white)),
      const CustomText(
          typoType: TypoType.bodyLight,
          text: '성공적으로 전자위임이 완료되었습니다.',
          colorType: ColorType.white),
      const CustomText(
          typoType: TypoType.bodyLight,
          text: '다른 캠페인도 둘러보시겠어요?',
          colorType: ColorType.white),
    ];
    var whiteBackGroundWidgets = [
      // const Spacer(
      //   flex: 2,
      // ),
      Container(
        width: Get.width,
        height: 120,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          color: Color(0xFFDC721E),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: const [
                CustomText(
                  typoType: TypoType.body,
                  text: '주소',
                  textAlign: TextAlign.left,
                  colorType: ColorType.white,
                ),
                // Spacer(),
                CustomText(
                  typoType: TypoType.bodyLight,
                  text: '수정하기',
                  textAlign: TextAlign.left,
                  colorType: ColorType.white,
                ),
                Icon(
                  Icons.arrow_circle_right_outlined,
                ),
              ],
            ),
            const Spacer(),
            const CustomText(
                typoType: TypoType.bodyLight,
                text: '서울시 송파구 아무로 12-2길 32, 송파아크 로펠리스 타워 102동 707호',
                textAlign: TextAlign.left,
                colorType: ColorType.white),
          ]),
        ),
      ),
      const SizedBox(height: 20),
      Container(
        width: Get.width,
        height: 100,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color(0xff582E66),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CustomText(
                  typoType: TypoType.body,
                  text: '보유 주소',
                  colorType: ColorType.white),
              Spacer(),
              CustomText(
                  typoType: TypoType.bodyLight,
                  text: '1000주',
                  colorType: ColorType.white)
            ],
          ),
        ),
      ),
    ];
    var animatedWidgets = Stepper(
      type: StepperType.vertical,
      steps: const [
        Step(
          title: Text('Step 1 title'),
          content: Text(''),
        ),
        Step(
          title: Text('Step 2 title'),
          content: Text(''),
        ),
      ],
    );
    return SimilarPage(
      blueBackGroundWidgets: blueBackGroundWidgets,
      whiteBackGroundWidgets: whiteBackGroundWidgets,
      animatedWidgets: animatedWidgets,
    );
  }
}
