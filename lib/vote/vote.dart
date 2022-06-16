import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'vote.model.dart';
import 'vote_selector.dart';
import '../campaign/campaign.controller.dart';

class VotePage extends StatefulWidget {
  const VotePage({Key? key}) : super(key: key);

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  final CampaignController _controller = Get.isRegistered<CampaignController>()
      ? Get.find()
      : Get.put(CampaignController());

  var marker = <String, int>{
    'cur': 0,
    'latest': 0,
  };

  goBack() {
    Get.back();
  }

  onVote(int index, VoteType result) {
    setState(() {
      marker = {
        'cur': index + 1,
        'latest': max(marker['latest']!, index + 1),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: const Color(0xFF5E3F74),
            elevation: 0,
            leading: IconButton(
              tooltip: "뒤로가기",
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: goBack,
            )),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children:
                  _controller.campaign.agendaList.asMap().entries.map((item) {
                // Do not show the next item
                if (item.key > marker['latest']!) {
                  return Container();
                }
                return VoteSelector(agendaItem: item.value, index: item.key, onVote: onVote);
              }).toList(),
            ),
          ),
        ));
  }
}

