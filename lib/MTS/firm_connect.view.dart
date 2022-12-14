// π¦ Flutter imports:
import 'package:flutter/material.dart';

// π¦ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// π Project imports:
import '../shared/shared.dart';

class MTSLoginChoicePage extends StatefulWidget {
  const MTSLoginChoicePage({super.key});

  @override
  State<MTSLoginChoicePage> createState() => _MTSLoginChoicePageState();
}

class _MTSLoginChoicePageState extends State<MTSLoginChoicePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          text: 'μ°λνκΈ°',
          helpButton: IconButton(
            icon: const Icon(
              Icons.help_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              // TODO: ν¬νλ²νΌ
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            CustomText(
              text: 'μ°λ λ°©λ² μ ν',
              typoType: TypoType.h1Title,
              textAlign: TextAlign.start,
              isFullWidth: true,
            ),
            CustomText(
              text:
                  'μνμλ μ°λλ°©λ²μ μ νν΄μ£ΌμΈμ.\nμΌλΆ μ¦κΆμ¬μ κ²½μ° κ³΅λμΈμ¦μμ μ¦κΆμ¬ IDλ₯Ό\nλͺ¨λ μκ΅¬ν  μλ μμ΅λλ€.',
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
                        goMTSLoginId();
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
                              semanticLabel: 'μ¦κΆμ¬κ³μ ',
                            ),
                            const SizedBox(height: 10),
                            CustomText(
                              text: 'μ¦κΆμ¬κ³μ ',
                            )
                          ],
                        ),
                      )),
                  const SizedBox(width: 5),
                  GestureDetector(
                      onTap: () {
                        goMTSLoginCert();
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
                              semanticLabel: 'κ³΅λμΈμ¦μ',
                            ),
                            const SizedBox(height: 10),
                            CustomText(
                              text: 'κ³΅λμΈμ¦μ',
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
