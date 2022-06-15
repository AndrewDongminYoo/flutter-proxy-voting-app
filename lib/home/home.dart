import 'dart:ui';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bside/home/campaign.dart';

// Reference: https://github.com/serenader2014/flutter_carousel_slider
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int curPage = 30;
  late Campaign curCampaign;
  PageController? controller;

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
    controller = PageController(viewportFraction: 0.2, initialPage: curPage);
    curCampaign = campaigns[getRealIndex(curPage, campaigns.length)];
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        backgroundImageLayer(curCampaign.backgroundImg),
        imageFilterLayer(),
        topBar(),
        customPageViewLayer(
            controller!, updateCurPage, curPage, campaigns.length),
        informationBox(curCampaign, controller!),
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
          child: Container(color: const Color(0xFF2B1433).withOpacity(0.8))));
}

Widget topBar() {
  const String assetName = "assets/images/bside_web.svg";
  return Positioned(
      top: 40,
      left: 20,
      child: Image.network("https://bside.ai/_nuxt/img/logo.71a8129.png"));
}

Widget customPageViewLayer(PageController controller,
    void Function(int) updateCurPage, int curPage, int campaignLength) {
  AnimatedContainer slider(Campaign campaign, int index, int active) {
    bool isActive = index == active;
    return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
        margin: EdgeInsets.only(
            right: isActive ? Get.width * 0.4 : Get.width * 0.65),
        decoration: BoxDecoration(
          color: campaign.color,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(80), bottomRight: Radius.circular(80)),
          gradient: SweepGradient(
            center: Alignment.center,
            colors: <Color>[
              const Color(0xFF572E67),
              Colors.deepPurple,
              campaign.color,
              const Color(0xFF572E67),
            ],
            stops: const [0.125, 0.126, 0.6, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 40.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(campaign.logoImg),
              // FIXME: 하드코딩된 % 3 수정 필요
              backgroundColor:
                  index % 3 == 0 ? const Color(0xFFFFE0E9) : Colors.white,
              radius: isActive ? 50 : 30,
            ),
          ),
        ));
  }

  return SizedBox(
      width: Get.width,
      height: Get.height * 0.7 + 80,
      child: Stack(children: [
        Positioned(
            top: 80,
            right: 16,
            child: SizedBox(
                width: Get.width,
                height: Get.height * 1.15,
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

Widget informationBox(Campaign curCampaign, PageController controller) {
  onPrev() {
    controller.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic);
  }

  onNext() {
    controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic);
  }

  onPress() {
    print('print');
  }

  Widget customTextButton() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              primary: Colors.deepPurple,
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: onPress,
            child: const Text('더보기'),
          ),
        ],
      ),
    );
  }

  return Positioned(
      bottom: Get.height * 0.185,
      right: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
              onPressed: onPrev,
              iconSize: 36,
              icon:
                  const Icon(Icons.expand_less_rounded, color: Colors.white70)),
          Text(
            curCampaign.companyName,
            style: const TextStyle(
                color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          Text(
            curCampaign.moderator,
            style:
                const TextStyle(color: Colors.white, fontSize: 16, height: 2),
          ),
          Text(
            curCampaign.date,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: customTextButton(),
          ),
          IconButton(
              onPressed: onNext,
              iconSize: 36,
              icon:
                  const Icon(Icons.expand_more_rounded, color: Colors.white70)),
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
              Icons.login_rounded,
              size: 24,
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
