// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/custom_button.dart';
import '../shared/custom_text.dart';
import '../theme.dart';
import '../vote/vote.controller.dart';
import 'similar_page.dart';
import 'stepper_example.dart';
import 'widget/address_card.dart';
import 'widget/edit_modal.dart';

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
      const AddressCard(),
      const SizedBox(height: 20),
      Container(
        width: Get.width,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(24.0)),
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
          onPressed: () {
            return Get.offNamedUntil(
              '/',
              (route) {
                return route.settings.name == '/';
              },
            );
          },
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
