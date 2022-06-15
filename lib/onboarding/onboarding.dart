import "package:flutter/material.dart";
import 'package:get/route_manager.dart' show Get, GetNavigation;
import 'package:bside/onboarding/guide.dart' show Guide;
import 'package:bside/onboarding/guide.data.dart' show mockGuideList;

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
  late TabController tabController;
  late List<Guide> guideList;
  List<Widget> tabs = [];

  void onTap() {
    if (tabController.index < tabs.length - 1) {
      tabController.animateTo(2);
    } else {
      Get.toNamed('/');
    }
  }

  @override
  void initState() {
    super.initState();
    guideList = mockGuideList;
    tabs = guideList.map((item) => GuideItem(guide: item)).toList();
    tabController = TabController(length: guideList.length, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
          length: guideList.length,
          child: Stack(
            children: [
              TabBarView(
                  controller: tabController,
                  physics: const ScrollPhysics(),
                  children: tabs),
              Align(alignment: Alignment.topRight, child: nextIcon()),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    child: TabPageSelector(
                      controller: tabController,
                      selectedColor: Colors.deepPurple,
                      color: Colors.grey,
                      borderStyle: BorderStyle.none,
                    )),
              ),
            ],
          )),
    );
  }

  Widget nextIcon() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 40, 20, 0),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
            textStyle: const TextStyle(fontSize: 16), primary: Colors.white),
        child: const Text('건너뛰기'),
      ),
    );
  }
}

class GuideItem extends StatelessWidget {
  const GuideItem({Key? key, required this.guide}) : super(key: key);
  final Guide guide;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Image.network(guide.imageURL, fit: BoxFit.cover));
  }
}
