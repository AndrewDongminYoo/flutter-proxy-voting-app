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
          children: <Widget>[
            complete(_controller.campaign),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                      typoType: TypoType.h1Bold,
                      textAlign: TextAlign.left,
                      text: '2022 ${_controller.campaign.companyName} 주주총회 의안'),
                  const CustomText(
                      typoType: TypoType.bodyLight,
                      textAlign: TextAlign.left,
                      text: '아래 작성 예시를 통해 정확한 정보를 알아보시고'),
                  const CustomText(
                      typoType: TypoType.bodyLight,
                      textAlign: TextAlign.left,
                      text: '소중한 주주의 의견을 알려주세요!'),
                  // CustomOutlinedButton(
                  //     textColor: customColor[ColorType.orange])
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: customColor[ColorType.yellow],
        child: const Icon(Icons.chat_rounded, color: Color(0xFFDC721E)),
      ),
    );
  }
}

Widget adress() {
  return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Spacer(
            flex: 2,
          ),
          Container(
              width: double.infinity,
              height: 120,
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
                              textAlign: TextAlign.left,
                              colorType: ColorType.white),
                          Spacer(),
                          CustomText(
                              typoType: TypoType.bodyLight,
                              text: '수정하기',
                              textAlign: TextAlign.left,
                              colorType: ColorType.white),
                        ],
                      ),
                      const Spacer(),
                      const CustomText(
                          typoType: TypoType.bodyLight,
                          text: '서울시 송파구 아무로 12-2길 32, 송파아크 로펠리스 타워 102동 707호',
                          textAlign: TextAlign.left,
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
          const Spacer(
            flex: 2,
          ),
        ]),
      ));
}

Widget complete(Campaign campaign) {
  return Container(
    width: double.infinity,
    height: 500,
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff60457A), Color(0xff80A1DF)])),
    child: Column(children: <Widget>[
      const Spacer(),
      const CustomText(
          typoType: TypoType.h1, text: '안녕하세요!', colorType: ColorType.white),
      const CustomText(
          typoType: TypoType.h1, text: '소재우 주주님', colorType: ColorType.white),
      const Spacer(),
      Align(
        child: CircleAvatar(
          foregroundImage: NetworkImage(campaign.logoImg),
          radius: 40,
          backgroundColor: customColor[ColorType.white],
        ),
      ),
      const Spacer(),
      CustomText(
          typoType: TypoType.h1,
          text: campaign.companyName,
          colorType: ColorType.white),
      adress()
    ]),
  );
}
