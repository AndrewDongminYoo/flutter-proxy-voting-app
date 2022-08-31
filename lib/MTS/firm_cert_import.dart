// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

// 🌎 Project imports:
import '../theme.dart';
import 'mts.controller.dart';
import '../shared/shared.dart';
import '../auth/widget/widget.dart';

class MTSCertImportPage extends StatefulWidget {
  const MTSCertImportPage({Key? key}) : super(key: key);

  @override
  State<MTSCertImportPage> createState() => _MTSCertImportPageState();
}

class _MTSCertImportPageState extends State<MTSCertImportPage> {
  final MtsController _mtsController = MtsController.get();
  int _index = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: CustomAppBar(
        text: '',
        bgColor: Colors.white,
        helpButton: IconButton(
          icon: Icon(
            Icons.help,
            color: customColor[ColorType.deepPurple],
          ),
          onPressed: () {
            // TODO: 뭐 넣지..
          },
        ),
      ),
      body: Theme(
        data: theme.copyWith(
          iconTheme: theme.iconTheme.copyWith(size: 55.0),
          colorScheme: theme.colorScheme.copyWith(
            primary: Colors.deepPurple,
            secondary: Colors.orange,
            error: Colors.red,
          ),
        ),
        child: Stepper(
          currentStep: _index,
          onStepContinue: (() {
            setState(() {
              if (_index < 3) {
                _index++;
              }
            });
          }),
          onStepCancel: (() {
            setState(() {
              if (_index > 0) {
                _index--;
              }
            });
          }),
          onStepTapped: ((int index) {
            print('selected index: $index');
          }),
          steps: [
            Step(
                title: const Text('비사이드 홈페이지에 접속하세요.'),
                content: TextButton(
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(
                          text: 'https://relay.coocon.net/beside/#none',
                        ),
                      );
                      print('클립보드에 복사되었습니다.');
                    },
                    child: const Text('비사이드 홈페이지 링크 복사'))),
            Step(
              title: const Text('인증서 내보내기 선택해주세요.'),
              content: Container(
                color: Colors.deepPurple,
              ),
            ),
            Step(
              title: const Text('인증서 선택 후 비밀번호 입력 해주세요.'),
              content: Container(
                color: Colors.deepPurple,
              ),
            ),
            Step(
              title: const Text('아래 인증번호 12자리를 입력해 주세요.'),
              content: Container(
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
