import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import '../shared/shared.dart';

class MTSChooseLoginMenu extends StatefulWidget {
  const MTSChooseLoginMenu({super.key});

  @override
  State<MTSChooseLoginMenu> createState() => _MTSChooseLoginMenuState();
}

class _MTSChooseLoginMenuState extends State<MTSChooseLoginMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          text: '연동하기',
          helpButton: IconButton(
            icon: const Icon(
              Icons.help_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: 뭐 넣지..
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            CustomText(
              text: '연동 방법 선택',
              typoType: TypoType.h1Title,
              textAlign: TextAlign.start,
              isFullWidth: true,
            ),
            CustomText(
              text:
                  '원하시는 연동방법을 선택해주세요.\n일부 증권사의 경우 공동인증서와 증권사 ID를\n모두 요구할 수도 있습니다.',
              typoType: TypoType.body,
              textAlign: TextAlign.start,
              isFullWidth: true,
            ),
            Container(
              width: Get.width,
              height: Get.width,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        goToMtsLoginWithID();
                      },
                      child: Container(
                        width: Get.width * 0.4,
                        height: Get.width * 0.4,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(18),
                          ),
                          color: Colors.white,
                          boxShadow: kElevationToShadow[3],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.account_circle_outlined,
                              size: 55,
                              semanticLabel: '증권사계정',
                            ),
                            const SizedBox(height: 10),
                            CustomText(
                              text: '증권사계정',
                            )
                          ],
                        ),
                      )),
                  const SizedBox(width: 5),
                  GestureDetector(
                      onTap: () {
                        goToMtsLoginWithCert();
                      },
                      child: Container(
                        width: Get.width * 0.4,
                        height: Get.width * 0.4,
                        margin: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(18),
                          ),
                          color: Colors.white,
                          boxShadow: kElevationToShadow[3],
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.fingerprint_outlined,
                              size: 55,
                              semanticLabel: '공동인증서',
                            ),
                            const SizedBox(height: 10),
                            CustomText(
                              text: '공동인증서',
                            )
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ]),
        ));
  }
}
