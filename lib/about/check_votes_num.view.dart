// π¦ Flutter imports:
import 'package:flutter/material.dart';

// π¦ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// π Project imports:
import '../auth/auth.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/shared.dart';
import '../theme.dart';
import '../vote/vote.controller.dart';
import 'widget/widget.dart';

class VoteNumCheckPage extends StatefulWidget {
  const VoteNumCheckPage({Key? key}) : super(key: key);
  @override
  State<VoteNumCheckPage> createState() => _VoteNumCheckPageState();
}

class _VoteNumCheckPageState extends State<VoteNumCheckPage> {
  final VoteController _voteCtrl = VoteController.get();
  final AuthController _authCtrl = AuthController.get();

  _voteWithoutExample() {
    print(_voteCtrl.voteAgenda.voteAt);
    if (_voteCtrl.voteAgenda.voteAt == null) {
      goVoteNoExample();
    } else {
      jumpToVoteResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    Campaign campaign = _voteCtrl.campaign;
    bool isLoggedIn = _authCtrl.user.id > 0;

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
      appBar: CustomAppBar(text: 'μΊ νμΈ'),
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
                            ? 'μλνμΈμ! ${_authCtrl.user.username} μ£Όμ£Όλ'
                            : 'μλνμΈμ! μ£Όμ£Όλ',
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
                          text: '2022 ${campaign.koName} μ£Όμ£Όμ΄ν μμ'),
                      const SizedBox(height: 10),
                      CustomText(
                          isFullWidth: true,
                          typoType: TypoType.bodyLight,
                          textAlign: TextAlign.center,
                          text: 'μλ μμ± μμλ₯Ό ν΅ν΄ μ νν μ λ³΄λ₯Ό μμλ³΄μκ³ '),
                      CustomText(
                          isFullWidth: true,
                          typoType: TypoType.bodyLight,
                          textAlign: TextAlign.center,
                          text: 'μμ€ν μ£Όμ£Όλμ μκ²¬μ μλ €μ£ΌμΈμ!'),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomOutlinedButton(
                          label: 'μμ±μμ λ³΄κΈ°',
                          onPressed: () {
                            goVoteWithExample();
                          },
                          textColor: ColorType.orange,
                          width: CustomW.w4,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: CustomButton(
                          label: 'ν¬ννλ¬ κ°κΈ°',
                          onPressed: () {
                            _voteWithoutExample();
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
