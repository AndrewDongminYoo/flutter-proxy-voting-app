import 'dart:typed_data' show Uint8List;
import 'package:bside/auth/auth.controller.dart';

import 'signature.upload.dart' show CustomSignatureController;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart' show Lottie, LottieBuilder;
import 'package:signature/signature.dart' show Signature, SignatureController;
import 'package:get/get.dart' show Get, GetNavigation, Inst;

class SignaturePage extends StatefulWidget {
  const SignaturePage({Key? key}) : super(key: key);

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final CustomSignatureController _customController =
      Get.isRegistered<CustomSignatureController>()
          ? Get.find()
          : Get.put(CustomSignatureController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _hideLottie();
    });
  }

  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.deepPurpleAccent.shade100,
  );

  final LottieBuilder _lottie = Lottie.network(
    'https://assets9.lottiefiles.com/packages/lf20_vaqzminx.json',
    width: Get.width,
    height: 300,
  );

  void _goBack() => Get.back();

  bool _showLottie = true;
  bool _isAgreed = false;
  bool _isManaged = false;

  void _hideLottie() {
    setState(() {
      _showLottie = false;
    });
  }

  void _setAgreed() {
    setState(() {
      _isAgreed = !_isAgreed;
    });
  }

  void _setManaged() {
    setState(() {
      _isManaged = !_isManaged;
    });
  }

  Future<void> _showSignature(BuildContext context) async {
    if (_controller.isNotEmpty) {
      final Uint8List? result = await _controller.toPngBytes();
      if (result != null) {
        Get.to(Center(
          child: Image.memory(result),
        ));
      }
    }
  }

  static const signatureString = '''전자서명을 저장하고 다음에 간편하게 불러올 수 있어요.
모든 개인정보는 안전하게 보관되며 지정된 용도 이외에 절대 사용되지 않습니다.''';

  void onSubmit() async {
    if (_controller.isEmpty) {
      return;
    }
    final Uint8List? result = await _controller.toPngBytes();
    await _customController.uploadSignature(
      "company_name",
      "sign_username.png",
      result!,
    );
    Get.toNamed('/vote');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Signature',
      color: Colors.white,
      home: Scaffold(
        appBar: AppBar(
            leading: goBackButton(),
            title: const Text('전자서명'),
            backgroundColor: const Color(0xFF572E67),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded),
                onPressed: () {},
              )
            ]),
        body: SingleChildScrollView(
          child: Column(children: [
            Container(
              margin: const EdgeInsets.all(15),
              alignment: Alignment.topLeft,
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('전자 서명을 등록해주세요.',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          primary: const Color(0xFF572E67),
                        ),
                        child: const Text('문의하기'),
                      ),
                    ],
                  ),
                  const Text(signatureString)
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.deepOrange,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadiusDirectional.circular(30),
              ),
              child: _showLottie
                  ? GestureDetector(
                      onTap: _hideLottie,
                      child: _lottie,
                    )
                  : Signature(
                      controller: _controller,
                      backgroundColor: Colors.transparent,
                      width: Get.width,
                      height: 300,
                    ),
            ),
            const SizedBox(
              height: 10,
            ),
            OutlinedButton(
              onPressed: () async {
                _controller.clear();
                // String result =
                //     await _customController.getSignature("company", "filename");
                // print(result);
              },
              style: OutlinedButton.styleFrom(
                fixedSize: Size(Get.width - 30, 50),
                primary: Colors.deepOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: const BorderSide(
                  color: Colors.deepOrange,
                  width: 2,
                ),
              ),
              child: const Text(
                '서명 불러오기',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 50, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _isAgreed,
                        onChanged: (v) {
                          _setAgreed();
                        },
                      ),
                      const Text('전자서명 저장에 동의합니다.'),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _isManaged,
                        onChanged: (v) {
                          _setManaged();
                        },
                      ),
                      const Text('에스엠 측에 대한 기존 위임을 철회합니다.'),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(Get.width - 30, 50),
                primary: const Color(0xFF572E67),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () async {
                // temporary solution :: show result
                await _showSignature(context);
                // onSubmit();
              },
              child: const Text(
                '등록',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  IconButton goBackButton() {
    return IconButton(
      icon: const Icon(
        IconData(
          0xf05bc,
          fontFamily: 'MaterialIcons',
        ),
      ),
      onPressed: _goBack,
    );
  }
}
