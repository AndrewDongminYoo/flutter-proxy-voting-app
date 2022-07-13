// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import '../auth/auth.controller.dart';
import '../campaign/campaign.model.dart';
import '../theme.dart';
import '../vote/vote.dart';
import 'about.dart';

class ShowResultPage extends StatefulWidget {
  const ShowResultPage({Key? key}) : super(key: key);
  @override
  State<ShowResultPage> createState() => _ShowResultPageState();
}

class _ShowResultPageState extends State<ShowResultPage> {
  AuthController authCtrl = AuthController.get();
  VoteController voteCtrl = VoteController.get();

  @override
  Widget build(BuildContext context) {
    const white = ColorType.white;
    Campaign campaign = voteCtrl.campaign;
    VoteAgenda voteAgenda = voteCtrl.voteAgenda;
    final String youAreDoneText;
    if (voteAgenda.idCardAt != null &&
        voteAgenda.backIdAt != null &&
        voteAgenda.signatureAt != null) {
      youAreDoneText = '성공적으로 전자위임이 완료되었습니다.';
    } else {
      youAreDoneText = '잠깐! 부족한 정보를 채워주세요. 🥺 ';
    }
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
      appBar: CustomAppBar(text: '결과 확인'),
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
                      Container(
                          margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
                          child: CustomText(
                              typoType: TypoType.h1,
                              text: campaign.koName,
                              colorType: white)),
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
                          colorType: white,
                        ),
                      ),
                      CustomText(
                        typoType: TypoType.bodyLight,
                        text: youAreDoneText,
                        colorType: white,
                      ),
                      const SizedBox(height: 20),
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
                                  colorType: white),
                              const SizedBox(height: 21),
                              CustomText(
                                  typoType: TypoType.bodyLight,
                                  text: '${voteCtrl.voteAgenda.sharesNum}',
                                  colorType: white)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    StepperCard(
                      agenda: voteCtrl.voteAgenda,
                      shareId: voteCtrl.shareholder.id,
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      label: '처음으로',
                      width: CustomW.w4,
                      onPressed: jumpToHome,
                    ),
                    const SizedBox(height: 100)
                  ],
                ),
              ],
            )),
          ],
        ),
      ),
      // floatingActionButton: const CustomFloatingButton()
    );
  }
}
