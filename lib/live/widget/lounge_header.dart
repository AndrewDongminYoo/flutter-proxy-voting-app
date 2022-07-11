// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../shared/custom_text.dart';

class LiveLoungeHeader extends Column {
  LiveLoungeHeader({Key? key})
      : super(
          key: key,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: '22년 에스엠 주주총회',
              typoType: TypoType.body,
            ),
            const SizedBox(
              height: 10,
            ),
            CustomText(
              text: '일시 : 3월 31일 (목) 오전 9시',
              typoType: TypoType.body,
            ),
            const SizedBox(
              height: 5,
            ),
            CustomText(
              text: '장소 : 성동구 왕십리로 83-21 에스엠 본사 2층',
              typoType: TypoType.body,
            ),
          ],
        );
}
