import '../vote/vote.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared/custom_button.dart';
import '../shared/custom_grid.dart';
import 'campaign.model.dart';
import 'campaign.controller.dart';
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
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());
  final AuthController _authController = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  final VoteController _voteController = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  _buildConfirmButton() {
    // FIXME: 디버깅용
    // return CustomButton(
    //     label: '투표하러가기',
    //     width: CustomW.w4,
    //     onPressed: () {
    //       _voteController.toVote("소재우");
    //     });

    if (_authController.canVote()) {
      return CustomButton(
          label: '전자위임 하러가기',
          width: CustomW.w4,
          onPressed: () {
            print(_authController.user!.username);
            _voteController.toVote(_authController.user!.username);
          });
    } else if (!_authController.isLogined) {
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
                  campaignHeader(_controller.campaign),
                  const SizedBox(height: 48),
                  campaignInfoInRow(_controller.campaign),
                  const SizedBox(height: 86),
                  campaignAgendaList(_controller.campaign),
                  const SizedBox(height: 24),
                  _controller.campaign.companyName == "티엘아이"
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
  return Text(campaign.slogan,
      style: const TextStyle(
          color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800));
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
        onTap: () {}),
    ActionMenu(
        icon: Icons.attach_file_rounded,
        color: Colors.deepPurple,
        label: '공시서류',
        onTap: () {}),
    ActionMenu(
        icon: Icons.history_rounded,
        color: Colors.deepPurple,
        label: '이전기록',
        onTap: () {}),
  ];

  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // SizedBox(
      //   height: 72,
      //   child: ListView.builder(
      //       shrinkWrap: true,
      //       scrollDirection: Axis.horizontal,
      //       itemCount: actionMenuList.length + 1,
      //       itemBuilder: (BuildContext context, int index) => index == 0
      //           ? const SizedBox(
      //               width: 41,
      //             )
      //           : iconButton(actionMenuList[index - 1])),
      // ),
      // const SizedBox(height: 16),
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
        text: "${campaign.moderator} | 주주총회 일정: ${campaign.date}",
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
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(
          actionMenu.icon,
          color: actionMenu.color,
        ),
        Text(actionMenu.label)
      ]),
    ),
  );
}

Widget campaignAgendaList(Campaign campaign) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const CustomText(
          typoType: TypoType.h1Bold,
          text: '주주총회의안',
          colorType: ColorType.white),
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
            trailing:
                TextButton(onPressed: () {}, child: Text(item.agendaFrom)),
          ),
        );
      }).toList())
    ],
  );
}
