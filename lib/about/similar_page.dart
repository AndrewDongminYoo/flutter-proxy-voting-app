import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared/custom_appbar.dart';
// import '../shared/custom_color.dart';
// import '../shared/custom_lottie.dart';

class SimilarPage extends StatefulWidget {
  const SimilarPage({
    Key? key,
    required this.title,
    required this.blueBackGroundWidgets,
    required this.whiteBackGroundWidgets,
    required this.animatedWidgets,
  }) : super(key: key);
  final String title;
  final List<Widget> blueBackGroundWidgets;
  final List<Widget> whiteBackGroundWidgets;
  final Widget animatedWidgets;

  @override
  State<SimilarPage> createState() => _SimilarPageState();
}

class _SimilarPageState extends State<SimilarPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.title,
        withoutBack: true,
        bgColor: const Color(0xff60457A),
      ),
      body: SizedBox(
        height: Get.height - 100,
        width: Get.width,
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff60457A),
                    Color(0xff80A1DF),
                  ],
                ),
              ),
              child: Column(
                children: widget.blueBackGroundWidgets,
              ),
            ),
            const SizedBox(height: 37),
            Container(
              width: Get.width,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: Get.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.whiteBackGroundWidgets,
                ),
              ),
            ),
            const SizedBox(height: 100),
            widget.animatedWidgets,
          ],
        )),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     //TODO: Add your onPressed code here!
      //   },
      //   backgroundColor: customColor[ColorType.yellow],
      //   child: lottieChat,
      // ),
    );
  }
}
