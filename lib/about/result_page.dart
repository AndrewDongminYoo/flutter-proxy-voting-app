import '../about/edit_modal.dart';

import '../auth/auth.controller.dart';

import '../shared/custom_button.dart';
import '../shared/custom_grid.dart';
import '../vote/vote.controller.dart';
import 'similar_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../campaign/campaign.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';
import 'stepper_example.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final AuthController _addressController = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());
  onEdit() {
    Get.dialog(EditModal());
  }

  final VoteController _voteController = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  @override
  Widget build(BuildContext context) {
    Campaign campaign = _controller.campaign;
    String address = _addressController.user?.address != null
        ? _addressController.user!.address
        : '주소가 없습니다.';
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
      // const CustomText(
      //     typoType: TypoType.bodyLight,
      //     text: '다른 캠페인도 둘러보시겠어요?',
      //     colorType: ColorType.white),
      const SizedBox(height: 20),
    ];
    var whiteBackGroundWidgets = [
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const CustomText(
                typoType: TypoType.bodyLight,
                text: '수정하기',
                textAlign: TextAlign.left,
                colorType: ColorType.white,
              ),
              IconButton(
                icon: Icon(
                  Icons.arrow_circle_right_outlined,
                  color: customColor[ColorType.white],
                ),
                onPressed: onEdit,
              ),
            ],
          ),
          // CustomText(
          //     typoType: TypoType.bodyLight,
          //     text: address,
          //     textAlign: TextAlign.left,
          //     colorType: ColorType.white),
        ),
      ),
      const SizedBox(height: 20),
      Container(
        width: Get.width,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Color(0xff582E66),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CustomText(
                  typoType: TypoType.body,
                  text: '보유 주수',
                  colorType: ColorType.white),
              const SizedBox(height: 21),
              CustomText(
                  typoType: TypoType.bodyLight,
                  text: _voteController.shareholder!.sharesNum.toString(),
                  colorType: ColorType.white)
            ],
          ),
        ),
      ),
    ];
    var animatedWidgets = Column(children: [
      const StepperComponent(),
      const SizedBox(height: 30),
      CustomButton(
        label: '처음으로',
        width: CustomW.w4,
        onPressed: () => Get.toNamed("/"),
      ),
      const SizedBox(height: 100)
    ]);
    return SimilarPage(
      title: '결과 확인',
      blueBackGroundWidgets: blueBackGroundWidgets,
      whiteBackGroundWidgets: whiteBackGroundWidgets,
      animatedWidgets: animatedWidgets,
    );
  }
}
