import 'package:bside/auth/auth.data.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'campaign.model.dart';
import '../shared/custom_button.dart';
import '../vote/vote.controller.dart';
import '../shared/custom_grid.dart';
import '../shared/custom_text.dart';
import '../shared/custom_color.dart';
import '../auth/auth.controller.dart';
import '../shared/custom_appbar.dart';
import '../shared/progress_bar.dart';
import '../shared/custom_confirm.dart';

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
  User? user;

  @override
  void initState() {
    user = authCtrl.user;
    super.initState();
  }

  Widget campaignAgendaList(Campaign campaign) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const CustomText(
                typoType: TypoType.h1Bold,
                text: '주주총회의안',
                colorType: ColorType.white),
            const Spacer(),
            CustomButton(
                label: '의결권권유 공시',
                width: CustomW.w2,
                bgColor: ColorType.orange,
                textColor: ColorType.white,
                height: 40.0,
                onPressed: () async {
                  await launchUrl(Uri.parse(campaign.dartUrl));
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
                  child: Text(item.agendaFrom)),
            ),
          );
        }).toList())
      ],
    );
  }

  _buildConfirmButton() {
    if (authCtrl.canVote()) {
      return AnimatedButton(
          isLoading: isLoading,
          label: '전자위임 하러가기',
          width: CustomW.w4,
          onPressed: () async {
            isLoading = true;
            print('[campaign] Hello, ${authCtrl.user!.username}!');
            if (user != null) {
              voteCtrl.toVote(authCtrl.user!.id, authCtrl.user!.username);
            }
            isLoading = false;
          });
    } else if (!authCtrl.isLogined) {
      return CustomConfirm(
          buttonLabel: '전자위임 하러가기',
          message: '서비스 이용을 위해\n본인인증이 필요해요.',
          okLabel: '인증하러가기',
          onConfirm: () {
            Get.toNamed('/signup');
          });
    } else {
      // NOTE: 전화번호 인증 혹은 본인정보 확인 필요
      print('Need verify telNumber');
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '', bgColor: Color(0xFF5E3F74)),
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
                  voteCtrl.campaign.companyName == '티엘아이'
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
  return Text(
    campaign.slogan,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 28,
      fontWeight: FontWeight.w800,
    ),
  );
  // return CustomText(
  //   typoType: TypoType.h1,
  //   text: campaign.slogan,
  //   textAlign: TextAlign.left,
  //   colorType: ColorType.white,
  // );
}

Widget campaignInfoInRow(Campaign campaign) {
  // ignore: unused_local_variable
  final actionMenuList = <ActionMenu>[
    ActionMenu(
        icon: Icons.book_rounded,
        color: Colors.deepOrange,
        label: '전자위임',
        onTap: () {
          Get.toNamed('/vote');
        }),
    ActionMenu(
        icon: Icons.group_add_rounded,
        color: Colors.deepPurple,
        label: '라운지',
        onTap: () {
          // TODO: 라운지 구현
        }),
    ActionMenu(
        icon: Icons.attach_file_rounded,
        color: Colors.deepPurple,
        label: '공시서류',
        onTap: () {
          // TODO: 공시서류 페이지
        }),
    ActionMenu(
        icon: Icons.history_rounded,
        color: Colors.deepPurple,
        label: '이전기록',
        onTap: () {
          // TODO: 이전 기록 보여주기
        }),
  ];

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Hero(
        tag: 'companyLogo',
        child: CircleAvatar(
            backgroundImage: NetworkImage(campaign.logoImg),
            backgroundColor: Colors.white,
            radius: 16),
      ),
      const SizedBox(height: 16),
      CustomText(
        typoType: TypoType.h2Bold,
        text: campaign.companyName,
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
          const CustomText(
              typoType: TypoType.body,
              text: '진행상황',
              colorType: ColorType.white),
          const SizedBox(width: 41),
          // TODO: 캠페인 인디케이터
          CampaignProgress(value: campaign.companyName == '티엘아이' ? 0.6 : 1.0),
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
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            actionMenu.icon,
            color: actionMenu.color,
          ),
          Text(actionMenu.label)
        ],
      ),
    ),
  );
}
