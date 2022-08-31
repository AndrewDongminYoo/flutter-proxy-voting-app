// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'mts.dart';
import '../shared/shared.dart';
import '../theme.dart';

class MtsFirmChoicePage extends StatefulWidget {
  const MtsFirmChoicePage({Key? key}) : super(key: key);
  @override
  State<MtsFirmChoicePage> createState() => _MtsFirmChoicePageState();
}

class _MtsFirmChoicePageState extends State<MtsFirmChoicePage> {
  final MtsController _controller = MtsController.get();

  _onPressed(CustomModule firm) {
    print(firm.firmName);
    _controller.setMTSFirm(firm);
    goToMtsLoginChoice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(text: '증권사'),
        body: Container(
            padding: const EdgeInsets.all(18),
            height: Get.height,
            width: Get.width,
            child: Column(children: [
              CustomText(
                text: '증권사 선택',
                typoType: TypoType.h1Title,
              ),
              CustomText(
                text: '연동할 증권사를 선택해주세요.',
                typoType: TypoType.body,
              ),
              CustomText(text: '더 많은 증권사와 연동하기 위해 준비 중입니다.'),
              Expanded(
                  // TODO: 각 증권사 버튼을 컴포넌트화 하여 동시에 중복선택 가능하도록 변경
                  // XD: https://xd.adobe.com/view/0acd4a8f-95ec-4996-8fd4-bd79f63790cb-5f9e/screen/4f90408e-7a85-4d8b-9775-7d4123f725c9
                  child: GridView.builder(
                      primary: false,
                      itemCount: stockTradingFirms.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (_, int index) {
                        CustomModule firm = stockTradingFirms[index];
                        return InkWell(
                            onTap: () => _onPressed(firm),
                            child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  color: customColor[ColorType.lightGrey]!,
                                ),
                                //  POINT: BoxDecoration
                                child: Column(children: [
                                  Text(
                                    firm.korName,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 8),
                                  CircleAvatar(
                                      radius: 20,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.asset(firm.logoImage),
                                      ))
                                ])));
                      }))
            ])));
  }
}
