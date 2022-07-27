import 'package:bside/shared/shared.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

class MtsPage extends StatelessWidget {
  const MtsPage({Key? key}) : super(key: key);

  onPressed() {
    goToMtsLink();
  }

  Widget securitiesFirmCard() {
  return InkWell(
    onTap: onPressed,
    child: Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(15.0)
        ), 
        color: customColor[ColorType.lightGrey]!,
      ),
        //  POINT: BoxDecoration
      child: Column(children: [
        
        CustomText(text: '대신증권',)
      ],)
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(text: '증권사'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: '증권사 선택', typoType: TypoType.h1Title,),
            CustomText(text: '연동할 증권사를 선택해주세요.', typoType: TypoType.body,),
            CustomText(text: '현재 모든 증권사를 지원하고 있지 않습니다.'),
            securitiesFirmCard()
          ],
        ));
  }
}
