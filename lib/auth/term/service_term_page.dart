import 'package:flutter/material.dart';

import 'service_term.data.dart';
import '../../shared/custom_appbar.dart';
import '../../shared/custom_text.dart';

class ServicePage extends StatelessWidget {
  const ServicePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '회원가입'),
        body: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: const [
        CustomText(text: '', typoType: TypoType.body),
        CustomText(text: Service0.headText, typoType: TypoType.body),
        CustomText(text: Service0.mainContent, typoType: TypoType.body),
      ],
    )));
  }
}
