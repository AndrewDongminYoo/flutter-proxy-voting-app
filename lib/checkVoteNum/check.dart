import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../checkVoteNum/check.dart';
import '../campaign/campaign.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';

class CheckVoteNumPage extends StatefulWidget {
  const CheckVoteNumPage({Key? key}) : super(key: key);
  @override
  State<CheckVoteNumPage> createState() => _CheckVoteNumPageState();
}

class _CheckVoteNumPageState extends State<CheckVoteNumPage> {
  goBack() {
    Get.back();
  }

  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: customColor[ColorType.deepPurple],
          elevation: 0,
          leading: IconButton(
            tooltip: "뒤로가기",
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFFFFFFFF)),
            onPressed: goBack,
          ),
          title: const Text('본인확인 자료'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[complete(_controller.campaign), adress()],
          ),
        ));
  }
}

Widget adress() {
  return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Spacer(),
          const CustomText(
            typoType: TypoType.h2Bold,
            text: '감사합니다. 소재우 주주님',
          ),
          Container(
              width: double.infinity,
              height: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color(0xFFDC721E),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CustomText(
                              typoType: TypoType.body,
                              text: '주소',
                              colorType: ColorType.white),
                          Spacer(),
                          CustomText(
                              typoType: TypoType.bodyLight,
                              text: '수정하기',
                              colorType: ColorType.white),
                          // IconButton(onPressed: Navigator, icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          // color: Color(0xFFFFFFFF)),)
                        ],
                      ),
                      const Spacer(),
                      const CustomText(
                          typoType: TypoType.bodyLight,
                          text: '서울시 송파구',
                          colorType: ColorType.white),
                    ]),
              )),
          const Spacer(),
          Container(
              width: double.infinity,
              height: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color(0xff582E66),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      CustomText(
                          typoType: TypoType.body,
                          text: '보유 주소',
                          colorType: ColorType.white),
                      Spacer(),
                      CustomText(
                          typoType: TypoType.bodyLight,
                          text: '1000주',
                          colorType: ColorType.white)
                    ]),
              )),
        ]),
      ));
}

Widget complete(Campaign campaign) {
  return Container(
    width: 1000,
    height: 400,
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff60457A), Color(0xff80A1DF)])),
    child: Column(children: <Widget>[
      Container(
          margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
          child: const CustomText(
              typoType: TypoType.h1,
              text: '사조 산업',
              colorType: ColorType.white)),
      Container(
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
        child: Align(
          child: CircleAvatar(
            foregroundImage: NetworkImage(campaign.logoImg),
            radius: 40,
            backgroundColor: customColor[ColorType.white],
          ),
        ),
      ),
      Container(
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: const CustomText(
              typoType: TypoType.h1,
              text: '수고하셨습니다.',
              colorType: ColorType.white)),
      const CustomText(
          typoType: TypoType.bodyLight,
          text: '성공적으로 전자위임이 완료되었습니다.',
          colorType: ColorType.white),
      const CustomText(
          typoType: TypoType.bodyLight,
          text: '다른 캠페인도 둘러보시겠어요?',
          colorType: ColorType.white),
      // IconButton(
      //     onPressed: () => Navigator.pushNamed(context, '/profile'),
      //     iconSize: 36,
      //     icon:
      //         const Icon(Icons.expand_more_rounded, color: Colors.white70)),
    ]),
  );
}
