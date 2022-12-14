// π¦ Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// π¦ Package imports:
import 'package:url_launcher/url_launcher_string.dart';

// π Project imports:
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
  // TODO: λ°μ΄ν° μ§μ  μλ ₯ μ κ±°νκΈ°
  final String _contact = '';
  final String _tele = '';

  final VoteController _voteCtrl = VoteController.get();

  _onPressedMail() async {
    String body = """
'μ£Όμ£ΌλͺλΆμ λ±λ‘λμ΄ μμ§ μμ΅λλ€.'λΌλ λ©μΈμ§κ° λνλ©λλ€.
μ±ν¨: ${_voteCtrl.shareholder.username}
νμ¬: ${_voteCtrl.voteAgenda.company}
κΈ°ν: ~${_voteCtrl.campaign.date} κΉμ§
""";
    try {
      final Mailto mailTo = Mailto(
        to: [_contact],
        cc: [
        ],
        subject: 'μ£Όμ£ΌλͺλΆμ λ±λ‘λμ΄ μμ§ μμ΅λλ€.',
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
        appBar: CustomAppBar(text: 'μΊ νμΈ'),
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
                                typoType: TypoType.h1, text: 'π§ $_contact'))),
                    InkWell(
                        onTap: _onCall,
                        child: CustomText(
                            typoType: TypoType.h1, text: 'π $_tele')),
                    const SizedBox(
                      height: 50,
                    ),
                    CustomButton(
                      label: 'λ€λ‘κ°κΈ°',
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
                      text: 'μ£Όμ£ΌλͺλΆμ λ±λ‘λμ΄μμ§ μμ΅λλ€.',
                      colorType: ColorType.white)),
              CustomText(
                  typoType: TypoType.bodyLight,
                  text: 'μ£Όμ£Όκ° λ§μΌμ€ κ²½μ° λ¬Έμν΄μ£ΌμκΈΈ λ°λλλ€.',
                  colorType: ColorType.white),
            ]));
}
