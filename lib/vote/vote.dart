import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'vote.model.dart';
import 'vote_selector.dart';
import '../shared/custom_grid.dart';
import '../auth/auth.controller.dart';
import '../vote/vote.controller.dart';
import '../shared/custom_appbar.dart';
import '../shared/custom_button.dart';

class VotePage extends StatefulWidget {
  const VotePage({Key? key}) : super(key: key);

  @override
  State<VotePage> createState() => _VotePageState();
}

class _VotePageState extends State<VotePage> {
  final AuthController _authController = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  final VoteController _voteController = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  var marker = <String, int>{
    'cur': 0,
    'latest': 0,
  };
  final voteResult = <int, VoteType>{};

  @override
  void initState() {
    super.initState();
    if (Get.arguments == 'voteWithExample') {
      voteResult[0] = VoteType.disagree;
      voteResult[1] = VoteType.agree;
      voteResult[2] = VoteType.agree;
      voteResult[3] = VoteType.disagree;
      setState(() {
        marker = {
          'cur': 4,
          'latest': 4,
        };
      });
    }
  }

  goBack() {
    Get.back();
  }

  onNext() {
    _voteController.postVoteResult(
        _authController.user!.id, voteResult.values.toList());
    Get.toNamed('/signature');
  }

  onVote(int index, VoteType result) {
    setState(() {
      voteResult[index] = result;
      marker = {
        'cur': index + 1,
        'latest': max(marker['latest']!, index + 1),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final agendaList = VoteController.to.campaign.agendaList;
    final agendaLength = agendaList.length;
    final useDefault = Get.arguments == 'voteWithExample';

    return Scaffold(
        appBar: const CustomAppBar(title: '의결수 확인'),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: agendaList.asMap().entries.map((item) {
                // Do not show the next item
                if (item.key > marker['latest']!) {
                  return Container();
                } else if (item.key == agendaLength - 1) {
                  return Column(children: [
                    VoteSelector(
                        agendaItem: item.value,
                        index: item.key,
                        onVote: onVote,
                        useDefault: useDefault),
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
                    agendaItem: item.value,
                    index: item.key,
                    onVote: onVote,
                    useDefault: useDefault);
              }).toList(),
            ),
          ),
        ));
  }
}
