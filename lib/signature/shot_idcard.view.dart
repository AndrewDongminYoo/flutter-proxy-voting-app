// ๐ฏ Dart imports:
import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;

// ๐ฆ Flutter imports:
import 'package:flutter/material.dart';

// ๐ฆ Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

// ๐ Project imports:
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

  final SignController _controller = SignController.get();
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
            text: '์ ๋ถ์ฆ์ ์ดฌ์ํด์ฃผ์ธ์.',
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
                text: '์นด๋ฉ๋ผ ์ดฌ์',
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
                text: '๊ฐค๋ฌ๋ฆฌ ์ ํ',
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
        final String extension = xfile.name.split('.').last;
        final String imgUrl = await _controller.uploadSignature(
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
          CustomText(text: '์ดฌ์ ๋ฐ ์๋ก๋ํ๊ธฐ'),
          const SizedBox(
            height: 10,
          ),
          const Icon(
            Icons.upload_file_rounded,
            size: 50,
            color: Colors.deepOrange,
            semanticLabel: '์ดฌ์ ๋ฐ ์๋ก๋',
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
    const String titleString = '์ ์์๋ช';
    const String helpText = '์ ๋ถ์ฆ์ ์ดฌ์ํด์ฃผ์ธ์';
    _informationString = _voteCtrl.voteAgenda.idCardAt != null
        ? '${timeago.format(_voteCtrl.voteAgenda.idCardAt!, locale: 'ko')}์ ์ด๋ฏธ ์๋ก๋ํ์์ต๋๋ค. ์ฌ ์๋ก๋ํ์๋ ค๋ฉด ๊ฐ์ด๋ฐ๋ฅผ ํด๋ฆญํ์ธ์.'
        : '''
์ ๋ถ์ฆ ์ฌ๋ณธ์ ์์์ฅ ๋ณธ์ธํ์ธ ์ฆ๋น ์๋ฃ๋ก ํ์ฉ๋ฉ๋๋ค. 
์ดฌ์ ์ ์ฃผ๋ฏผ๋ฑ๋ก๋ฒํธ์ ๋ท์๋ฆฌ๋ฅผ ๊ฐ๋ ค์ฃผ์ธ์. 
์ ๋ถ์ฆ ์๋ณธ์ ๋ฏผ๊ฐํ ๊ฐ์ธ์ ๋ณด๋ ๋ณด์ ๊ธฐ์ ์ ์ํด ์๋์ผ๋ก ๋ณด์ด์ง ์๊ฒ ์ญ์ ๋ฉ๋๋ค.''';
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
          label: '๋ฑ๋ก',
          onPressed: () {
            if (_idcardImage != null) {
              if (_authCtrl.user.backId.length > 1) {
                jumpToVoteResult();
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
