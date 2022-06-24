import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/auth.controller.dart';
import '../campaign/campaign.controller.dart';
import 'common_app_body.dart';
import 'signature.upload.dart';

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
  final AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  final CampaignController cmpCtrl = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());

  void onSubmit() async {
    final XFile? xfile = await picker.pickImage(
      source: ImageSource.camera,
    );
    if (xfile != null) {
      idcardImage = await File(xfile.path).readAsBytes();
      if (idcardImage != null) {
        await _controller.uploadSignature(
          cmpCtrl.campaign.companyName,
          '${authCtrl.user?.username}${xfile.name}',
          idcardImage!,
          "idcard",
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
    const titleString = '전자서명';
    const helpText = '신분증을 촬영해주세요';
    const informationString = '''
신분증 사본은 위임장 본인확인 증빙 자료로 활용됩니다. 
촬영 시 주민등록번호의 뒷자리를 가려주세요. 
신분증 원본의 민감한 개인정보는 보안 기술에 의해 자동으로 보이지 않게 삭제됩니다.''';
    Widget mainContent = Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      foregroundDecoration: BoxDecoration(
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
    );

    Widget subContentList = Column(
      children: [
        // Row(
        //   children: [
        //     const SizedBox(width: 16),
        //     const Text('주민등록 번호 먼저 입력하기'),
        //     IconButton(
        //       tooltip: '주민등록번호 뒷자리를 입력해요.',
        //       icon: const Icon(
        //         Icons.arrow_circle_right_outlined,
        //       ),
        //       onPressed: () {
        //         if (idCardUploaded) {
        //           Get.toNamed("/idnumber");
        //         }
        //         // 주민등록번호 먼저 입력하는 페이지로 이동
        //       },
        //     )
        //   ],
        // ),
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
              // authCtrl.user.URL = _controller.downloadSignature();
              Get.toNamed('/idnumber');
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
    );
    return AppBodyPage(
      titleString: titleString,
      helpText: helpText,
      informationString: informationString,
      mainContent: mainContent,
      subContentList: subContentList,
    );
  }
}
