// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/shared.dart';
import '../theme.dart';
import '../vote/vote.dart';
import 'about.dart';

class VoteResultPage extends StatefulWidget {
  const VoteResultPage({Key? key}) : super(key: key);
  @override
  State<VoteResultPage> createState() => _VoteResultPageState();
}

class _VoteResultPageState extends State<VoteResultPage> {
  final AuthController _authCtrl = AuthController.get();
  final VoteController _voteCtrl = VoteController.get();

  @override
  Widget build(BuildContext context) {
    const white = ColorType.white;
    Campaign campaign = _voteCtrl.campaign;
    VoteAgenda voteAgenda = _voteCtrl.voteAgenda;
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
                          text: '${_authCtrl.user.username}님 수고하셨습니다.',
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
                      VioletCard(),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Column(
                  children: [
                    StepperCard(
                      agenda: _voteCtrl.voteAgenda,
                      shareId: _voteCtrl.shareholder.id,
                    ),
                    const SizedBox(height: 30),
                    CustomButton(
                      label: '처음으로',
                      width: CustomW.w4,
                      onPressed: jumpToMainHome,
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
