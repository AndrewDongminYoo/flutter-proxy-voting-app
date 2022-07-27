// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:bside/lib.dart';
import 'mts.dart';

class MtsLinkPage extends StatefulWidget {
  const MtsLinkPage({Key? key}) : super(key: key);

  @override
  State<MtsLinkPage> createState() => _MtsLinkPageState();
}

class _MtsLinkPageState extends State<MtsLinkPage> {
  final MtsController _mtsController = MtsController.get();
  final String _module = 'secDaishin';

  onPressedCertification() {
    _mtsController.setSecuritiesModule(_module);
    goToMtsCertification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: '연동 방법'),
      body: Column(
        children: [
          CustomText(text: '연동 방법 선택'),
          CustomText(text: '증권사 연동을 통해 주주인증이 가능합니다.'),
          CustomButton(label: '증권사 ID로 연동하기', onPressed: onPressedCertification)
        ],
      ),
    );
  }
}
