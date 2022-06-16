import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VotePage extends StatefulWidget {
  const VotePage({Key? key}) : super(key: key);

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  goBack() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color(0xFF5E3F74),
          elevation: 0,
          leading: IconButton(
            tooltip: "뒤로가기",
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: goBack,
          )),
      body: Container(),
    );
  }
}
