import "package:flutter/material.dart";
import 'package:get/route_manager.dart' show Get, GetNavigation;
import 'package:bside/onboarding/guide.dart' show Guide;
import 'package:bside/onboarding/guide_mock_data.dart' show mockGuideList;

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
  late PageController pageController;
  late List<Guide> guideList;
  List<Widget> tabs = [];

  void onTap() {
    Get.toNamed('/');
  }

  @override
  void initState() {
    super.initState();
    guideList = mockGuideList;
    tabs = guideList.map((item) => GuideItem(guide: item)).toList();
    tabController = TabController(length: guideList.length, vsync: this);
    pageController = PageController();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
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
                width: 80,
                height: 30,
                margin: const EdgeInsets.only(bottom: 30),
                child: TabPageSelector(
                    controller: tabController,
                    selectedColor: Colors.purple,
                    color: Colors.white.withOpacity(0.5)),
              ),
            )
          ],
        ));
  }

  Widget nextIcon() {
    return GestureDetector(
        onTap: onTap,
        child: Container(
            margin: const EdgeInsets.all(16.0),
            child: const Material(
                color: Colors.black45,
                shape: CircleBorder(),
                child: Padding(
                    padding: EdgeInsets.fromLTRB(12.0, 12.0, 8.0, 12.0),
                    child: Icon(Icons.arrow_forward_ios,
                        color: Colors.white70)))));
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
