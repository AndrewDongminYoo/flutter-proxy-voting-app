// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;
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
  final AuthController _authCtrl = AuthController.get();
  final VoteController _voteCtrl = VoteController.get();
  bool isLoading = false;

  Widget _gradientLayer() {
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

  Widget _campaignHeader(Campaign campaign) {
    return CustomText(
      text: campaign.slogan,
      typoType: TypoType.h1Bold,
      colorType: ColorType.white,
      textAlign: TextAlign.left,
    );
  }

  Widget _campaignInfoInRow(Campaign campaign) {
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
            CampaignProgress(value: 1.0),
          ],
        )
      ],
    );
  }

  Widget _campaignAgendaList(Campaign campaign) {
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
                fontSize: 16,
                height: 40.0,
                onPressed: () async {
                  await launchUrlString(campaign.dartUrl);
                })
          ],
        ),
        const SizedBox(height: 16),
        Column(
            children: campaign.agendaList.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: CustomCard(
                content: ListTile(
                  title: CustomText(
                      text: item.section,
                      typoType: TypoType.body,
                      textAlign: TextAlign.left),
                  subtitle: CustomText(
                      text: item.head,
                      typoType: TypoType.bodySmaller,
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
                      child: CustomText(
                        text: item.agendaFrom,
                        typoType: TypoType.bodySmaller,
                      )),
                ),
                cardPadding: 0),
          );
        }).toList())
      ],
    );
  }

  Widget _buildConfirmButton() {
    if (_authCtrl.canVote) {
      return AnimatedButton(
          isLoading: isLoading,
          label: _voteCtrl.isCompleted ? '위임내역 확인하기' : '전자위임 하러가기',
          width: CustomW.w4,
          onPressed: () async {
            debugPrint('[campaign] Hello, ${_authCtrl.user.username}!');
            _voteCtrl.toVote(_authCtrl.user.id, _authCtrl.user.username);
          });
    } else {
      return CustomConfirmWithButton(
          buttonLabel: '전자위임 하러가기',
          message: '서비스 이용을 위해\n본인인증이 필요해요.',
          okLabel: '인증하러가기',
          onConfirm: () {
            goToSignUp();
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: '', bgColor: const Color(0xFF5E3F74)),
      body: Stack(fit: StackFit.expand, children: [
        _gradientLayer(),
        SizedBox(
          height: Get.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _campaignHeader(_voteCtrl.campaign),
                  const SizedBox(height: 48),
                  _campaignInfoInRow(_voteCtrl.campaign),
                  const SizedBox(height: 86),
                  _campaignAgendaList(_voteCtrl.campaign),
                  const SizedBox(height: 24),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        )
      ]),
      floatingActionButton: _buildConfirmButton(),
    );
  }
}
