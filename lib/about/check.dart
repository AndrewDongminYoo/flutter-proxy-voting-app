// ignore_for_file: unused_import

import 'package:bside/About/complete_page.dart';
import 'package:bside/about/result.dart';
import 'package:bside/shared/custom_button.dart';
import 'package:bside/shared/custom_grid.dart';
import 'package:bside/shared/notice_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../campaign/campaign.controller.dart';
import '../campaign/campaign.model.dart';
import '../shared/back_button.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';

class CheckVoteNumPage extends StatefulWidget {
  const CheckVoteNumPage({Key? key}) : super(key: key);
  @override
  State<CheckVoteNumPage> createState() => _CheckVoteNumPageState();
}

class _CheckVoteNumPageState extends State<CheckVoteNumPage> {
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());

  @override
  Widget build(BuildContext context) {
    Campaign campaign = _controller.campaign;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: customColor[ColorType.deepPurple],
        elevation: 0,
        leading: const CustomBackButton(),
        title: const Text('본인확인 자료'),
        actions: const [
          NoticeButton(),
        ],
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            const CompleteWidget(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                      typoType: TypoType.h1Bold,
                      textAlign: TextAlign.left,
                      text: '2022 ${campaign.companyName} 주주총회 의안'),
                  const SizedBox(height: 10),
                  const CustomText(
                      typoType: TypoType.bodyLight,
                      textAlign: TextAlign.left,
                      text: '아래 작성 예시를 통해 정확한 정보를 알아보시고'),
                  const CustomText(
                      typoType: TypoType.bodyLight,
                      textAlign: TextAlign.left,
                      text: '소중한 주주의 의견을 알려주세요!'),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomOutlinedButton(
                      label: "작성예시 보기",
                      onPressed: () {},
                      textColor: ColorType.orange,
                      width: CustomW.w4,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomButton(
                      label: "투표하러 가기",
                      onPressed: () {},
                      width: CustomW.w4,
                    ),
                  ),
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
