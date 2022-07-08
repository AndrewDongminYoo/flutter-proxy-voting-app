// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

// 🌎 Project imports:
import '../campaign/campaign.model.dart';
import '../get_nav.dart';
import '../shared/custom_appbar.dart';
import '../shared/custom_button.dart';
import '../shared/custom_text.dart';
import '../theme.dart';
import '../utils/mailto.dart';
import '../vote/vote.controller.dart';

class NotShareholderPage extends StatefulWidget {
  const NotShareholderPage({Key? key}) : super(key: key);
  @override
  State<NotShareholderPage> createState() => _NotShareholderPageState();
}

class _NotShareholderPageState extends State<NotShareholderPage> {
  final contact = 'sjcho0070@naver.com';
  final tele = '010-8697-1669';

  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  onPressedMail() async {
    var body = """
'주주명부에 등록되어 있지 않습니다.'라는 메세지가 나타납니다.
성함: ${voteCtrl.shareholder.username}
회사: ${voteCtrl.voteAgenda.company}

받는사람: $tele 조상준 $contact
기한: ~${voteCtrl.campaign.date} 까지
>> Bside Co.ltd.
""";
    try {
      final mailTo = Mailto(
        to: [contact],
        cc: [
          'aaron.so@bside.ai',
          'andrew@bside.ai',
        ],
        subject: '주주명부에 등록되어 있지 않습니다.',
        body: body,
      );
      await launchUrlString('$mailTo');
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: contact));
    }
  }

  onCall() {
    launchUrl(Uri.parse('tel:$tele'));
  }

  @override
  Widget build(BuildContext context) {
    Campaign campaign = voteCtrl.campaign;

    return Scaffold(
        appBar: CustomAppBar(text: '캠페인'),
        body: SizedBox(
          child: ListView(
            children: [
              Temp(campaign: campaign),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    InkWell(
                        onTap: onPressedMail,
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: CustomText(
                                typoType: TypoType.h1, text: '📧 $contact'))),
                    InkWell(
                        onTap: onCall,
                        child: CustomText(
                            typoType: TypoType.h1, text: '📞 $tele')),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomButton(
                      label: '뒤로가기',
                      bgColor: ColorType.deepPurple,
                      onPressed: goBack,
                      width: CustomW.w4,
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class Temp extends StatefulWidget {
  const Temp({
    Key? key,
    required this.campaign,
  }) : super(key: key);

  final Campaign campaign;

  @override
  State<Temp> createState() => _TempState();
}

class _TempState extends State<Temp> {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 400,
        decoration: const BoxDecoration(
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
                ])),
        child: Column(children: <Widget>[
          Container(
              margin: const EdgeInsets.fromLTRB(0, 30, 0, 20),
              child: const CustomText(
                  typoType: TypoType.h1, text: '', colorType: ColorType.white)),
          Container(
            margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
            child: Align(
              child: CircleAvatar(
                foregroundImage: NetworkImage(widget.campaign.logoImg),
                radius: 40,
                backgroundColor: customColor[ColorType.white],
              ),
            ),
          ),
          Container(
              margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
              child: const CustomText(
                  typoType: TypoType.h1,
                  text: '주주명부에 등록되어있지 않습니다.',
                  colorType: ColorType.white)),
          const CustomText(
              typoType: TypoType.bodyLight,
              text: '주주가 맞으실 경우 문의해주시길 바랍니다.',
              colorType: ColorType.white),
        ]));
  }
}
