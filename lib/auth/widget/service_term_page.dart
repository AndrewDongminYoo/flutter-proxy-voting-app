// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../shared/custom_appbar.dart';
import '../../shared/custom_text.dart';
import 'service_term.data.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(text: '회원가입'),
        body: SingleChildScrollView(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CustomText(text: '', typoType: TypoType.body),
            CustomText(text: Service0.headText, typoType: TypoType.body),
            CustomText(text: Service0.mainContent, typoType: TypoType.body),
          ],
        )));
  }
}
