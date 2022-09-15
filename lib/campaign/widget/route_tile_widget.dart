// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/route_manager.dart' show Get;
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:url_launcher/url_launcher_string.dart';

// 🌎 Project imports:
import '../../campaign/campaign.model.dart';
import '../../shared/custom_nav.dart';

class RouteTileWidget extends StatelessWidget {
  const RouteTileWidget({
    Key? key,
    required this.title,
    required this.campaign,
  }) : super(key: key);

  final List<List<dynamic>> title;
  final Campaign campaign;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      height: 100,
      width: Get.width * 0.9,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: title.length,
        itemBuilder: (BuildContext context, int index) {
          return Material(
            color: const Color.fromARGB(0, 255, 255, 255),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18), color: Colors.white),
              height: 100,
              width: 90,
              margin: const EdgeInsets.fromLTRB(5, 5, 5, 5),
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      title[index][1] as IconData,
                      size: 30,
                      color: const Color(0xFF572E66),
                    ),
                    onPressed: () async {
                      index == 0
                          ? goAuthSignUp()
                          : index == 1
                              ? goCampaignOverview()
                              : index == 2
                                  ? goCampaignOverview()
                                  : index == 3
                                      ? await launchUrlString(campaign.dartUrl)
                                      : goCampaignOverview();
                    },
                  ),
                  Text(
                    title[index][0] as String,
                    style: const TextStyle(
                      letterSpacing: 0.28,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
