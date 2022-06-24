import 'similar_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../campaign/campaign.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/custom_grid.dart';
import '../shared/custom_button.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';

class CheckVoteNumPage extends StatefulWidget {
  const CheckVoteNumPage({Key? key}) : super(key: key);
  @override
  State<CheckVoteNumPage> createState() => _CheckVoteNumPageState();
}

class _CheckVoteNumPageState extends State<CheckVoteNumPage> {
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());

  voteWithExample() {
    Get.toNamed("/vote");
  }

  voteWithoutExample() {
    Get.toNamed("/vote");
  }

  @override
  Widget build(BuildContext context) {
    Campaign campaign = _controller.campaign;

    var blueBackGroundWidgets = <Widget>[
      const SizedBox(height: 40),
      CustomText(
        typoType: TypoType.h1,
        text: campaign.companyName,
        colorType: ColorType.white,
      ),
      const SizedBox(height: 16),
      Align(
        child: CircleAvatar(
          foregroundImage: NetworkImage(campaign.logoImg),
          radius: 40,
          backgroundColor: customColor[ColorType.white],
        ),
      ),
      const SizedBox(height: 16),
      const CustomText(
        typoType: TypoType.h1,
        text: '안녕하세요! 주주님',
        colorType: ColorType.white,
      ),
      const SizedBox(height: 16),
      Container(
        width: Get.width,
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
                Spacer(),
                CustomText(
                  typoType: TypoType.bodyLight,
                  text: '수정하기',
                  textAlign: TextAlign.left,
                  colorType: ColorType.white,
                ),
                Icon(
                  Icons.arrow_circle_right_outlined,
                )
              ],
            ),
            const SizedBox(height: 24),
            const CustomText(
                typoType: TypoType.bodyLight,
                text: '서울시 송파구 아무로 12-2길 32, 송파아크 로펠리스 타워 102동 707호',
                textAlign: TextAlign.left,
                colorType: ColorType.white),
          ]),
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: Get.width,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color(0xff582E66),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CustomText(
                  typoType: TypoType.body,
                  text: '보유 주수',
                  colorType: ColorType.white),
              SizedBox(height: 21),
              CustomText(
                  typoType: TypoType.bodyLight,
                  text: '1000주',
                  colorType: ColorType.white)
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
    ];
    var whiteBackGroundWidgets = [
      CustomText(
          typoType: TypoType.h1Bold,
          textAlign: TextAlign.left,
          text: '2022 ${campaign.companyName} 주주총회 의안'),
      const SizedBox(height: 10),
      const CustomText(
          typoType: TypoType.bodyLight,
          textAlign: TextAlign.left,
          text: '아래 작성 예시를 통해 정확한 정보를 알아보시고'),
      const CustomText(
          typoType: TypoType.bodyLight,
          textAlign: TextAlign.left,
          text: '소중한 주주의 의견을 알려주세요!'),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomOutlinedButton(
          label: "작성예시 보기",
          onPressed: () {
            voteWithExample();
          },
          textColor: ColorType.orange,
          width: CustomW.w4,
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomButton(
          label: "투표하러 가기",
          onPressed: () {
            voteWithoutExample();
          },
          width: CustomW.w4,
        ),
      ),
    ];
    return SimilarPage(
      blueBackGroundWidgets: blueBackGroundWidgets,
      whiteBackGroundWidgets: whiteBackGroundWidgets,
      animatedWidgets: Container(),
    );
  }
}
