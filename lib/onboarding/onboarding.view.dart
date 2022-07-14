// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation, GetPlatform;

// 🌎 Project imports:
import '../shared/shared.dart';
import '../theme.dart';
import '../utils/shared_prefs.dart';
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
  TabController? _tabController;
  late List<Guide> _guideList;
  List<Widget> _tabs = [];
  int _curIndex = 0;

  void _onTap() async {
    setIamFirstTime();
    jumpToHome();
  }

  void _updateIndex() {
    setState(() {
      _curIndex = _tabController!.index;
    });
  }

  @override
  void initState() {
    super.initState();
    _guideList = mockGuideList;
    _tabs = _guideList.map((item) => GuideItem(guide: item)).toList();
    _tabController = TabController(length: _guideList.length, vsync: this);
    _tabController!.addListener(_updateIndex);
    // analytics.logTutorialBegin();
  }

  @override
  void dispose() {
    _tabController!.removeListener(_updateIndex);
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: customColor[ColorType.deepPurple],
      child: DefaultTabController(
          length: _guideList.length,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: TabBarView(
                    controller: _tabController,
                    physics: const ScrollPhysics(),
                    children: _tabs),
              ),
              Align(alignment: Alignment.topRight, child: _nextIcon(_curIndex)),
            ],
          )),
    );
  }

  Widget _nextIcon(int index) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 40, 20, 0),
      child: TextButton(
        onPressed: _onTap,
        style: TextButton.styleFrom(
          foregroundColor: Colors.white, textStyle: const TextStyle(
            fontSize: 16,
          ),
        ),
        child: CustomText(text: index == 2 ? '시작하기' : '건너뛰기'),
      ),
    );
  }
}

class GuideItem extends Container {
  final Guide guide;
  GuideItem({
    Key? key,
    required this.guide,
  }) : super(
          key: key,
          width: double.infinity,
          height: Get.height - 100,
          padding: const EdgeInsets.only(top: 100),
          color: const Color(0xFF572E67),
          child: Image(
            image: AssetImage(
              GetPlatform.isAndroid ? guide.aosImageUrl : guide.iosImageUrl,
            ),
            fit: BoxFit.contain,
          ),
        );
}
