// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../../auth/auth.controller.dart';
import '../../shared/custom_button.dart';
import '../../shared/custom_text.dart';

class EditModal extends StatefulWidget {
  const EditModal({Key? key}) : super(key: key);

  @override
  State<EditModal> createState() => _EditModalState();
}

class _EditModalState extends State<EditModal> {
  String addressInModal = '';
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());

  onClose() {
    Get.back();
  }

  onSubmit() {
    Get.back();
    authCtrl.setAddress(addressInModal);
  }

  @override
  void initState() {
    addressInModal = authCtrl.user.address;
    super.initState();
  }

  Widget addressForm() {
    return TextFormField(
      minLines: 2,
      maxLines: 3,
      initialValue: addressInModal,
      autofocus: true,
      style: const TextStyle(
        letterSpacing: 2.0,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      keyboardType: TextInputType.text,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: '자택 주소',
      ),
      onChanged: (text) {
        addressInModal = text;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.only(
        left: 25,
        right: 25,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CustomText(
            text: '주소를 입력해주세요!',
            typoType: TypoType.body,
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(
              Icons.close,
              color: Colors.black,
              semanticLabel: 'Close modal',
            ),
          )
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20.0),
        ),
      ),
      content: Padding(
          padding: const EdgeInsets.only(top: 0),
          child: SizedBox(
              height: Get.height * 0.3,
              child: Column(
                children: [
                  addressForm(),
                  const SizedBox(
                    height: 10,
                  ),
                  CustomButton(
                    label: '확인',
                    onPressed: onSubmit,
                  ),
                  const SizedBox(
                    height: 10,
                  )
                ],
              ))),
    );
  }
}
