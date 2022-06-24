import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'signature.upload.dart';
import 'common_app_body.dart';

class TakeBackNumberPage extends StatefulWidget {
  const TakeBackNumberPage({Key? key}) : super(key: key);

  @override
  State<TakeBackNumberPage> createState() => _TakeBackNumberPageState();
}

class _TakeBackNumberPageState extends State<TakeBackNumberPage> {
  final CustomSignatureController _controller =
      Get.isRegistered<CustomSignatureController>()
          ? Get.find()
          : Get.put(CustomSignatureController());

  @override
  Widget build(BuildContext context) {
    return const AppBodyPage(
      helpText: '',
      informationString: '',
      mainContent: Text(''),
      subContentList: Text(''),
      titleString: '',
    );
  }
}
