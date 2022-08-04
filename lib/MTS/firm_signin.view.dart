// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:bside/MTS/mts.controller.dart';
import 'package:bside/shared/shared.dart';
import 'widgets/idpw_form.dart';

class SecuritiesPage extends StatefulWidget {
  const SecuritiesPage({Key? key}) : super(key: key);

  @override
  State<SecuritiesPage> createState() => _SecuritiesPageState();
}

class _SecuritiesPageState extends State<SecuritiesPage> {
  final MtsController _mtsController = MtsController.get();

  final String _securitiesID = '';
  final String _securitiesPW = '';

  onPressed() {
    _mtsController.setIDPW(_securitiesID, _securitiesPW);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          text: '연동하기',
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: '증권사 연동하기'),
            const TradingFirmIdForm(),
            const TradingFirmPasswordForm(),
            CustomButton(label: '확인', onPressed: onPressed)
          ],
        ));
  }
}
