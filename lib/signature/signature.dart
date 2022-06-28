import 'dart:async';
import 'package:flutter/material.dart';
import '../auth/auth.controller.dart';
import '../vote/vote.controller.dart';
import '../shared/custom_lottie.dart';
import '../signature/common_app_body.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get/get.dart' show Get, GetNavigation, Inst;
import 'signature.upload.dart' show CustomSignatureController;
import 'package:signature/signature.dart' show Signature, SignatureController;

class SignaturePage extends StatefulWidget {
  const SignaturePage({Key? key}) : super(key: key);

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final CustomSignatureController _controller =
      Get.isRegistered<CustomSignatureController>()
          ? Get.find()
          : Get.put(CustomSignatureController());
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  Timer? timer;
  bool _showLottie = true;
  late String username = '';
  DateTime? signatureAt;
  String informationString = '';

  void _hideLottie() {
    if (mounted) {
      setState(() {
        _showLottie = false;
      });
    }
  }

  @override
  void initState() {
    if (authCtrl.user != null) {
      username = authCtrl.user!.username;
    }
    if (voteCtrl.voteAgenda != null) {
      signatureAt = voteCtrl.voteAgenda?.signatureAt;
    }

    timer = Timer(const Duration(seconds: 2), () {
      _hideLottie();
    });
    print('Get.arguments: ${Get.arguments}');
    super.initState();
  }

  final SignatureController _signCtrl = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  void onSubmit() async {
    if (_signCtrl.isNotEmpty) {
      final signature = await _signCtrl.toPngBytes();
      final url = await _controller.uploadSignature(
        voteCtrl.campaign.companyName,
        '$username-${DateTime.now()}.png',
        signature!,
        'signature',
      );
      voteCtrl.putSignatureUrl(url);
      Get.toNamed('/idcard');
    } else if (signatureAt != null) {
      Get.toNamed('/idcard');
    }
  }

  @override
  Widget build(BuildContext context) {
    const titleString = '전자위임';
    const helpText = '전자 서명을 등록해주세요.';
    print('signatureAt: ${signatureAt}');
    informationString = signatureAt != null
        ? '${timeago.format(signatureAt!, locale: 'ko')}에 이미 서명하셨습니다. 다시 서명하려면 가운데를 클릭하세요.'
        : '''
전자서명을 저장하고 다음에 간편하게 불러올 수 있어요.
모든 개인정보는 안전하게 보관되며 지정된 용도 이외에 절대 사용되지 않습니다.''';
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
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: Size(Get.width - 30, 50),
            primary: const Color(0xFF572E67),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: () {
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
