import 'dart:typed_data' show Uint8List;
import 'package:flutter/material.dart';

import '../auth/auth.data.dart';
import '../auth/auth.controller.dart';
import '../vote/vote.controller.dart';
import '../shared/custom_lottie.dart';
import '../signature/common_app_body.dart';
import 'package:get/get.dart' show Get, GetNavigation, Inst;
import 'signature.upload.dart' show CustomSignatureController;
import 'package:signature/signature.dart' show Signature, SignatureController;

class SignaturePage extends StatefulWidget {
  const SignaturePage({Key? key}) : super(key: key);

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final CustomSignatureController custSignCtrl =
      Get.isRegistered<CustomSignatureController>()
          ? Get.find()
          : Get.put(CustomSignatureController());
  final AuthController authCtrl = Get.find();
  final VoteController voteCtrl = Get.find();

  late String username = "";

  @override
  void initState() {
    if (authCtrl.isLogined) {
      User? user = authCtrl.user;
      if (user != null) {
        username = user.username;
      }
    }
    authCtrl.addListener(() {
      _hideLottie();
    });
    super.initState();
  }

  final SignatureController _signCtrl = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

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

  static const informationString = '''전자서명을 저장하고 다음에 간편하게 불러올 수 있어요.
모든 개인정보는 안전하게 보관되며 지정된 용도 이외에 절대 사용되지 않습니다.''';

  void onSubmit() async {
    if (_signCtrl.isNotEmpty) {
      final Uint8List? result = await _signCtrl.toPngBytes();
      final url = await custSignCtrl.uploadSignature(
        VoteController.to.campaign.companyName,
        '${DateTime.now()}-$username.png',
        result!,
        "signature",
      );
      voteCtrl.putSignatureUrl(url);
      Get.toNamed('/idcard');
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleString = '전자위임';
    const helpText = '전자 서명을 등록해주세요.';
    var mainContent = Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      foregroundDecoration: BoxDecoration(
        border: Border.all(
          color: Colors.deepOrange,
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadiusDirectional.circular(30),
      ),
      child: SizedBox(
        child: (_showLottie
            ? GestureDetector(
                onTap: _hideLottie,
                child: lottieIDCard,
              )
            : Signature(
                controller: _signCtrl,
                backgroundColor: Colors.white,
                height: 300,
                width: Get.width,
              )),
      ),
    );
    var subContentList = Column(
      children: [
        OutlinedButton(
          onPressed: () async {
            _signCtrl.clear();
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
            '초기화',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        const SizedBox(height: 30),
        // Row(
        //   children: [
        //     Checkbox(
        //       value: _isAgreed,
        //       onChanged: (v) {
        //         _setAgreed();
        //       },
        //     ),
        //     const Text('전자서명 저장에 동의합니다.'),
        //   ],
        // ),
        // Row(
        //   children: [
        //     Checkbox(
        //       value: _isManaged,
        //       onChanged: (v) {
        //         _setManaged();
        //       },
        //     ),
        //     const Text('티엘아이 측에 대한 기존 위임을 철회합니다.'),
        //   ],
        // ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: Size(Get.width - 30, 50),
            primary: const Color(0xFF572E67),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () async {
            onSubmit();
          },
          child: const Text(
            '등록',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        )
      ],
    );
    return AppBodyPage(
      titleString: titleString,
      helpText: helpText,
      informationString: informationString,
      mainContent: mainContent,
      subContentList: subContentList,
    );
  }
}
