import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../auth/auth.data.dart';
import 'common_app_body.dart';
import 'signature.upload.dart';
import '../vote/vote.controller.dart';
import '../auth/auth.controller.dart';

class UploadIdCardPage extends StatefulWidget {
  const UploadIdCardPage({Key? key}) : super(key: key);

  @override
  State<UploadIdCardPage> createState() => _UploadIdCardPageState();
}

class _UploadIdCardPageState extends State<UploadIdCardPage> {
  Uint8List? idcardImage;
  bool idCardUploaded = false;
  String username = '';
  final ImagePicker picker = ImagePicker();

  final CustomSignatureController _controller =
      Get.isRegistered<CustomSignatureController>()
          ? Get.find()
          : Get.put(CustomSignatureController());
  final AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  final VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController(), permanent: true);
  ImageSource source = ImageSource.camera;

  void onPressed() async {
    if (authCtrl.isLogined) {
      User? user = authCtrl.user;
      if (user != null) {
        username = user.username;
      }
    }
    var result = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 10,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20.0,
          ),
          title: const Text(
            '신분증을 촬영해주세요.',
            style: TextStyle(fontSize: 16),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  source = ImageSource.camera;
                });
                Navigator.pop(context, source);
              },
              child: const Text('카메라 촬영',
                  style: TextStyle(
                    fontSize: 14,
                  )),
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  source = ImageSource.gallery;
                });
                Navigator.pop(context, source);
              },
              child: const Text('갤러리 선택',
                  style: TextStyle(
                    fontSize: 14,
                  )),
            ),
          ],
        );
      },
    );
    print(result);

    final XFile? xfile = await picker.pickImage(
      maxWidth: 1900,
      maxHeight: 600,
      source: source,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (xfile != null) {
      idcardImage = await File(xfile.path).readAsBytes();
      if (idcardImage != null) {
        final extension = xfile.name.split('.').last;
        final imgUrl = await _controller.uploadSignature(
          VoteController.to.campaign.companyName,
          '$username-${DateTime.now()}.$extension',
          idcardImage!,
          'idcard',
        );
        voteCtrl.putIdCard(imgUrl);
        setState(() {
          idCardUploaded = true;
        });
      }
    }
  }

  Widget uploadImageButton() {
    return IconButton(
      onPressed: onPressed,
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
                onLongPress: onPressed,
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
              // TODO: 이미지 주소 바로 다시 받아 데이터베이스(유저 객체)에 저장하기
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
