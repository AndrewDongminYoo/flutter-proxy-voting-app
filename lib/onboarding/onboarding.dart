import "package:flutter/material.dart";
import 'package:get/route_manager.dart' show Get, GetNavigation;

import 'guide.dart' show Guide;
import 'guide.data.dart' show mockGuideList;
import '../shared/custom_color.dart';

/*
  Reference:
  - main: https://github.com/duytq94/flutter-intro-slider
  - sub: https://github.com/TheAnkurPanchani/card_swiper
  - page indicator: https://github.com/best-flutter/flutter_page_indicator
*/
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  late List<Guide> guideList;
  List<Widget> tabs = [];
  int _curIndex = 0;

  void onTap() {
    if (tabController!.index < tabs.length - 1) {
      tabController!.animateTo(2);
      setState(() {
        _curIndex = 2;
      });
    } else {
      Get.offAllNamed('/');
    }
  }

  void updateIndex() {
    setState(() {
      _curIndex = tabController!.index;
    });
  }

  @override
  void initState() {
    super.initState();
    guideList = mockGuideList;
    tabs = guideList.map((item) => GuideItem(guide: item)).toList();
    tabController = TabController(length: guideList.length, vsync: this);
    tabController!.addListener(updateIndex);
  }

  @override
  void dispose() {
    tabController!.removeListener(updateIndex);
    tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: customColor[ColorType.deepPurple],
      child: DefaultTabController(
          length: guideList.length,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: TabBarView(
                    controller: tabController,
                    physics: const ScrollPhysics(),
                    children: tabs),
              ),
              Align(alignment: Alignment.topRight, child: nextIcon(_curIndex)),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Container(
              //       margin: const EdgeInsets.only(bottom: 30),
              //       child: TabPageSelector(
              //         indicatorSize: 10,
              //         controller: tabController,
              //         selectedColor: Colors.deepPurple,
              //         color: Colors.grey,
              //         borderStyle: BorderStyle.none,
              //       )),
              // ),
            ],
          )),
    );
  }

  Widget nextIcon(int index) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 40, 20, 0),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          textStyle: const TextStyle(
            fontSize: 16,
          ),
          primary: Colors.white,
        ),
        child: Text(index == 2 ? '시작하기' : '건너뛰기'),
      ),
    );
  }
}

class GuideItem extends StatelessWidget {
  const GuideItem({Key? key, required this.guide}) : super(key: key);
  final Guide guide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: Get.height - 100,
      padding: const EdgeInsets.only(top: 100),
      color: const Color(0xFF572E67),
      child: Image(
        image: AssetImage(guide.imageURL),
        fit: BoxFit.contain,
      ),
    );
  }
}
