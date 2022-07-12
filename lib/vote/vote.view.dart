// 🎯 Dart imports:
import 'dart:math' show max;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import '../theme.dart';
import '../shared/shared.dart';
import '../auth/auth.controller.dart';
import 'vote.dart';
import 'widget/vote_selector.dart';

class VoteAgendaPage extends StatefulWidget {
  const VoteAgendaPage({Key? key}) : super(key: key);

  @override
  State<VoteAgendaPage> createState() => _VoteAgendaPageState();
}

class _VoteAgendaPageState extends State<VoteAgendaPage> {
  AuthController authCtrl = Get.isRegistered<AuthController>()
      ? Get.find()
      : Get.put(AuthController());
  VoteController voteCtrl = Get.isRegistered<VoteController>()
      ? Get.find()
      : Get.put(VoteController());

  var marker = <String, int>{
    'cur': 0,
    'latest': 0,
  };
  Map<int, VoteType> voteResult = {
    0: VoteType.none,
    1: VoteType.none,
    2: VoteType.none,
    3: VoteType.none,
  };

  @override
  initState() {
    if (Get.arguments == 'voteWithLastMemory') {
      voteResult = voteWithMemory();
    } else if (Get.arguments == 'voteWithExample') {
      voteResult = voteWithExample();
    } else {
      debugPrint('voteWithoutDefault');
    }
    super.initState();
  }

  voteWithExample() {
    debugPrint('voteWithExample');
    setState(() {
      voteResult[0] = VoteType.disagree;
      voteResult[1] = VoteType.agree;
      voteResult[2] = VoteType.agree;
      voteResult[3] = VoteType.disagree;
      marker = {
        'cur': 4,
        'latest': 4,
      };
    });
    debugPrint(voteResult.values.toString());
    return voteResult;
  }

  voteWithMemory() {
    debugPrint('voteWithLastMemory');
    setState(() {
      VoteAgenda agenda = voteCtrl.voteAgenda;
      voteResult[0] = agenda.agenda1.vote;
      voteResult[1] = agenda.agenda2.vote;
      voteResult[2] = agenda.agenda3.vote;
      voteResult[3] = agenda.agenda4.vote;
      marker = {
        'cur': 4,
        'latest': 4,
      };
    });
    debugPrint(voteResult.values.toString());
    return voteResult;
  }

  onNext() {
    voteCtrl.postVoteResult(authCtrl.user.id, voteResult.values.toList());
    if (voteCtrl.voteAgenda.signatureAt == null) {
      goToSignature();
    } else if (voteCtrl.voteAgenda.idCardAt == null) {
      goToIDCard(); //
    } else {
      jumpToResult();
    }
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
    final agendaList = voteCtrl.campaign.agendaList;
    final agendaLength = agendaList.length;

    return Scaffold(
      appBar: CustomAppBar(text: '의결수 확인'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: agendaList.asMap().entries.map(
              (item) {
                // Do not show the next item
                if (item.key > marker['latest']!) {
                  return Container();
                } else if (item.key == agendaLength - 1) {
                  return Column(
                    children: [
                      VoteSelector(
                        agendaItem: item.value,
                        index: item.key,
                        onVote: onVote,
                        initialValue: voteResult[item.key]!,
                      ),
                      marker['latest']! < agendaLength
                          ? Container()
                          : Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 20.0, 0, 100.0),
                              child: CustomButton(
                                label: '위임확인',
                                onPressed: onNext,
                                width: CustomW.w4,
                              ),
                            ),
                    ],
                  );
                }
                return VoteSelector(
                  agendaItem: item.value,
                  index: item.key,
                  onVote: onVote,
                  initialValue: voteResult[item.key]!,
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
