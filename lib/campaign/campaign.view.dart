// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../shared/shared.dart';
import '../vote/vote.controller.dart';
import '../theme.dart';
import 'campaign.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({Key? key}) : super(key: key);

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());
  bool isLoading = false;

  Widget campaignAgendaList(Campaign campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomText(
                typoType: TypoType.h1Bold,
                text: '주주총회의안',
                colorType: ColorType.white),
            const Spacer(),
            CustomButton(
                label: '의결권권유 공시',
                width: CustomW.w2,
                bgColor: ColorType.orange,
                textColor: ColorType.white,
                fontSize: 18,
                height: 40.0,
                onPressed: () async {
                  await launchUrlString(campaign.dartUrl);
                })
          ],
        ),
        const SizedBox(height: 16),
        Column(
            children: campaign.agendaList.map((item) {
          return Card(
            child: ListTile(
              title: CustomText(
                  text: item.section,
                  typoType: TypoType.body,
                  textAlign: TextAlign.left),
              subtitle: CustomText(
                  text: item.head,
                  typoType: TypoType.bodyLight,
                  textAlign: TextAlign.left,
                  colorType: ColorType.black),
              trailing: TextButton(
                  onPressed: () async {
                    if (mounted) {
                      setState(() {
                        isLoading = !isLoading;
                      });
                    }
                  },
                  child: CustomText(text: item.agendaFrom)),
            ),
          );
        }).toList())
      ],
    );
  }

  _buildConfirmButton() {
    if (authCtrl.canVote()) {
      return AnimatedButton(
          label: voteCtrl.isCompleted ? '위임내역 확인하기' : '전자위임 하러가기',
          width: CustomW.w4,
          onPressed: () async {
            debugPrint('[campaign] Hello, ${authCtrl.user.username}!');
            voteCtrl.toVote(authCtrl.user.id, authCtrl.user.username);
          });
    } else if (!authCtrl.isLogined) {
      return CustomConfirmWithButton(
          buttonLabel: '전자위임 하러가기',
          message: '서비스 이용을 위해\n본인인증이 필요해요.',
          okLabel: '인증하러가기',
          onConfirm: () {
            goToSignUp();
          });
    } else {
      // TODO: 전화번호 인증 혹은 본인정보 확인 필요
      debugPrint('Need verify telNumber');
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: '', bgColor: const Color(0xFF5E3F74)),
      body: Stack(fit: StackFit.expand, children: [
        gradientLayer(),
        SizedBox(
          height: Get.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  campaignHeader(voteCtrl.campaign),
                  const SizedBox(height: 48),
                  campaignInfoInRow(voteCtrl.campaign),
                  const SizedBox(height: 86),
                  campaignAgendaList(voteCtrl.campaign),
                  const SizedBox(height: 24),
                  voteCtrl.campaign.getStatus() == '더보기'
                      ? _buildConfirmButton()
                      : Container(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        )
      ]),
    );
  }
}

Widget gradientLayer() {
  return Positioned.fill(
      child: Container(
    width: Get.width,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF5E3F74),
          Color(0xFF82A5E1),
        ],
      ),
    ),
  ));
}

Widget campaignHeader(Campaign campaign) {
  return CustomText(
    text: campaign.slogan,
    typoType: TypoType.h1Bold,
    colorType: ColorType.white,
  );
}

Widget campaignInfoInRow(Campaign campaign) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Hero(
          tag: 'companyLogo',
          child: Avatar(
              image: campaign.logoImg,
              radius: 16,
              align: Alignment.centerLeft)),
      const SizedBox(height: 16),
      CustomText(
        typoType: TypoType.h2Bold,
        text: campaign.koName,
        colorType: ColorType.white,
      ),
      const SizedBox(height: 16),
      CustomText(
        typoType: TypoType.body,
        text: '${campaign.moderator} | 주주총회 일정: ${campaign.date}',
        colorType: ColorType.white,
      ),
      const SizedBox(height: 24),
      CustomText(
        typoType: TypoType.bodyLight,
        text: campaign.details,
        colorType: ColorType.white,
        textAlign: TextAlign.left,
      ),
      const SizedBox(height: 46),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
              typoType: TypoType.body,
              text: '진행상황',
              colorType: ColorType.white),
          const SizedBox(width: 41),
          // TODO: 캠페인 진행상황 서버에서 가져오기
          CampaignProgress(value: 1.0),
        ],
      )
    ],
  );
}

Widget iconButton(ActionMenu actionMenu) {
  return InkWell(
    onTap: actionMenu.onTap,
    child: Container(
      width: 82,
      height: 72,
      margin: const EdgeInsets.only(right: 10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            actionMenu.icon,
            color: actionMenu.color,
          ),
          CustomText(text: actionMenu.label)
        ],
      ),
    ),
  );
}
