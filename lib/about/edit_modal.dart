import 'package:bside/shared/custom_button.dart';
import 'package:bside/shared/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../auth/auth.controller.dart';

class EditModal extends StatelessWidget {
  EditModal({Key? key}) : super(key: key);
  onClose() {
    Get.back();
  }

  final AuthController _controller = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  onEdit(String address) {
    _controller.setAddress(address);
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    String address = _controller.user?.address != null
        ? _controller.user!.address
        : '주소가 없습니다.';

    return AlertDialog(
      contentPadding: const EdgeInsets.only(left: 25, right: 25),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomText(
            text: '주소를 입력해주세요!',
            typoType: TypoType.body,
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close,
                color: Colors.black, semanticLabel: 'Close modal'),
          )
        ],
      ),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20.0))),
      content: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: SizedBox(
              height: 150,
              child: Column(
                children: [
                  addressForm(context, address),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(label: '확인', onPressed: () => {onEdit(address)}),
                ],
              ))),
    );
  }
}

Widget addressForm(BuildContext context, String address) {
  return TextFormField(
    initialValue: address,
    autofocus: true,
    style: const TextStyle(
        letterSpacing: 2.0, fontSize: 14, fontWeight: FontWeight.bold),
    keyboardType: TextInputType.text,
    decoration:
        const InputDecoration(border: OutlineInputBorder(), labelText: '주소'),
    onChanged: (text) {},
  );
}
