// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../about/widget/address_card.dart';
import '../auth/auth.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/shared.dart';
import '../theme.dart';
import '../vote/vote.controller.dart';
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
      jumpToResult();
    }
  }

  onEdit() async {
    await Get.dialog(const EditModal());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Campaign campaign = voteCtrl.campaign;
    bool isLoggedIn = authCtrl.user.id > 0;

    const boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(24.0),
        bottomRight: Radius.circular(24.0),
      ),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xff60457A),
          Color(0xff80A1DF),
        ],
      ),
    );
    return Scaffold(
      appBar: CustomAppBar(text: '캠페인'),
      body: SizedBox(
        height: Get.height - 100,
        width: Get.width,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
                child: Column(
              children: [
                Container(
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: boxDecoration,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      CustomText(
                        typoType: TypoType.h1,
                        text: campaign.koName,
                        colorType: ColorType.white,
                      ),
                      const SizedBox(height: 16),
                      Avatar(image: campaign.logoImg, radius: 40),
                      const SizedBox(height: 16),
                      CustomText(
                        typoType: TypoType.h1,
                        text: isLoggedIn
                            ? '안녕하세요! ${authCtrl.user.username} 주주님'
                            : '안녕하세요! 주주님',
                        colorType: ColorType.white,
                      ),
                      const SizedBox(height: 16),
                      const AddressCard(),
                      const SizedBox(height: 8),
                      VioletCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                const SizedBox(height: 37),
                Container(
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                          isFullWidth: true,
                          typoType: TypoType.h1Bold,
                          textAlign: TextAlign.center,
                          text: '2022 ${campaign.koName} 주주총회 의안'),
                      const SizedBox(height: 10),
                      CustomText(
                          isFullWidth: true,
                          typoType: TypoType.bodyLight,
                          textAlign: TextAlign.center,
                          text: '아래 작성 예시를 통해 정확한 정보를 알아보시고'),
                      CustomText(
                          isFullWidth: true,
                          typoType: TypoType.bodyLight,
                          textAlign: TextAlign.center,
                          text: '소중한 주주님의 의견을 알려주세요!'),
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
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            )),
          ],
        ),
      ),
      // floatingActionButton: const CustomFloatingButton()
    );
  }
}
