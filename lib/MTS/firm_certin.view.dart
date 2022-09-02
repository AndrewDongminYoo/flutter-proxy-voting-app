// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';
import 'mts.dart';
import '../shared/shared.dart';

class MTSLoginCERTPage extends StatefulWidget {
  const MTSLoginCERTPage({Key? key}) : super(key: key);

  @override
  State<MTSLoginCERTPage> createState() => _MTSLoginCERTPageState();
}

class _MTSLoginCERTPageState extends State<MTSLoginCERTPage> {
  final MtsController _mtsController = MtsController.get();

  List<RKSWCertItem> certificationList = [];

  @override
  void initState() {
    super.initState();
    loadCertList();
  }

  loadCertList() async {
    List<RKSWCertItem>? response = await _mtsController.loadCertList();
    setState(() {
      if (response != null) {
        for (RKSWCertItem element in response) {
          certificationList.add(element);
        }
      }
      print(certificationList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(
          text: '연동하기',
          bgColor: Colors.transparent,
          helpButton: IconButton(
            icon: Icon(
              Icons.help,
              color: customColor[ColorType.deepPurple],
            ),
            onPressed: () {
              // TODO: 뭐 넣지..
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: loginWithCertification(),
        ));
  }

  Column loginWithCertification() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomText(
        text: '공동인증서 선택',
        typoType: TypoType.h1Title,
        textAlign: TextAlign.start,
        isFullWidth: true,
      ),
      CustomText(
        text:
            '증권사 연동을 위해 공동인증서를 선택해주세요.\n일부 증권사의 경우 공동인증서와 증권사 ID를\n모두 요구할 수도 있습니다.',
        typoType: TypoType.body,
        textAlign: TextAlign.start,
        isFullWidth: true,
      ),
      Container(
        width: Get.width,
        height: Get.width,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: certificationList
              .map(
                (e) => CertificationCard(item: e),
              )
              .toList(),
        ),
      ),
    ]);
  }
}
