import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../checkVoteNum/check.dart';
import '../About/address.dart';
import '../campaign/campaign.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/back_button.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);
  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: customColor[ColorType.deepPurple],
          elevation: 0,
          leading: const CustomBackButton(),
          title: const Text('본인확인 자료'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Complete(_controller.campaign),
              const Address(),
              progress()
            ],
          ),
        ));
  }
}

Widget Complete(Campaign campaign) {
  return Container(
    width: double.infinity,
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
          child: CustomText(
              typoType: TypoType.h1,
              text: campaign.companyName,
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

Widget progress() {
  return Stepper(
    type: StepperType.vertical,
    steps: const [
      Step(
        title: Text('Step 1 title'),
        content: Text(''),
      ),
      Step(
        title: Text('Step 2 title'),
        content: Text(''),
      ),
    ],
  );
}
