// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 🌎 Project imports:
import '../theme.dart';
import 'mts.controller.dart';
import '../shared/shared.dart';
import 'widgets/enhance_stepper.dart';

class MTSCertImportPage extends StatefulWidget {
  const MTSCertImportPage({Key? key}) : super(key: key);

  @override
  State<MTSCertImportPage> createState() => _MTSCertImportPageState();
}

class _MTSCertImportPageState extends State<MTSCertImportPage> {
  final MtsController _mtsController = MtsController.get();
  int _index = 0;
  String twelveDigits = '';

  controller() => TextEditingController(
        text: twelveDigits,
      );

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
      body: EnhanceStepper(
        stepIconSize: 45,
        currentStep: _index,
        onStepContinue: onContinue,
        onStepCancel: onCancel,
        onStepTapped: (i) => onTapped(i),
        physics: const ClampingScrollPhysics(),
        controlsBuilder: ((context, details) {
          ButtonStyleButton nextLevel = ElevatedButton(
            onPressed: onContinue,
            child: const Text('다음단계로'),
          );
          ButtonStyleButton prevLevel = ElevatedButton(
            onPressed: onCancel,
            child: const Text('이전단계로'),
          );
          switch (details.stepIndex) {
            case 0:
              nextLevel = ElevatedButton(
                onPressed: copyBside,
                child: const Text('링크복사'),
              );
              break;
            case 1:
              break;
            case 2:
              nextLevel = ElevatedButton(
                onPressed: onPressed,
                child: const Text('인증번호생성'),
              );
              break;
            case 3:
              nextLevel = TextButton(
                onPressed: () {},
                child: const Text('가져오기 완료'),
              );
              break;
          }
          return Row(
            children: <Widget>[
              const SizedBox(width: 10),
              nextLevel,
              const SizedBox(width: 20),
              prevLevel,
            ],
          );
        }),
        steps: [
          EnhanceStep(
            icon: EnhanceIcon(icon: Icons.link),
            title: const Text('비사이드 홈페이지에 접속하세요.'),
            content: const Text(''),
          ),
          EnhanceStep(
            icon: EnhanceIcon(icon: Icons.import_export),
            title: const Text('인증서 내보내기 선택해주세요.'),
            content: Container(
              color: Colors.deepPurple,
            ),
          ),
          EnhanceStep(
            icon: EnhanceIcon(icon: Icons.password),
            title: const Text('인증서 선택 후 비밀번호 입력 해주세요.'),
            content: const Text(''),
          ),
          EnhanceStep(
              icon: EnhanceIcon(icon: Icons.verified),
              title: const Text('아래 인증번호 12자리를 입력해 주세요.'),
              content: TextFormField(
                controller: controller(),
                maxLength: 14,
                textAlignVertical: TextAlignVertical.center,
                textAlign: TextAlign.center,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.number,
                autofocus: true,
                readOnly: true,
              ),
              state: StepState.editing),
        ],
      ),
    );
  }

  void copyBside() {
    Clipboard.setData(
      const ClipboardData(
        text: 'https://relay.coocon.net/beside/#none',
      ),
    );
    print('클립보드에 복사되었습니다.');
    onContinue();
  }

  onTapped(int index) {
    print('selected index: $index');
  }

  onCancel() {
    setState(() {
      if (_index > 0) {
        _index--;
      }
    });
  }

  onContinue() {
    setState(() {
      if (_index < 3) {
        _index++;
      }
    });
  }

  onPressed() async {
    String pin = await _mtsController.loadTwelveDigits();
    setState(() {
      String num1 = pin.substring(0, 4);
      String num2 = pin.substring(4, 8);
      String num3 = pin.substring(8, 12);
      twelveDigits = [num1, num2, num3].join('-');
    });
    onContinue();
  }
}

// ignore: must_be_immutable
class EnhanceIcon extends StatelessWidget {
  EnhanceIcon({
    super.key,
    required this.icon,
  });

  IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.deepPurpleAccent),
      child: Icon(
        icon,
        color: Colors.white,
        size: 30,
      ),
    );
  }
}
