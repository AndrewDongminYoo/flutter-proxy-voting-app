import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'campaign.controller.dart';

class CampaignPage extends StatefulWidget {
  const CampaignPage({Key? key}) : super(key: key);

  @override
  State<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends State<CampaignPage> {
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        gradientLayer(),
        Column(
          children: [
            Column(
              children: [
                const SizedBox(height: 40),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _controller.campaign.slogan,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                    CircleAvatar(
                        backgroundImage:
                            NetworkImage(_controller.campaign.logoImg),
                        backgroundColor: Colors.white,
                        radius: 25)
                  ],
                ),
              ],
            )
          ],
        )
      ]),
    );
  }
}

Widget gradientLayer() {
  return Positioned.fill(
      child: Container(
    width: Get.width,
    decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5E3F74), Color(0xFF82A5E1)])),
  ));
}
