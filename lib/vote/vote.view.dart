// 🎯 Dart imports:
import 'dart:math' show max;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../shared/shared.dart';
import '../theme.dart';
import 'vote.dart';

class VoteAgendaPage extends StatefulWidget {
  const VoteAgendaPage({Key? key}) : super(key: key);

  @override
  State<VoteAgendaPage> createState() => _VoteAgendaPageState();
}

class _VoteAgendaPageState extends State<VoteAgendaPage> {
  final AuthController _authCtrl = AuthController.get();
  final VoteController _voteCtrl = VoteController.get();

  var _marker = <String, int>{
    'cur': 0,
    'latest': 0,
  };
  Map<int, VoteType> _voteResult = {
    0: VoteType.none,
    1: VoteType.none,
    2: VoteType.none,
    3: VoteType.none,
  };

  @override
  initState() {
    if (Get.arguments == 'voteWithLastMemory') {
      _voteResult = _voteWithMemory();
    } else if (Get.arguments == 'voteWithExample') {
      _voteResult = _voteWithExample();
    } else {
      debugPrint('voteWithoutDefault');
    }
    super.initState();
  }

  _voteWithExample() {
    debugPrint('voteWithExample');
    setState(() {
      _voteResult[0] = VoteType.disagree;
      _voteResult[1] = VoteType.agree;
      _voteResult[2] = VoteType.agree;
      _voteResult[3] = VoteType.disagree;
      _marker = {
        'cur': 4,
        'latest': 4,
      };
    });
    debugPrint(_voteResult.values.toString());
    return _voteResult;
  }

  _voteWithMemory() {
    debugPrint('voteWithLastMemory');
    setState(() {
      VoteAgenda agenda = _voteCtrl.voteAgenda;
      _voteResult[0] = agenda.agenda1.vote;
      _voteResult[1] = agenda.agenda2.vote;
      _voteResult[2] = agenda.agenda3.vote;
      _voteResult[3] = agenda.agenda4.vote;
      _marker = {
        'cur': 4,
        'latest': 4,
      };
    });
    debugPrint(_voteResult.values.toString());
    return _voteResult;
  }

  _onNext() {
    _voteCtrl.postVoteResult(_authCtrl.user.id, _voteResult.values.toList());
    if (_voteCtrl.voteAgenda.signatureAt == null) {
      goToSignature();
    } else if (_voteCtrl.voteAgenda.idCardAt == null) {
      goToIDCard(); //
    } else {
      jumpToResult();
    }
  }

  _onVote(int index, VoteType result) {
    setState(() {
      _voteResult[index] = result;
      _marker = {
        'cur': index + 1,
        'latest': max(_marker['latest']!, index + 1),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final agendaList = _voteCtrl.campaign.agendaList;
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
                if (item.key > _marker['latest']!) {
                  return Container();
                } else if (item.key == agendaLength - 1) {
                  return Column(
                    children: [
                      VoteSelector(
                        agendaItem: item.value,
                        index: item.key,
                        onVote: _onVote,
                        initialValue: _voteResult[item.key]!,
                      ),
                      _marker['latest']! < agendaLength
                          ? Container()
                          : Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0, 20.0, 0, 100.0),
                              child: CustomButton(
                                label: '위임확인',
                                onPressed: _onNext,
                                width: CustomW.w4,
                              ),
                            ),
                    ],
                  );
                }
                return VoteSelector(
                  agendaItem: item.value,
                  index: item.key,
                  onVote: _onVote,
                  initialValue: _voteResult[item.key]!,
                );
              },
            ).toList(),
          ),
        ),
      ),
    );
  }
}
