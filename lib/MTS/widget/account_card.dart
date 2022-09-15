// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';

// 🌎 Project imports:
import '../../shared/shared.dart';
import '../mts.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({super.key, required this.account});
  final Account account;
  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  MtsController mtsController = MtsController.get();
  @override
  Widget build(BuildContext context) {
    Account account = widget.account;
    return GestureDetector(
      onTap: () => onTap(account),
      child: Container(
        width: Get.width - 20,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            boxShadow: kElevationToShadow[3],
            color: Colors.white,
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Image.asset(
                  account.module.logoImage,
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: account.module.korName,
                  typoType: TypoType.h2Bold,
                ),
                CustomText(
                    text: account.idOrCert, typoType: TypoType.bodySmaller),
                CustomText(
                    text: [
                  codeMap[account.productCode],
                  account.productName,
                  hypen(account.accountNum)
                ].join(' '))
              ],
            ),
            const Spacer(),
            Flex(
              direction: Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              children: const [
                Icon(Icons.more_vert),
                SizedBox(
                  height: 50,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onTap(Account account) {
    goMTSStockChoice(account);
  }
}

Map<String, String> codeMap = {
  '': '위탁',
  '01': '위탁',
  '02': '펀드',
  '05': 'CMA',
};
