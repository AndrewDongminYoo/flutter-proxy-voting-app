// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart';
import 'package:get/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import '../theme.dart';
import '../get_nav.dart';
import 'guide.data.dart';

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

  void onTap() async {
    savePref();
    jumpToHome();
  }

  void savePref() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstTime', false);
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
    // analytics.logTutorialBegin();
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
        image: AssetImage(
            GetPlatform.isAndroid ? guide.aosImageUrl : guide.iosImageUrl),
        fit: BoxFit.contain,
      ),
    );
  }
}
