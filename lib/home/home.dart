import 'dart:ui';

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
  int curPage = 2;
  late Campaign curCampaign;
  late PageController _controller;

  onTap(Campaign campaign) {}

  updateCurPage(int index) {
    setState(() {
      curPage = index;
      curCampaign = campaigns[getRealIndex(index, campaigns.length)];
    });
  }

  @override
  void initState() {
    super.initState();
    _controller =
        PageController(viewportFraction: 0.2, initialPage: initialPage);
    curCampaign = campaigns[getRealIndex(initialPage, campaigns.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        backgroundImageLayer(curCampaign.backgroundImg),
        imageFilterLayer(),
        customPageViewLayer(
            _controller, updateCurPage, curPage, campaigns.length),
        informationBox(curCampaign),
        loginBox()
      ]),
    );
  }
}

Widget backgroundImageLayer(String imgUrl) {
  return Container(
      height: Get.height,
      width: Get.width,
      decoration: BoxDecoration(
          image:
              DecorationImage(image: NetworkImage(imgUrl), fit: BoxFit.cover)));
}

Widget imageFilterLayer() {
  return Positioned.fill(
      child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.deepPurpleAccent.withOpacity(0.4))));
}

Widget customPageViewLayer(PageController controller,
    void Function(int) updateCurPage, int curPage, int campaignLength) {
  AnimatedContainer slider(Campaign campaign, int index, int active) {
    bool isActive = index == active;

    return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        margin: EdgeInsets.only(
            right: isActive ? Get.width * 0.4 : Get.width * 0.7),
        decoration: BoxDecoration(
            color: campaign.color,
            border: Border.all(color: campaign.color),
            borderRadius: const BorderRadius.all(Radius.circular(100))),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(campaign.logoImg),
              backgroundColor: Colors.white,
              radius: isActive ? 50 : 30,
            ),
          ),
        ));
  }

  return SizedBox(
      width: Get.width,
      height: Get.height * 0.75 + 60.0,
      child: Stack(children: [
        Positioned(
            top: 60,
            right: 0,
            child: SizedBox(
                width: Get.width * 2,
                height: Get.height * 1.25,
                child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: null,
                    pageSnapping: true,
                    controller: controller,
                    onPageChanged: updateCurPage,
                    itemBuilder: (context, index) {
                      int activePage = getRealIndex(index, campaigns.length);
                      return Container(
                          margin: const EdgeInsets.all(10),
                          child: slider(campaigns[activePage], index, curPage));
                    })))
      ]));
}

Widget informationBox(Campaign curCampaign) {
  return Positioned(
      bottom: Get.height * 0.25,
      right: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            curCampaign.companyName,
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            curCampaign.moderator,
            style:
                const TextStyle(color: Colors.white, fontSize: 18, height: 2),
          ),
          Text(
            curCampaign.date,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ));
}

Widget loginBox() {
  void onClicked() {
    print('onClicked');
  }

  return Positioned(
    bottom: 0,
    right: 12,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.door_front_door_outlined,
              size: 30,
              color: Colors.white,
            ),
          ),
          const Text(
            '로그인',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    ),
  );
}

int getRealIndex(int position, int? length) {
  if (length == 0) return 0;
  final int result = position % length!;
  return result < 0 ? length + result : result;
}
