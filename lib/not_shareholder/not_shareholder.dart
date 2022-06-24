import 'package:bside/shared/custom_button.dart';
import 'package:bside/shared/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/back_button.dart';
import '../shared/custom_color.dart';
import '../shared/custom_grid.dart';
import 'feedback_modal.dart';

class NotShareholderPage extends StatefulWidget {
  const NotShareholderPage({Key? key}) : super(key: key);

  @override
  State<NotShareholderPage> createState() => _NotShareholderPageState();
}

class _NotShareholderPageState extends State<NotShareholderPage> {
  // void downloadFileWeb(String url, String name) {
  //   html.AnchorElement anchorElement = new html.AnchorElement(href: url);
  //   anchorElement.download = name;
  //   anchorElement.click();
  // }
  // Future openFile({required String url}) async {
  //   final name = "PDF";
  //   if (identical(0, 0.0)) {
  //     downloadFileWeb(url, name);
  //     return;
  //   }
  //   final file = await download(url, name);
  //   if (file == null) {
  //     // print('oops');
  //     return;
  //   }
  //   OpenFile.open(file.path);
  // }

  // onPPTClicked() async {
  //   // TODO:
  //   await openFile(
  //       url:
  //           'https://s3.ap-northeast-2.amazonaws.com/lounge.bside.ai/APCM_%EC%97%90%EC%8A%A4%EC%97%A0+%EC%A3%BC%EC%A3%BC%EC%A0%9C%EC%95%88.pdf');
  // }

  onYoutube() async {
    await launchUrl(Uri.parse('https://www.youtube.com/watch?v=ic1BKge_d8s'));
  }

  onQnA() {
    Get.dialog(const FeedBackModal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: customColor[ColorType.deepPurple],
          elevation: 0,
          leading: const CustomBackButton(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomText(typoType: TypoType.h1, text: '소재우님'),
                const SizedBox(
                  height: 30,
                ),
                const CustomText(
                    typoType: TypoType.body, text: '주주 명분에 등록되어 있지 않습니다.'),
                const SizedBox(
                  height: 10,
                ),
                const CustomText(
                  typoType: TypoType.body,
                  text: '주주가 맞으실 경우, 우측 상단에 있는 문의하기를 통해 연락 부탁드립니다.',
                  textAlign: TextAlign.left,
                ),
                const SizedBox(
                  height: 10,
                ),
                const CustomText(
                  typoType: TypoType.body,
                  text:
                      '저희 캠페인에 관심이 있으실 경우 아래 내용에 동의해 주시면 향후 관련 업데이트 내용을 전달드릴 수 있도록 하겠습니다.',
                  textAlign: TextAlign.left,
                ),
                const SizedBox(
                  height: 10,
                ),
                const CustomText(
                  typoType: TypoType.body,
                  text: '감사합니다.',
                  textAlign: TextAlign.left,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    CustomButton(
                      label: '주주제안 영상',
                      onPressed: () {
                        onYoutube();
                      },
                      width: CustomW.w2,
                    ),
                    const Spacer(),
                    CustomButton(
                      label: '주주제안 PPT',
                      onPressed: () {},
                      width: CustomW.w2,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    CustomButton(
                      label: '처음으로',
                      onPressed: () {
                        Get.toNamed("/");
                      },
                      width: CustomW.w2,
                    ),
                    const Spacer(),
                    CustomButton(
                      label: '문의하기',
                      onPressed: onQnA,
                      width: CustomW.w2,
                    ),
                  ],
                ),
              ]),
        ));
  }
}
