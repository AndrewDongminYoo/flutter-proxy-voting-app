// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// 🌎 Project imports:
import '../theme.dart';
import '../shared/shared.dart';
import 'mts.dart';

class MTSImportCertPage extends StatefulWidget {
  const MTSImportCertPage({Key? key}) : super(key: key);

  @override
  State<MTSImportCertPage> createState() => _MTSImportCertPageState();
}

class _MTSImportCertPageState extends State<MTSImportCertPage> {
  final MtsController _mtsController = MtsController.get();
  int _index = 0;
  String num0 = '';
  String num1 = '';
  String num2 = '';

  @override
  void initState() {
    super.initState();
    checkCertList();
  }

  checkCertList() async {
    List<RKSWCertItem>? response = await _mtsController.loadCertList();
    if (response != null && response.isNotEmpty) {
      goMTSLoginCert();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<EnhanceStep> steps = [
      EnhanceStep(
        icon: EnhanceIcon(icon: Icons.link),
        title: const Text('비사이드 홈페이지에 접속하세요.'),
        content: const Text(''),
      ),
      EnhanceStep(
        icon: EnhanceIcon(icon: Icons.import_export),
        title: const Text('인증서 복사하기 선택해주세요.'),
        content: Image.asset('assets/images/screenshot_example1.png'),
      ),
      EnhanceStep(
        icon: EnhanceIcon(icon: Icons.password),
        title: const Text('인증서 선택 후 비밀번호 입력 해주세요.'),
        content: Image.asset('assets/images/screenshot_example2.png'),
      ),
      EnhanceStep(
          icon: EnhanceIcon(icon: Icons.verified),
          title: const Text('아래 인증번호 12자리를 입력해 주세요.'),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PurpleInputBox(value: num0),
              const Text(' - '),
              PurpleInputBox(value: num1),
              const Text(' - '),
              PurpleInputBox(value: num2),
            ],
          ),
          state: StepState.editing)
    ];
    return Scaffold(
      appBar: CustomAppBar(
        text: '',
        bgColor: Colors.transparent,
        helpButton: IconButton(
          icon: Icon(
            Icons.help,
            color: customColor[ColorType.deepPurple],
          ),
          onPressed: () {
            // TODO: 헬프버튼
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
          Widget nextLevel = ElevatedButton(
            onPressed: onContinue,
            child: const Text('다음단계로'),
          );
          Widget prevLevel = ElevatedButton(
            onPressed: onCancel,
            child: const Text('이전단계로'),
          );
          switch (details.stepIndex) {
            case 0:
              nextLevel = ElevatedButton(
                onPressed: copyBside,
                child: const Text('링크복사'),
              );
              prevLevel = Container();
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
                onPressed: onFinish,
                child: const Text('가져오기 완료'),
              );
              break;
          }
          return Row(
            children: <Widget>[
              const SizedBox(width: 20),
              nextLevel,
              const SizedBox(width: 10),
              prevLevel,
            ],
          );
        }),
        steps: steps,
      ),
    );
  }

  void copyBside() {
    String text = 'https://relay.coocon.net/beside/#none';
    Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );
    print('클립보드에 복사되었습니다. $text');
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
    String? pin = await _mtsController.loadTwelveDigits();
    if (pin != null) {
      setState(() {
        num0 = pin.substring(0, 4);
        num1 = pin.substring(4, 8);
        num2 = pin.substring(8, 12);
        print('$num0 - $num1 - $num2');
      });
      onContinue();
    } else {
      print('12자리 숫자를 불러오는데 실패했어요.');
    }
  }

  void onFinish() {
    Get.bottomSheet(
      confirmBody(
        'PC 웹사이트에서 인증번호를 입력하세요.',
        '입력 후 확인',
        () async {
          bool ok = await _mtsController.checkIfImported();
          if (ok) {
            goMTSLoginCert();
          } else {
            goBack();
          }
        },
      ),
      backgroundColor: Colors.white,
    );
  }
}

class PurpleInputBox extends StatelessWidget {
  const PurpleInputBox({
    super.key,
    required this.value,
  });

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Colors.deepPurple,
          ),
          borderRadius: const BorderRadius.all(
            Radius.circular(
              5,
            ),
          ),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 5,
        ),
        padding: const EdgeInsets.all(10),
        child: Text(value));
  }
}
