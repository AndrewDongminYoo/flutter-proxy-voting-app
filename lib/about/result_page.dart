import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'similar_page.dart';
import 'stepper_example.dart';
import '../about/edit_modal.dart';
import '../shared/custom_grid.dart';
import '../shared/custom_text.dart';
import '../shared/custom_color.dart';
import '../vote/vote.controller.dart';
import '../auth/auth.controller.dart';
import '../shared/custom_button.dart';
import '../campaign/campaign.model.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  onAddressEdit() async {
    await Get.dialog(const EditModal());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Campaign campaign = voteCtrl.campaign;
    var blueBackGroundWidgets = <Widget>[
      Container(
          margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
          child: CustomText(
              typoType: TypoType.h1,
              text: campaign.koName,
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
          colorType: ColorType.white,
        ),
      ),
      const CustomText(
        typoType: TypoType.bodyLight,
        text: '성공적으로 전자위임이 완료되었습니다.',
        colorType: ColorType.white,
      ),
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
                children: [
                  const CustomText(
                    typoType: TypoType.body,
                    text: '주소',
                    textAlign: TextAlign.left,
                    colorType: ColorType.white,
                  ),
                  const Spacer(),
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
                    onPressed: onAddressEdit,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomText(
                typoType: TypoType.bodyLight,
                text: authCtrl.user.address,
                textAlign: TextAlign.left,
                colorType: ColorType.white,
              ),
            ],
          ),
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
                  text: '${voteCtrl.voteAgenda.sharesNum}',
                  colorType: ColorType.white)
            ],
          ),
        ),
      ),
    ];
    var animatedWidgets = Column(
      children: [
        StepperComponent(
          agenda: voteCtrl.voteAgenda,
          shareId: voteCtrl.shareholder.id,
        ),
        const SizedBox(height: 30),
        CustomButton(
          label: '처음으로',
          width: CustomW.w4,
          onPressed: () => Get.offNamedUntil('/', (route) => route.settings.name == '/'),
        ),
        const SizedBox(height: 100)
      ],
    );
    return SimilarPage(
      title: '결과 확인',
      blueBackGroundWidgets: blueBackGroundWidgets,
      whiteBackGroundWidgets: whiteBackGroundWidgets,
      animatedWidgets: animatedWidgets,
    );
  }
}
