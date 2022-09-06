// 🎯 Dart imports:
import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../shared/shared.dart';
import '../vote/vote.controller.dart';
import 'signature.dart';

class UploadIdCardPage extends StatefulWidget {
  const UploadIdCardPage({Key? key}) : super(key: key);

  @override
  State<UploadIdCardPage> createState() => _UploadIdCardPageState();
}

class _UploadIdCardPageState extends State<UploadIdCardPage> {
  Uint8List? _idcardImage;
  String _username = '';
  String _informationString = '';
  final ImagePicker _picker = ImagePicker();

  final CustomSignController _controller = CustomSignController.get();
  final AuthController _authCtrl = AuthController.get();
  final VoteController _voteCtrl = VoteController.get();
  ImageSource _source = ImageSource.camera;

  void _onPressed() async {
    if (_authCtrl.canVote) {
      _username = _authCtrl.user.username;
    }
    await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          elevation: 10,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20.0,
          ),
          title: CustomText(
            text: '신분증을 촬영해주세요.',
            typoType: TypoType.h2Bold,
          ),
          children: [
            SimpleDialogOption(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _source = ImageSource.camera;
                  });
                }
                Navigator.pop(context, _source);
              },
              child: CustomText(
                text: '카메라 촬영',
                typoType: TypoType.bodyLight,
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                if (mounted) {
                  setState(() {
                    _source = ImageSource.gallery;
                  });
                }
                Navigator.pop(context, _source);
              },
              child: CustomText(
                text: '갤러리 선택',
                typoType: TypoType.bodyLight,
              ),
            ),
          ],
        );
      },
    );

    final XFile? xfile = await _picker.pickImage(
      maxWidth: 1900,
      maxHeight: 600,
      source: _source,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (xfile != null) {
      _idcardImage = await File(xfile.path).readAsBytes();
      if (_idcardImage != null) {
        final extension = xfile.name.split('.').last;
        final imgUrl = await _controller.uploadSignature(
          _voteCtrl.campaign.enName,
          '$_username-${DateTime.now()}.$extension',
          _idcardImage!,
          'idcard',
        );
        _voteCtrl.putIdCard(imgUrl);
        setState(() {});
      }
    }
  }

  Widget _uploadImageButton() {
    return IconButton(
      onPressed: _onPressed,
      icon: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomText(text: '촬영 및 업로드하기'),
          const SizedBox(
            height: 10,
          ),
          const Icon(
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const titleString = '전자서명';
    const helpText = '신분증을 촬영해주세요';
    _informationString = _voteCtrl.voteAgenda.idCardAt != null
        ? '${timeago.format(_voteCtrl.voteAgenda.idCardAt!, locale: 'ko')}에 이미 업로드하였습니다. 재 업로드하시려면 가운데를 클릭하세요.'
        : '''
신분증 사본은 위임장 본인확인 증빙 자료로 활용됩니다. 
촬영 시 주민등록번호의 뒷자리를 가려주세요. 
신분증 원본의 민감한 개인정보는 보안 기술에 의해 자동으로 보이지 않게 삭제됩니다.''';
    Widget mainContent = Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
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
        child: (_idcardImage != null
            ? GestureDetector(
                onLongPress: _onPressed,
                child: Image.memory(
                  _idcardImage!,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              )
            : _uploadImageButton()),
      ),
    );

    Widget subContentList = Column(
      children: [
        CustomButton(
          label: '등록',
          onPressed: () {
            if (_idcardImage != null) {
              if (_authCtrl.user.backId.length > 1) {
                jumpToResult();
              }
              goTakeIdNumber();
            }
          },
        ),
      ],
    );
    return AppBodyPage(
      titleString: titleString,
      helpText: helpText,
      informationString: _informationString,
      mainContent: mainContent,
      subContentList: subContentList,
    );
  }
}
