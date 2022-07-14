// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/shared.dart';
import '../auth/auth.controller.dart';
import '../campaign/campaign.dart';
import '../theme.dart';
import '../vote/vote.controller.dart';
import 'pop_scope.dart';

// Reference: https://github.com/serenader2014/flutter_carousel_slider
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _curPage = 100;
  late Campaign _curCampaign;
  PageController? _controller;
  final AuthController _authCtrl = AuthController.get();
  final VoteController _voteCtrl = VoteController.get();

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.2, initialPage: _curPage);
    _curCampaign = campaigns[_getRealIndex(_curPage, campaigns.length)];
    _authCtrl.init();
    _voteCtrl.init();
    // initFirebase();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _onConfirmed(Campaign campaign) {
    _voteCtrl.setCampaign(campaign);
    goToCampaign();
  }

  void updateCurPage(int index) {
    if (mounted) {
      setState(() {
        _curPage = index;
        _curCampaign = campaigns[_getRealIndex(index, campaigns.length)];
      });
    }
  }

  // Future<void> initFirebase() async {
  //   FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
  //     Navigator.pushNamed(context, dynamicLinkData.link.path);
  //   }).onError((error) {
  //     debugPrint('onLink error');
  //     debugPrint(error.message);
  //   });

  //   NotificationSettings settings = await messaging.requestPermission(
  //     alert: true,
  //     announcement: false,
  //     badge: true,
  //     carPlay: false,
  //     criticalAlert: false,
  //     provisional: false,
  //     sound: true,
  //   );

  //   messaging.onTokenRefresh.listen((fcmToken) {
  //     debugPrint(fcmToken);
  //   }).onError((err) {
  //     // Error getting token.
  //   });

  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     debugPrint('Got a message whilst in the foreground!');
  //     debugPrint('Message data: ${message.data}');

  //     if (message.notification != null) {
  //       debugPrint('Message also contained a notification: ${message.notification}');
  //     }
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return CustomPopScope(
      child: Scaffold(
        body: Stack(children: [
          _backgroundImageLayer(_curCampaign.backgroundImg),
          _topBar(),
          _customPageViewLayer(_controller!, updateCurPage, _curPage,
              campaigns.length, _onConfirmed),
          _informationBox(_curCampaign, _onConfirmed, _controller!),
          // loginBox()
        ]),
      ),
    );
  }
}

Widget _backgroundImageLayer(String imgUrl) {
  return Container(
      height: Get.height,
      width: Get.width,
      color: customColor[ColorType.deepPurple],
      child: Image(
        image: AssetImage(imgUrl),
        fit: BoxFit.cover,
      ));
}

Widget _topBar() {
  const String assetName = 'assets/images/bside_logo.png';
  return Positioned(
      top: 40,
      left: 16,
      child: SizedBox(width: 56, child: Image.asset(assetName)));
}

Widget _customPageViewLayer(
    PageController controller,
    void Function(int) updateCurPage,
    int curPage,
    int campaignLength,
    void Function(Campaign) onConfirmed) {
  onTap(int page) {
    if (page != curPage) {
      controller.animateToPage(page,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic);
    }
  }

  AnimatedContainer _slider(Campaign campaign, int index, int active) {
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
              const Color(0xFF7C299A),
              campaign.color,
              const Color(0xFF572E67),
            ],
            stops: const [0.125, 0.126, 0.6, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Align(
            alignment: Alignment.center,
            child: isActive
                ? Hero(
                    tag: 'companyLogo',
                    child: GestureDetector(
                      onTap: () {
                        onConfirmed(campaign);
                      },
                      child: Avatar(
                          image: campaign.logoImg,
                          backgroundColor: const Color(0xFFFFE0E9),
                          radius: isActive ? 40 : 25),
                    ),
                  )
                : Avatar(
                    image: campaign.logoImg,
                    backgroundColor: const Color(0xFFFFE0E9),
                    radius: isActive ? 40 : 25)));
  }

  return SizedBox(
      width: Get.width,
      height: Get.height * 0.88,
      child: Stack(children: [
        Positioned(
            top: 100,
            right: 16,
            child: SizedBox(
                width: Get.width,
                height: Get.height * 1.25,
                child: PageView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: null,
                    pageSnapping: true,
                    controller: controller,
                    onPageChanged: updateCurPage,
                    itemBuilder: (context, index) {
                      int realIndex = _getRealIndex(index, campaigns.length);
                      return Container(
                          margin: const EdgeInsets.all(13),
                          child: GestureDetector(
                              onTap: () => onTap(index),
                              child: _slider(
                                  campaigns[realIndex], index, curPage)));
                    })))
      ]));
}

Widget _informationBox(Campaign curCampaign, void Function(Campaign) onPress,
    PageController controller) {
  onPrev() {
    controller.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic);
  }

  _onNext() {
    controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic);
  }

  return Positioned(
      top: Get.height * 0.55,
      right: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          IconButton(
              onPressed: onPrev,
              iconSize: 36,
              icon: const Icon(
                Icons.expand_less_rounded,
                color: Colors.white70,
              )),
          CampaignInfo(
            campaign: curCampaign,
            onPress: onPress,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: CustomButton(
              label: curCampaign.status,
              fontSize: 16,
              onPressed: () => onPress(curCampaign),
              bgColor: ColorType.white,
              textColor: ColorType.deepPurple,
              width: CustomW.w1,
            ),
          ),
          const SizedBox(height: 24),
          IconButton(
              onPressed: _onNext,
              iconSize: 36,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: Colors.white70,
              )),
        ],
      ));
}

int _getRealIndex(int position, int? length) {
  if (length == 0) return 0;
  final int result = position % length!;
  return result < 0 ? length + result : result;
}
