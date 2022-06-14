import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'guide.dart';
import 'guide_mock_data.dart';

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
    Get.toNamed('/');
  }

  @override
  void initState() {
    super.initState();
    guideList = mockGuideList;
    tabs = guideList.map((item) => GuideItem(guide: item)).toList();
    tabController = TabController(length: guideList.length, vsync: this);
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
            Align(alignment: Alignment.topRight, child: nextIcon())
          ],
        ));
  }

  Widget nextIcon() {
    return Container(
        margin: const EdgeInsets.all(16.0),
        child: Material(
            color: Colors.black45,
            shape: const CircleBorder(),
            child: Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 8.0, 12.0),
                child: GestureDetector(
                    onTap: onTap,
                    child: const Icon(Icons.arrow_forward_ios,
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
