import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../chatting/chatting.dart';
import '../shared/custom_appbar.dart';
import '../shared/custom_color.dart';
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
  onPressFloatingBtn() {
    showModalBottomSheet(
        isScrollControlled: true,
        builder: (context) => Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: ChattingPage(),
            ),
        context: context);
  }

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
        child: Stack(children: [
          SingleScrollView(
              widget: widget, blueWidget: widget, whiteWidget: widget),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onPressFloatingBtn,
        backgroundColor: customColor[ColorType.yellow],
        child: Icon(Icons.chat_rounded),
      ),
    );
  }
}

class SingleScrollView extends StatelessWidget {
  const SingleScrollView({
    Key? key,
    required this.widget,
    required this.blueWidget,
    required this.whiteWidget,
  }) : super(key: key);

  final SimilarPage widget;
  final SimilarPage blueWidget;
  final SimilarPage whiteWidget;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            children: blueWidget.blueBackGroundWidgets,
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
              children: whiteWidget.whiteBackGroundWidgets,
            ),
          ),
        ),
        const SizedBox(height: 40),
        widget.animatedWidgets,
      ],
    ));
  }
}
