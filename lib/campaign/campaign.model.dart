// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'agenda.model.dart';

class Campaign {
  final String koName;
  final String enName;
  final String moderator;
  final String date;
  final DateTime datetime;
  final String slogan;
  final String details;
  final String backgroundImg;
  final String logoImg;
  final Color color;
  final String dartUrl;
  final String youtubeUrl;
  final List<AgendaItem> agendaList;

  Campaign({
    required this.koName,
    required this.enName,
    required this.moderator,
    required this.date,
    required this.datetime,
    required this.slogan,
    required this.details,
    required this.backgroundImg,
    required this.logoImg,
    required this.color,
    required this.dartUrl,
    required this.youtubeUrl,
    required this.agendaList,
  });

  String get status => datetime.isAfter(DateTime.now()) ? '더보기' : '종료';
}

class ActionMenu {
  final IconData icon;
  final Color color;
  final String label;
  final void Function() onTap;

  ActionMenu({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });
}
