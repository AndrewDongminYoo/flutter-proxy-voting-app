// π¦ Flutter imports:
import 'package:flutter/material.dart';

// π¦ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// π Project imports:
import 'mts.dart';
import '../shared/shared.dart';

class MTSFirmChoicePage extends StatefulWidget {
  const MTSFirmChoicePage({Key? key}) : super(key: key);
  @override
  State<MTSFirmChoicePage> createState() => _MTSFirmChoicePageState();
}

class _MTSFirmChoicePageState extends State<MTSFirmChoicePage> {
  final MtsController _controller = MtsController.get();
  List<CustomModule> firms = [];

  @override
  void initState() {
    super.initState();
    firms = _controller.firms;
  }

  void _onTap(CustomModule firm) {
    print(firm.firmName);
    setState(() {
      firms.add(firm);
    });
    _controller.addMTSFirm(firm);
  }

  void _offTap(CustomModule firm) {
    print(firm.firmName);
    setState(() {
      firms.remove(firm);
    });
    _controller.delMTSFirm(firm);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(text: 'μ¦κΆμ¬'),
      body: Container(
          padding: const EdgeInsets.all(18),
          height: Get.height,
          width: Get.width,
          child: Column(children: [
            CustomText(
              text: 'μ¦κΆμ¬ μ ν',
              typoType: TypoType.h1Title,
            ),
            CustomText(
              text: 'μ°λν  μ¦κΆμ¬λ₯Ό μ νν΄μ£ΌμΈμ.',
            ),
            CustomText(
              text: 'λ λ§μ μ¦κΆμ¬μ μ°λνκΈ° μν΄ μ€λΉ μ€μλλ€.',
            ),
            Expanded(
                child: GridView.builder(
                    primary: false,
                    itemCount: stockTradingFirms.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (_, int index) {
                      CustomModule firm = stockTradingFirms[index];
                      bool contains = firms.contains(firm);
                      return InkWell(
                          onTap: () => contains ? _offTap(firm) : _onTap(firm),
                          child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0)),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: contains
                                        ? Colors.deepPurple
                                        : Colors.transparent,
                                    width: 4,
                                  ),
                                  boxShadow: kElevationToShadow[2]),
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
          ])),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          goMTSLoginChoice();
        },
        shape: const CircleBorder(),
        elevation: 10,
        tooltip: 'μ ν μλ£',
        child: const Icon(Icons.done_all),
      ),
    );
  }
}
