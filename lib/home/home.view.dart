// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../shared/custom_avatar.dart';
import '../shared/custom_nav.dart';
import '../auth/auth.controller.dart';
import '../campaign/campaign.data.dart';
import '../campaign/campaign.model.dart';
import '../campaign/campaign_info.dart';
import '../shared/custom_button.dart';
import '../shared/custom_text.dart';
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
  int curPage = 100;
  late Campaign curCampaign;
  PageController? controller;
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: 0.2, initialPage: curPage);
    curCampaign = campaigns[getRealIndex(curPage, campaigns.length)];
    authCtrl.init();
    voteCtrl.init();
    // initFirebase();
  }

  @override
  void dispose() {
    controller!.dispose();
    super.dispose();
  }

  void onConfirmed(Campaign campaign) {
    voteCtrl.setCampaign(campaign);
    goToCampaign();
  }

  void updateCurPage(int index) {
    if (mounted) {
      setState(() {
        curPage = index;
        curCampaign = campaigns[getRealIndex(index, campaigns.length)];
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
          backgroundImageLayer(curCampaign.backgroundImg),
          topBar(),
          customPageViewLayer(controller!, updateCurPage, curPage,
              campaigns.length, onConfirmed),
          informationBox(curCampaign, onConfirmed, controller!),
          // loginBox()
        ]),
      ),
    );
  }
}

Widget backgroundImageLayer(String imgUrl) {
  return Container(
      height: Get.height,
      width: Get.width,
      color: customColor[ColorType.deepPurple],
      child: Image(
        image: AssetImage(imgUrl),
        fit: BoxFit.cover,
      ));
}

Widget topBar() {
  const String assetName = 'assets/images/bside_logo.png';
  return Positioned(
      top: 40,
      left: 16,
      child: SizedBox(width: 56, child: Image.asset(assetName)));
}

Widget customPageViewLayer(
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
                      int realIndex = getRealIndex(index, campaigns.length);
                      return Container(
                          margin: const EdgeInsets.all(13),
                          child: GestureDetector(
                              onTap: () => onTap(index),
                              child: slider(
                                  campaigns[realIndex], index, curPage)));
                    })))
      ]));
}

Widget informationBox(Campaign curCampaign, void Function(Campaign) onPress,
    PageController controller) {
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
              label: curCampaign.getStatus(),
              onPressed: () => onPress(curCampaign),
              bgColor: ColorType.white,
              textColor: ColorType.deepPurple,
              width: CustomW.w1,
            ),
          ),
          const SizedBox(height: 24),
          IconButton(
              onPressed: onNext,
              iconSize: 36,
              icon: const Icon(
                Icons.expand_more_rounded,
                color: Colors.white70,
              )),
        ],
      ));
}

Widget loginBox() {
  void onClicked() {
    // Force a test crash to finish setup
    // throw Exception("Throw Test Exception");
  }

  return Positioned(
    bottom: 0,
    right: 12,
    child: InkWell(
      onTap: onClicked,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0))),
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
            CustomText(
              text: '로그인',
              typoType: TypoType.h2,
            ),
          ],
        ),
      ),
    ),
  );
}

int getRealIndex(int position, int? length) {
  if (length == 0) return 0;
  final int result = position % length!;
  return result < 0 ? length + result : result;
}
