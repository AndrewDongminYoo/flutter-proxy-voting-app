import 'dart:ui';

class Campaign {
  final String companyName;
  final String moderator;
  final String date;
  final String backgroundImg;
  final String logoImg;
  final Color color;

  Campaign({
    required this.companyName,
    required this.moderator,
    required this.date,
    required this.backgroundImg,
    required this.logoImg,
    required this.color,
  });
}