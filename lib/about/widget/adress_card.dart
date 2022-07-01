// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../theme.dart';
import '../../auth/auth.controller.dart';
import '../../shared/custom_text.dart';
import 'edit_modal.dart';

class AdressCard extends StatefulWidget {
  const AdressCard({Key? key}) : super(key: key);

  @override
  State<AdressCard> createState() => _AdressCardState();
}

class _AdressCardState extends State<AdressCard> {
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  onEdit() async {
    await Get.dialog(const EditModal());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
        color: Color(0xFFDC721E),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 5, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CustomText(
                  typoType: TypoType.body,
                  text: '주소',
                  textAlign: TextAlign.left,
                  colorType: ColorType.white,
                ),
                const Spacer(),
                const CustomText(
                  typoType: TypoType.bodyLight,
                  text: '수정하기',
                  textAlign: TextAlign.left,
                  colorType: ColorType.white,
                ),
                IconButton(
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    CupertinoIcons.arrow_right_square,
                    color: customColor[ColorType.white],
                  ),
                  onPressed: onEdit,
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomText(
              typoType: TypoType.bodyLight,
              text: authCtrl.user.address,
              textAlign: TextAlign.left,
              colorType: ColorType.white,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}
