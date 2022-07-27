import 'package:bside/MTS/mts.controller.dart';
import 'package:bside/shared/shared.dart';
import 'package:flutter/material.dart';


import 'widgets/certificationForm.dart';

class SecuritiesPage extends StatefulWidget {
  const SecuritiesPage({Key? key}) : super(key: key);

  @override
  State<SecuritiesPage> createState() =>
      _SecuritiesPageState();
}

class _SecuritiesPageState extends State<SecuritiesPage> {
  final MtsController _mtsController = MtsController.get();

  final String _securitiesId = '';
  final int _securitiesPassword = 0;

  onPressed() {
    _mtsController.setMts(_securitiesId, _securitiesPassword);
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
            const CertificaitionIdForm(),
            const CertificaitionPasswordForm(),
            CustomButton(label: '확인', onPressed: onPressed)
          ],
        ));
  }
}
