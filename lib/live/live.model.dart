// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveAgenda {
  int index = 0;
  String title = '';
  String subTitle = '';
  int status = 0;
  int _forCompany = 0;
  int _forAlign = 0;
  int _forOffline = 0;
  int _againstCompany = 0;
  int _againstAlign = 0;
  int _againstOffline = 0;
  int reactionHappy = 0;
  int reactionAngry = 0;
  int reactionLove = 0;
  int reactionSad = 0;
  int reactionSurprise = 0;

  LiveAgenda.fromJson(DocumentSnapshot json) {
    title = json['title'];
    subTitle = json['subTitle'];
    status = json['status'];
    _forCompany = json['for']['company'];
    _forAlign = json['for']['align'];
    _forOffline = json['for']['offline'];
    _againstCompany = json['against']['company'];
    _againstAlign = json['against']['align'];
    _againstOffline = json['against']['offline'];
    reactionHappy = json['reaction']['happy'];
    reactionAngry = json['reaction']['angry'];
    reactionLove = json['reaction']['love'];
    reactionSad = json['reaction']['sad'];
    reactionSurprise = json['reaction']['surprise'];
  }

  get statusString {
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

  get statusColor {
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

  int get totalFor => _forCompany + _forAlign + _forOffline;
  int get totalAgainst => _againstCompany + _againstAlign + _againstOffline;
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
  int _preVoteStatus = 0;
  int _preVoteOnline = 0;
  int preVoteCompany = 0;
  int _preVoteAlign = 0;
  int _totalStatus = 0;
  Timestamp updatedAt = Timestamp.now();

  LiveLounge.fromJson(DocumentSnapshot json) {
    _preVoteStatus = json['preVoteStatus'];
    _preVoteOnline = json['preVoteOnline'];
    preVoteCompany = json['preVoteCompany'];
    _preVoteAlign = json['preVoteAlign'];
    _totalStatus = json['totalStatus'];
    updatedAt = json['updatedAt'];
  }

  int get totalVote => _preVoteOnline + _preVoteAlign + preVoteCompany;

  get totalStatus {
    switch (_totalStatus) {
      case 1:
        return '사전 표결 진행중';
      case 2:
        return '종료';
      default:
        return '진행 전';
    }
  }

  get preVoteStatus {
    switch (_preVoteStatus) {
      case 1:
        return '집계 중';
      case 2:
        return '집계 완료';
      default:
        return '집계 전';
    }
  }

  get totalStatusColor {
    return toColor(_totalStatus);
  }

  get preVoteColor {
    return toColor(_preVoteStatus);
  }

  Color toColor(int status) {
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
