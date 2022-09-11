// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:url_launcher/url_launcher_string.dart';

// 🌎 Project imports:
import '../campaign/campaign.model.dart';
import '../shared/shared.dart';
import '../theme.dart';
import '../utils/mailto_class.dart';
import '../vote/vote.controller.dart';

class NotShareholderPage extends StatefulWidget {
  const NotShareholderPage({Key? key}) : super(key: key);
  @override
  State<NotShareholderPage> createState() => _NotShareholderPageState();
}

class _NotShareholderPageState extends State<NotShareholderPage> {
  // TODO: 데이터 직접 입력 제거하기
  final String _contact = 'sjcho0070@naver.com';
  final String _tele = '010-8697-1669';

  final VoteController _voteCtrl = VoteController.get();

  _onPressedMail() async {
    String body = """
'주주명부에 등록되어 있지 않습니다.'라는 메세지가 나타납니다.
성함: ${_voteCtrl.shareholder.username}
회사: ${_voteCtrl.voteAgenda.company}

받는사람: $_tele 조상준 $_contact
기한: ~${_voteCtrl.campaign.date} 까지
>> Bside Co.ltd.
""";
    try {
      final Mailto mailTo = Mailto(
        to: [_contact],
        cc: [
          'aaron.so@bside.ai',
          'andrew@bside.ai',
        ],
        subject: '주주명부에 등록되어 있지 않습니다.',
        body: body,
      );
      await launchUrlString('$mailTo');
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: _contact));
    }
  }

  _onCall() {
    launchUrlString('tel:$_tele');
  }

  @override
  Widget build(BuildContext context) {
    Campaign campaign = _voteCtrl.campaign;
    return Scaffold(
        appBar: CustomAppBar(text: '캠페인'),
        body: SizedBox(
          child: ListView(
            children: [
              NotShareholder(campaign: campaign),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    InkWell(
                        onTap: _onPressedMail,
                        child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            child: CustomText(
                                typoType: TypoType.h1, text: '📧 $_contact'))),
                    InkWell(
                        onTap: _onCall,
                        child: CustomText(
                            typoType: TypoType.h1, text: '📞 $_tele')),
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

class NotShareholder extends Container {
  final Campaign campaign;

  NotShareholder({
    Key? key,
    required this.campaign,
  }) : super(
            key: key,
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
                  child: CustomText(
                      typoType: TypoType.h1,
                      text: '',
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
                  child: CustomText(
                      typoType: TypoType.h1,
                      text: '주주명부에 등록되어있지 않습니다.',
                      colorType: ColorType.white)),
              CustomText(
                  typoType: TypoType.bodyLight,
                  text: '주주가 맞으실 경우 문의해주시길 바랍니다.',
                  colorType: ColorType.white),
            ]));
}
