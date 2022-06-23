import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bside/signature/signature.upload.dart';

import '../shared/back_button.dart';
import '../shared/notice_button.dart';

class UploadIdCardPage extends StatefulWidget {
  const UploadIdCardPage({Key? key}) : super(key: key);

  @override
  State<UploadIdCardPage> createState() => _UploadIdCardPageState();
}

class _UploadIdCardPageState extends State<UploadIdCardPage> {
  Uint8List? idcardImage;
  bool idCardUploaded = false;
  final ImagePicker picker = ImagePicker();

  final CustomSignatureController _controller =
      Get.isRegistered<CustomSignatureController>()
          ? Get.find()
          : Get.put(CustomSignatureController());

  void onSubmit() async {
    final XFile? xfile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (xfile != null) {
      idcardImage = await File(xfile.path).readAsBytes();
      if (idcardImage != null) {
        await _controller.uploadSignature(
          "company_name",
          xfile.name,
          idcardImage!,
        );
        setState(() {
          idCardUploaded = true;
        });
      }
    }
  }

  Widget uploadImageButton() {
    return IconButton(
      onPressed: onSubmit,
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('촬영 및 업로드하기'),
          SizedBox(
            height: 10,
          ),
          Icon(
            Icons.upload_file_rounded,
            size: 50,
            color: Colors.deepOrange,
            semanticLabel: '촬영 및 업로드',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: const Text('신분증 업로드'),
        backgroundColor: const Color(0xFF572E67),
        actions: const [
          NoticeButton(),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(15),
        alignment: Alignment.topLeft,
        child: Column(
          children: [
            Row(
              children: [
                const Text('신분증 사본을 업로드해주세요.',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    )),
                const Spacer(),
                OutlinedButton(
                  onPressed: () {
                    // TODO: 문의하기 페이지 구현
                  },
                  style: OutlinedButton.styleFrom(
                    primary: const Color(0xFF572E67),
                  ),
                  child: const Text('문의하기'),
                ),
              ],
            ),
            const Text('''
신분증 사본은 위임장 본인확인 증빙 자료로 활용됩니다. 
촬영 시 주민등록번호의 뒷자리를 가려주세요. 
신분증 원본의 민감한 개인정보는 보안 기술에 의해 자동으로 보이지 않게 삭제됩니다.
            '''),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.deepOrange,
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadiusDirectional.circular(30),
              ),
              child: SizedBox(
                width: Get.width,
                height: 300,
                child: (idCardUploaded
                    ? GestureDetector(
                        onLongPress: onSubmit,
                        child: Image.memory(
                          idcardImage!,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      )
                    : uploadImageButton()),
              ),
            ),
            const Spacer(),
            Row(
              children: [
                const Text(
                  '주민등록 번호 먼저 입력하기',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.arrow_circle_right_outlined,
                  ),
                  onPressed: () {
                    if (idCardUploaded) {}
                    // 주민등록번호 먼저 입력하는 페이지로 이동
                  },
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(Get.width - 30, 50),
                primary: const Color(0xFF572E67),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                if (idCardUploaded) {
                  // TODO: 저장된 이미지 리턴받아 등록하고 다음 페이지로 이동
                  Get.toNamed('done');
                }
              },
              child: const Text(
                '등록',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
