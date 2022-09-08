// 🎯 Dart imports:
import 'dart:math' show max;

// 🐦 Flutter imports:
import 'package:bside/lib.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart' show Get, GetNavigation;

// 🌎 Project imports:
import '../auth/auth.controller.dart';
import '../shared/shared.dart';
import '../theme.dart';
import 'vote.dart';

class VoteToAgendaPage extends StatefulWidget {
  const VoteToAgendaPage({Key? key}) : super(key: key);

  @override
  State<VoteToAgendaPage> createState() => _VoteToAgendaPageState();
}

class _VoteToAgendaPageState extends State<VoteToAgendaPage> {
  final AuthController _authCtrl = AuthController.get();
  final VoteController _voteCtrl = VoteController.get();

  Map<String, int> _marker = {
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
    if (Get.arguments == 'memory') {
      _voteResult = _voteWithMemory();
    } else if (Get.arguments == 'example') {
      _voteResult = _voteWithExample();
    } else {
      print('voteWithoutDefault');
    }
    super.initState();
  }

  _voteWithExample() {
    print('example');
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
    print(_voteResult.values.toString());
    return _voteResult;
  }

  _voteWithMemory() {
    print('memory');
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
    print(_voteResult.values.toString());
    return _voteResult;
  }

  _onNext() {
    _voteCtrl.postVoteResult(_authCtrl.user.id, _voteResult.values.toList());
    if (_voteCtrl.voteAgenda.signatureAt == null) {
      goVoteSign();
    } else if (_voteCtrl.voteAgenda.idCardAt == null) {
      goUploadIdCard(); //
    } else {
      jumpToVoteResult();
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
    final List<AgendaItem> agendaList = _voteCtrl.campaign.agendaList;
    final int agendaLength = agendaList.length;

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
