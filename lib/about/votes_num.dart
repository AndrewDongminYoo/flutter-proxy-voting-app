// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../about/widget/address_card.dart';
import '../auth/auth.controller.dart';
import '../campaign/campaign.model.dart';
import '../get_nav.dart';
import '../shared/custom_button.dart';
import '../shared/custom_text.dart';
import '../theme.dart';
import '../vote/vote.controller.dart';
import 'similar_page.dart';
import 'widget/edit_modal.dart';
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

  voteWithoutExample() {
    debugPrint(voteCtrl.voteAgenda.voteAt.toString());
    if (voteCtrl.voteAgenda.voteAt == null) {
      goToVoteWithoutExample();
    } else {
      Get.offNamed('/result');
    }
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
      const AddressCard(),
      const SizedBox(height: 8),
      VioletCard(),
      const SizedBox(height: 16),
    ];
    var whiteBackGroundWidgets = [
      CustomText(
          isFullWidth: true,
          typoType: TypoType.h1Bold,
          textAlign: TextAlign.center,
          text: '2022 ${campaign.koName} 주주총회 의안'),
      const SizedBox(height: 10),
      const CustomText(
          isFullWidth: true,
          typoType: TypoType.bodyLight,
          textAlign: TextAlign.center,
          text: '아래 작성 예시를 통해 정확한 정보를 알아보시고'),
      const CustomText(
          isFullWidth: true,
          typoType: TypoType.bodyLight,
          textAlign: TextAlign.center,
          text: '소중한 주주의 의견을 알려주세요!'),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: CustomOutlinedButton(
          label: '작성예시 보기',
          onPressed: () {
            goToVoteWithExample();
          },
          textColor: ColorType.orange,
          width: CustomW.w4,
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
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
      title: '캠페인',
      blueBackGroundWidgets: blueBackGroundWidgets,
      whiteBackGroundWidgets: whiteBackGroundWidgets,
      animatedWidgets: Container(),
    );
  }
}
