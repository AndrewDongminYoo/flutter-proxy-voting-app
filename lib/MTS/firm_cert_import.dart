// π¦ Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// π¦ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// π Project imports:
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

  dynamic checkCertList() async {
    Set<RKSWCertItem>? response = await _mtsController.loadCertList();
    if (response != null && response.isNotEmpty) {
      goMTSLoginCert();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<EnhanceStep> steps = [
      EnhanceStep(
        icon: EnhanceIcon(icon: Icons.link),
        title: const Text('νλ¬ν° μν ννμ΄μ§μ μ μνμΈμ.'),
        content: const Text(''),
      ),
      EnhanceStep(
        icon: EnhanceIcon(icon: Icons.import_export),
        title: const Text('μΈμ¦μ λ³΅μ¬νκΈ° μ νν΄μ£ΌμΈμ.'),
        content: Image.asset('assets/images/screenshot_example1.png'),
      ),
      EnhanceStep(
        icon: EnhanceIcon(icon: Icons.password),
        title: const Text('μΈμ¦μ μ ν ν λΉλ°λ²νΈ μλ ₯ ν΄μ£ΌμΈμ.'),
        content: Image.asset('assets/images/screenshot_example2.png'),
      ),
      EnhanceStep(
          icon: EnhanceIcon(icon: Icons.verified),
          title: const Text('μλ μΈμ¦λ²νΈ 12μλ¦¬λ₯Ό μλ ₯ν΄ μ£ΌμΈμ.'),
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
            // TODO: ν¬νλ²νΌ
          },
        ),
      ),
      body: EnhanceStepper(
        stepIconSize: 45,
        currentStep: _index,
        onStepContinue: onContinue,
        onStepCancel: onCancel,
        onStepTapped: (int i) => onTapped(i),
        physics: const ClampingScrollPhysics(),
        controlsBuilder: ((BuildContext context, ControlsDetails details) {
          Widget nextLevel = ElevatedButton(
            onPressed: onContinue,
            child: const Text('λ€μλ¨κ³λ‘'),
          );
          Widget prevLevel = ElevatedButton(
            onPressed: onCancel,
            child: const Text('μ΄μ λ¨κ³λ‘'),
          );
          switch (details.stepIndex) {
            case 0:
              nextLevel = ElevatedButton(
                onPressed: copyLink,
                child: const Text('λ§ν¬λ³΅μ¬'),
              );
              prevLevel = Container();
              break;
            case 1:
              break;
            case 2:
              nextLevel = ElevatedButton(
                onPressed: onPressed,
                child: const Text('μΈμ¦λ²νΈμμ±'),
              );
              break;
            case 3:
              nextLevel = TextButton(
                onPressed: onFinish,
                child: const Text('κ°μ Έμ€κΈ° μλ£'),
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

  void copyLink() {
    String text = 'https://relay.coocon.net/beside/#none';
    Clipboard.setData(
      ClipboardData(
        text: text,
      ),
    );
    print('ν΄λ¦½λ³΄λμ λ³΅μ¬λμμ΅λλ€. $text');
    onContinue();
  }

  void onTapped(int index) {
    print('selected index: $index');
  }

  void onCancel() {
    setState(() {
      if (_index > 0) {
        _index--;
      }
    });
  }

  void onContinue() {
    setState(() {
      if (_index < 3) {
        _index++;
      }
    });
  }

  void onPressed() async {
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
      print('12μλ¦¬ μ«μλ₯Ό λΆλ¬μ€λλ° μ€ν¨νμ΄μ.');
    }
  }

  void onFinish() {
    Get.bottomSheet(
      confirmBody(
        'PC μΉμ¬μ΄νΈμμ μΈμ¦λ²νΈλ₯Ό μλ ₯νμΈμ.',
        'μλ ₯ ν νμΈ',
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
