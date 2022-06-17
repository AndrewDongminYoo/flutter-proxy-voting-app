import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadIdCard extends StatefulWidget {
  const UploadIdCard({Key? key}) : super(key: key);

  @override
  State<UploadIdCard> createState() => _UploadIdCardState();
}

class _UploadIdCardState extends State<UploadIdCard> {
  Uint8List? _image;
  bool idCardUploaded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(IconData(0xf05bc, fontFamily: 'MaterialIcons')),
          onPressed: () => Get.back(),
        ),
        title: const Text('전자서명'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_rounded),
            onPressed: () {},
          ),
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
                  onPressed: () {},
                  style: OutlinedButtonTheme.of(context).style,
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
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.deepOrange,
                  width: 3,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadiusDirectional.circular(30),
              ),
              child: SizedBox(
                width: Get.width - 15,
                height: 300,
                child: (idCardUploaded
                    ? Image.memory(
                        _image!,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                      )
                    : IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.upload_file_rounded,
                          size: 50,
                          color: Colors.deepOrange,
                        ),
                      )),
              ),
            ),
            const Spacer(),
            Row(
              children: const [
                Text(
                  '주민등록 번호 먼저 입력하기',
                ),
                Icon(Icons.arrow_circle_right_outlined)
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(Get.width - 30, 50),
                // primary: const Color(0xFF572E67),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {},
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
