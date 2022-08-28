// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'campaign.dart';
import '../home/home.view.dart';
import '../shared/yotube.dart';
import '../vote/vote.controller.dart';

class PreviewCampaignPage extends StatefulWidget {
  const PreviewCampaignPage({Key? key}) : super(key: key);

  @override
  State<PreviewCampaignPage> createState() => _PreviewCampaignPageState();
}

class _PreviewCampaignPageState extends State<PreviewCampaignPage> {
  final VoteController _voteCtrl = VoteController.get();
  final List<List> title = [
    ['전자위임', Icons.description_outlined],
    ['캠페인', Icons.import_contacts_outlined],
    ['라운지', Icons.people_outline],
    ['공시서류', Icons.attachment_outlined],
    ['이전기록', Icons.history]
  ];
  final List progress = ['공개 진행중', '주주제안 진행중', '의결권 위임 진행중', '주주총회 진행중'];
  // TODO: 데이터 직접 입력 제거하기
  final int progressState = 2;
  int bottomsheetHeight = 3;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Campaign campaign = _voteCtrl.campaign;

    return Scaffold(
      body: Hero(
        tag: 'previewCampaign',
        child: Stack(
          children: [
            backgroundImageLayer(campaign.backgroundImg),
            Wrap(
              children: const [
                CompanyLogoWidget(),
                CompanyLogoWidget(),
              ],
            ),
            CampaignInfoWidget(campaign: campaign),
            bottomsheetHeight == 4 ? blur() : Container(),
            customBottomsheet(campaign)
          ],
        ),
      ),
    );
  }

  Widget customBottomsheet(campaign) {
    return AnimatedContainer(
      height: Get.height,
      transform: Matrix4.translationValues(
          0,
          bottomsheetHeight == 0
              ? Get.height
              : bottomsheetHeight == 1
                  ? Get.height * 0.8
                  : bottomsheetHeight == 2
                      ? Get.height * 0.6
                      : bottomsheetHeight == 3
                          ? Get.height * 0.4
                          : bottomsheetHeight == 4
                              ? Get.height * 0.2
                              : bottomsheetHeight == 5
                                  ? 0
                                  : Get.height,
          0),
      duration: const Duration(milliseconds: 500),
      child: Wrap(
        alignment: WrapAlignment.center,
        children: [
          Material(
            color: const Color.fromARGB(0, 0, 0, 0),
            child: IconButton(
                onPressed: () => setState(() {
                      bottomsheetHeight == 3
                          ? bottomsheetHeight = 4
                          : bottomsheetHeight = 3;
                    }),
                iconSize: 36,
                icon: Icon(
                  bottomsheetHeight == 3
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: Colors.white70,
                )),
          ),
          Container(
            height: Get.height * 0.8,
            width: Get.width,
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(18), topLeft: Radius.circular(18)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: <Color>[
                  campaign.color,
                  const Color(0xFF7C299A),
                  const Color(0xFF572E67),
                  const Color(0xFF5E3F74),
                ],
                tileMode: TileMode.clamp,
              ),
            ),
            child: Wrap(
              runSpacing: 25,
              alignment: WrapAlignment.center,
              children: [
                const BarIconWidget(),
                ProgressInfoWidget(
                  progress: progress,
                  progressState: progressState,
                  campaign: campaign,
                ),
                RouteTileWidget(title: title, campaign: campaign),
                const YoutubeApp(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget blur() {
    return GestureDetector(
        onTap: () {
          setState(() {
            bottomsheetHeight = 3;
          });
        },
        child: Container(color: const Color.fromARGB(174, 0, 0, 0)));
  }
}
