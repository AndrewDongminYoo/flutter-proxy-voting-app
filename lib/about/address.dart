import 'package:flutter/material.dart';
import 'package:get/get.dart';

// import '../checkVoteNum/check.dart';
import '../shared/custom_color.dart';
import '../shared/custom_text.dart';

import 'package:get/route_manager.dart';

class Address extends StatelessWidget {
  const Address({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(
              flex: 2,
            ),
            Container(
              width: Get.width,
              height: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                color: Color(0xFFDC721E),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CustomText(
                            typoType: TypoType.body,
                            text: '주소',
                            textAlign: TextAlign.left,
                            colorType: ColorType.white,
                          ),
                          Spacer(),
                          CustomText(
                            typoType: TypoType.bodyLight,
                            text: '수정하기',
                            textAlign: TextAlign.left,
                            colorType: ColorType.white,
                          ),
                          Icon(
                            Icons.arrow_circle_right_outlined,
                          )
                        ],
                      ),
                      const Spacer(),
                      const CustomText(
                          typoType: TypoType.bodyLight,
                          text: '서울시 송파구 아무로 12-2길 32, 송파아크 로펠리스 타워 102동 707호',
                          textAlign: TextAlign.left,
                          colorType: ColorType.white),
                    ]),
              ),
            ),
            const Spacer(),
            Container(
              width: Get.width,
              height: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                color: Color(0xff582E66),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CustomText(
                        typoType: TypoType.body,
                        text: '보유 주소',
                        colorType: ColorType.white),
                    Spacer(),
                    CustomText(
                        typoType: TypoType.bodyLight,
                        text: '1000주',
                        colorType: ColorType.white)
                  ],
                ),
              ),
            ),
            const Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}
