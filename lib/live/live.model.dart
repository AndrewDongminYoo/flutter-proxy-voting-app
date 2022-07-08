// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveAgenda {
  int index = 0;
  String title = '';
  String subTitle = '';
  int status = 0;
  int forCompany = 0;
  int forAlign = 0;
  int forOffline = 0;
  int againstCompany = 0;
  int againstAlign = 0;
  int againstOffline = 0;
  int reactionHappy = 0;
  int reactionAngry = 0;
  int reactionLove = 0;
  int reactionSad = 0;
  int reactionSurprise = 0;

  LiveAgenda.fromJson(DocumentSnapshot json) {
    title = json['title'];
    subTitle = json['subTitle'];
    status = json['status'];
    forCompany = json['for']['company'];
    forAlign = json['for']['align'];
    forOffline = json['for']['offline'];
    againstCompany = json['against']['company'];
    againstAlign = json['against']['align'];
    againstOffline = json['against']['offline'];
    reactionHappy = json['reaction']['happy'];
    reactionAngry = json['reaction']['angry'];
    reactionLove = json['reaction']['love'];
    reactionSad = json['reaction']['sad'];
    reactionSurprise = json['reaction']['surprise'];
  }

  String getStatus() {
    switch (status) {
      case -1:
        return '안건 철회';
      case 1:
        return '집계 중';
      case 2:
        return '가결';
      case 3:
        return '부결';
      default:
        return '집계 전';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case -1:
        return const Color(0x0ff00000);
      case 1:
        return const Color(0xFFEB0C1F);
      case 2:
        return const Color(0x0ff00000);
      case 3:
        return const Color(0x0ff00000);
      case 4:
        return const Color(0xFF572E66);
      default:
        return const Color(0x0ff00000);
    }
  }

  int get totalFor => forCompany + forAlign + forOffline;
  int get totalAgainst => againstCompany + againstAlign + againstOffline;
  int get totalCount => totalFor + totalAgainst;
  double get forPercentage => totalCount == 0 ? 0 : totalFor / totalCount;
  double get againstPercentage =>
      totalCount == 0 ? 0 : totalAgainst / totalCount;
  int operator [](prop) {
    switch (prop) {
      case 'happy':
        return reactionHappy;
      case 'sad':
        return reactionSad;
      case 'angry':
        return reactionAngry;
      case 'surprise':
        return reactionSurprise;
      case 'love':
      default:
        return reactionLove;
    }
  }
}

class LiveLounge {
  int preVoteStatus = 0;
  int preVoteOnline = 0;
  int preVoteCompany = 0;
  int preVoteAlign = 0;
  int totalStatus = 0;
  int agendaCount = 0;
  Timestamp updatedAt = Timestamp.now();

  LiveLounge.fromJson(DocumentSnapshot json) {
    preVoteStatus = json['preVoteStatus'];
    preVoteOnline = json['preVoteOnline'];
    preVoteCompany = json['preVoteCompany'];
    preVoteAlign = json['preVoteAlign'];
    totalStatus = json['totalStatus'];
    agendaCount = json['agendaCount'];
    updatedAt = json['updatedAt'];
  }

  int get totalVote => preVoteOnline + preVoteAlign + preVoteCompany;

  String getTotalStatus() {
    switch (totalStatus) {
      case 1:
        return '사전 표결 진행중';
      case 2:
        return '종료';
      default:
        return '진행 전';
    }
  }

  String getPreVoteStatus() {
    switch (preVoteStatus) {
      case 1:
        return '집계 중';
      case 2:
        return '집계 완료';
      default:
        return '집계 전';
    }
  }

  Color getTotalStatusColor() {
    return getColor(totalStatus);
  }

  Color getPreVoteColor() {
    return getColor(preVoteStatus);
  }

  Color getColor(int status) {
    switch (status) {
      case 1:
        return const Color(0xFF572E66);
      case 2:
        return const Color(0x0ff00000);
      default:
        return const Color(0xFF572E66);
    }
  }
}
