import 'dart:ui';

enum VoteType {
  none(-2),
  agree(-1),
  disagree(0),
  abstention(1);

  const VoteType(this.value);
  final int value;
}

class VoteButton {
  final Color borderColor;
  final Color bgColor;
  final Color textColor;
  final String label;
  final VoteType value;

  VoteButton(
      {required this.borderColor,
      required this.textColor,
      required this.bgColor,
      required this.label,
      required this.value});
}

class VoteAgenda {
  int id = -1;
  String company = "tli";
  String curStatus = "00000";
  int sharesNum = 0;
  int agenda1 = 0;
  int agenda2 = 0;
  int agenda3 = 0;
  int agenda4 = 0;

  VoteAgenda(
    this.id,
    this.company,
    this.curStatus,
    this.sharesNum,
    this.agenda1,
    this.agenda2,
    this.agenda3,
    this.agenda4,
  );

  VoteAgenda.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    company = json['company'] ?? '';
    curStatus = json['curStatus'] ?? '';
    sharesNum = json['sharesNum'];
    agenda1 = json['agenda1'];
    agenda2 = json['agenda2'];
    agenda3 = json['agenda3'];
    agenda4 = json['agenda4'];
  }
}
