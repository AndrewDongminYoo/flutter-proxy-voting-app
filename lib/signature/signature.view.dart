// 🎯 Dart imports:
import 'dart:typed_data' show Uint8List;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:signature/signature.dart' show Signature, SignatureController;
import 'package:timeago/timeago.dart' as timeago;
import 'package:lottie/lottie.dart' show Lottie, LottieBuilder;

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../shared/shared.dart';
import '../vote/vote.controller.dart';
import 'signature.dart';

class VoteSignPage extends StatefulWidget {
  const VoteSignPage({Key? key}) : super(key: key);

  @override
  State<VoteSignPage> createState() => _VoteSignPageState();
}

class _VoteSignPageState extends State<VoteSignPage> {
  final SignController _signCtrl = SignController.get();
  final AuthController _authCtrl = AuthController.get();
  final VoteController _voteCtrl = VoteController.get();

  bool _showLottie = true;
  late String _username = '';
  DateTime? _signatureAt;
  String _informationString = '';

  void _hideLottie() {
    if (mounted) {
      setState(() {
        _showLottie = false;
      });
    }
  }

  final LottieBuilder lottieIDCard = Lottie.network(
    'https://assets9.lottiefiles.com/packages/lf20_vaqzminx.json',
    width: Get.width,
    height: 300,
  );

  @override
  void initState() {
    _username = _authCtrl.user.username;
    _signatureAt = _voteCtrl.voteAgenda.signatureAt;

    super.initState();
  }

  final SignatureController _signer = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );

  void _onSubmit() async {
    if (_signer.isNotEmpty) {
      final Uint8List? signature = await _signer.toPngBytes();
      final String url = await _signCtrl.uploadSignature(
        _voteCtrl.campaign.enName,
        '$_username-${DateTime.now()}.png',
        signature!,
        'signature',
      );
      _voteCtrl.putSignatureUrl(url);
    } else if (_voteCtrl.voteAgenda.idCardAt != null) {
      await jumpToVoteResult();
    }
    goUploadIdCard();
  }

  @override
  Widget build(BuildContext context) {
    const String titleString = '전자위임';
    const String helpText = '전자 서명을 등록해주세요.';
    print('signatureAt: $_signatureAt');
    _informationString = _signatureAt != null
        ? '${timeago.format(_signatureAt!, locale: 'ko')}에 이미 서명하셨습니다. 다시 서명하려면 가운데를 클릭하세요.'
        : '''
전자서명을 저장하고 다음에 간편하게 불러올 수 있어요.
모든 개인정보는 안전하게 보관되며 지정된 용도 이외에 절대 사용되지 않습니다.''';
    Container mainContent = Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
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
                controller: _signer,
                backgroundColor: Colors.white,
                height: 300,
                width: Get.width,
              )),
      ),
    );
    Column subContentList = Column(
      children: [
        OutlinedButton(
          onPressed: () async {
            _signer.clear();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.deepOrange,
            fixedSize: Size(Get.width - 30, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            side: const BorderSide(
              color: Colors.deepOrange,
              width: 2,
            ),
          ),
          child: CustomText(
            text: '초기화',
            typoType: TypoType.h2Bold,
          ),
        ),
        const SizedBox(height: 30),
        CustomButton(
          label: '등록',
          onPressed: _onSubmit,
        ),
      ],
    );
    return AppBodyPage(
      titleString: titleString,
      helpText: helpText,
      informationString: _informationString,
      mainContent: mainContent,
      subContentList: subContentList,
    );
  }
}
