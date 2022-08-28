// 🐦 Flutter imports:
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show ExtensionDialog, Get, GetNavigation;

// 🌎 Project imports:
import '../../auth/auth.controller.dart';
import '../../shared/shared.dart';
import '../../theme.dart';
import '../../vote/vote.controller.dart';
import 'edit_modal.dart';

class AddressCard extends StatefulWidget {
  const AddressCard({Key? key}) : super(key: key);

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  AuthController authCtrl = AuthController.get();
  VoteController voteCtrl = VoteController.get();
  String address = '';

  onEdit() async {
    String? add = await Get.dialog(
      const EditModal(),
      arguments: address,
    );
    setState(() {
      if (add != null) address = add;
    });
  }

  @override
  void initState() {
    if (authCtrl.user.address.isNotEmpty) {
      print('load address from userCtrlr');
      address = authCtrl.user.address;
    } else if (voteCtrl.shareholder.address.isNotEmpty) {
      print('load address from shareholder');
      address = voteCtrl.shareholder.address;
    }
    super.initState();
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
                CustomText(
                  typoType: TypoType.body,
                  text: '주소',
                  textAlign: TextAlign.left,
                  colorType: ColorType.white,
                ),
                const Spacer(),
                InkWell(
                  onTap: onEdit,
                  child: CustomText(
                    typoType: TypoType.bodyLight,
                    text: '수정하기',
                    textAlign: TextAlign.left,
                    colorType: ColorType.white,
                  ),
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
              text: address,
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
