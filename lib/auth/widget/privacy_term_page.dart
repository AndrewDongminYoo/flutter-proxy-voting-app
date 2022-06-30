// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../shared/custom_appbar.dart';
import '../../shared/custom_text.dart';
import 'service_term.data.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({Key? key}) : super(key: key);

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
        CustomText(text: Privacy0.headText, typoType: TypoType.body),
        CustomText(text: Privacy0.mainContent1, typoType: TypoType.body),
        CustomText(text: Privacy0.mainContent2, typoType: TypoType.body),
      ],
    )));
  }
}
