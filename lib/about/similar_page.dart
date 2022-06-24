import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../shared/custom_appbar.dart';
import '../shared/custom_color.dart';

class SimilarPage extends StatefulWidget {
  const SimilarPage({
    Key? key,
    required this.blueBackGroundWidgets,
    required this.whiteBackGroundWidgets,
    required this.animatedWidgets,
  }) : super(key: key);

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
      appBar: const CustomAppBar(
        title: '본인확인자료',
      ),
      body: Center(
        child: ListView(
          children: [
            Container(
                width: Get.width,
                height: 450,
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
                )),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.whiteBackGroundWidgets,
              ),
            ),
            widget.animatedWidgets,
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add your onPressed code here!
        },
        backgroundColor: customColor[ColorType.yellow],
        child: const Icon(Icons.chat_rounded, color: Color(0xFFDC721E)),
      ),
    );
  }
}
