import 'dart:math';

import 'package:bside/shared/custom_button.dart';
import 'package:bside/shared/custom_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'vote.model.dart';
import 'vote_selector.dart';
import '../shared/custom_appbar.dart';
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

  onNext() {
    Get.toNamed('/signature');
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
    final agendaLength = _controller.campaign.agendaList.length;

    return Scaffold(
        appBar: const CustomAppBar(title: ""),
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
                } else if (item.key == agendaLength - 1) {
                  return Column(children: [
                    VoteSelector(
                        agendaItem: item.value,
                        index: item.key,
                        onVote: onVote),
                    marker['latest']! < agendaLength
                        ? Container()
                        : Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0, 20.0, 0, 100.0),
                            child: CustomButton(
                                label: '위임확인',
                                onPressed: onNext,
                                width: CustomW.w4),
                          ),
                  ]);
                }
                return VoteSelector(
                    agendaItem: item.value, index: item.key, onVote: onVote);
              }).toList(),
            ),
          ),
        ));
  }
}
