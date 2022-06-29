import '../auth/auth.controller.dart';
import '../vote/vote.controller.dart';
import 'widget/adress_card.dart';
import 'widget/edit_modal.dart';
import 'similar_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../campaign/campaign.model.dart';
import '../shared/custom_grid.dart';
import '../shared/custom_button.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';
import 'widget/vote_num_card.dart';

class CheckVoteNumPage extends StatefulWidget {
  const CheckVoteNumPage({Key? key}) : super(key: key);
  @override
  State<CheckVoteNumPage> createState() => _CheckVoteNumPageState();
}

class _CheckVoteNumPageState extends State<CheckVoteNumPage> {
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  voteWithExample() {
    Get.toNamed('/vote', arguments: 'voteWithExample');
  }

  voteWithoutExample() {
    Get.toNamed('/vote', arguments: 'voteWithoutExample');
  }

  onEdit() async {
    await Get.dialog(const EditModal());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Campaign campaign = voteCtrl.campaign;

    var blueBackGroundWidgets = <Widget>[
      const SizedBox(height: 40),
      CustomText(
        typoType: TypoType.h1,
        text: campaign.koName,
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
      const AdressCard(),
      const SizedBox(height: 8),
      VioletCard(),
      const SizedBox(height: 16),
    ];
    var whiteBackGroundWidgets = [
      CustomText(
          typoType: TypoType.h1Bold,
          textAlign: TextAlign.left,
          text: '2022 ${campaign.koName} 주주총회 의안'),
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
          label: '작성예시 보기',
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
          label: '투표하러 가기',
          onPressed: () {
            voteWithoutExample();
          },
          width: CustomW.w4,
        ),
      ),
    ];
    return SimilarPage(
      title: '의결수 확인',
      blueBackGroundWidgets: blueBackGroundWidgets,
      whiteBackGroundWidgets: whiteBackGroundWidgets,
      animatedWidgets: Container(),
    );
  }
}
