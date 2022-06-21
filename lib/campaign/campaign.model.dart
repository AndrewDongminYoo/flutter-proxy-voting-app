import 'package:flutter/material.dart';

import 'agenda.model.dart';

class Campaign {
  final String companyName;
  final String moderator;
  final String date;
  final String slogan;
  final String backgroundImg;
  final String logoImg;
  final String status;
  final Color color;
  final String youtubeUrl;
  final List<AgendaItem> agendaList;

  Campaign({
    required this.companyName,
    required this.moderator,
    required this.date,
    required this.slogan,
    required this.backgroundImg,
    required this.logoImg,
    required this.status,
    required this.color,
    required this.youtubeUrl,
    required this.agendaList,
  });
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
