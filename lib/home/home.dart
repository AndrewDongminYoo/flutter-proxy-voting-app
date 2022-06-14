import 'package:flutter/material.dart';
import 'package:bside/home/campaign.dart';
import 'package:get/get.dart';

// Reference: https://github.com/serenader2014/flutter_carousel_slider
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int initialPage = 30;
  int activePage = 2;
  late PageController _controller;

  onTap(Campaign campaign) {}

  @override
  void initState() {
    super.initState();
    _controller =
        PageController(viewportFraction: 0.2, initialPage: initialPage);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OverflowBox(
        minWidth: 0.0,
        minHeight: 0.0,
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        alignment: Alignment.topRight,
        child: SizedBox(
          width: Get.width * 2,
          height: Get.height * 1.65,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: null,
            pageSnapping: true,
            controller: _controller,
            onPageChanged: (int index) {
              // int curPage = getRealIndex(index, campaigns.length);
              setState(() {
                activePage = index;
              });
            },
            itemBuilder: (context, index) {
              int curPage = getRealIndex(index, campaigns.length);
              return Container(
                  margin: const EdgeInsets.all(10),
                  child: slider(campaigns[curPage], index, activePage));
            },
          ),
        ),
      ),
    );
  }
}

AnimatedContainer slider(Campaign campaign, int index, int active) {
  bool isActive = index == active;

  return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
      margin:
          EdgeInsets.only(right: isActive ? Get.width * 0.4 : Get.width * 0.6),
      decoration: BoxDecoration(
          color: campaign.color,
          border: Border.all(color: campaign.color),
          borderRadius: const BorderRadius.all(Radius.circular(100))),
      child: Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: EdgeInsets.only(right: isActive ? 80.0 : 40.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(campaign.logoImg),
            backgroundColor: Colors.white,
            radius: isActive ? 50 : 30,
          ),
        ),
      ));
}

int getRealIndex(int position, int? length) {
  if (length == 0) return 0;
  final int result = position % length!;
  return result < 0 ? length + result : result;
}
