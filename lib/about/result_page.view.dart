// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/custom_avatar.dart';
import '../shared/get_nav.dart';
import '../auth/auth.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/custom_button.dart';
import '../shared/custom_text.dart';
import '../theme.dart';
import '../vote/vote.controller.dart';
import '../vote/vote.model.dart';
import 'similar_page.dart';
import 'widget/stepper_card.dart';
import 'widget/address_card.dart';

class ShowResultPage extends StatefulWidget {
  const ShowResultPage({Key? key}) : super(key: key);
  @override
  State<ShowResultPage> createState() => _ShowResultPageState();
}

class _ShowResultPageState extends State<ShowResultPage> {
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  @override
  Widget build(BuildContext context) {
    VoteAgenda voteAgenda = voteCtrl.voteAgenda;
    final String youAreDoneText;
    if (voteAgenda.idCardAt != null &&
        voteAgenda.backIdAt != null &&
        voteAgenda.signatureAt != null) {
      youAreDoneText = '성공적으로 전자위임이 완료되었습니다.';
    } else {
      youAreDoneText = '잠깐! 부족한 정보를 채워주세요. 🥺 ';
    }

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
        child: Avatar(
          image: campaign.logoImg,
          radius: 40,
        ),
      ),
      Container(
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: CustomText(
          typoType: TypoType.h1,
          text: '${authCtrl.user.username}님 수고하셨습니다.',
          colorType: ColorType.white,
        ),
      ),
      CustomText(
        typoType: TypoType.bodyLight,
        text: youAreDoneText,
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
              CustomText(
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
        StepperCard(
          agenda: voteCtrl.voteAgenda,
          shareId: voteCtrl.shareholder.id,
        ),
        const SizedBox(height: 30),
        CustomButton(
          label: '처음으로',
          width: CustomW.w4,
          onPressed: () {
            jumpToHome();
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
