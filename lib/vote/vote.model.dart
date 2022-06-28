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

  VoteButton({
    required this.borderColor,
    required this.textColor,
    required this.bgColor,
    required this.label,
    required this.value,
  });
}

class VoteAgenda {
  int id = -1;
  String company = 'tli';
  String curStatus = '00000';
  int sharesNum = 0;
  int agenda1 = 0;
  int agenda2 = 0;
  int agenda3 = 0;
  int agenda4 = 0;
  DateTime? signatureAt;
  DateTime? idCardAt;
  DateTime? voteAt;

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

  DateTime parseDate(String time) {
    var dateTime = DateTime.parse(time);
    return dateTime.toLocal();
  }

  VoteAgenda.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      id = json['id'] ?? -1;
      company = json['company'] ?? '';
      curStatus = json['curStatus'] ?? '';
      sharesNum = json['sharesNum'] ?? 0;
      agenda1 = json['agenda1'] ?? 0;
      agenda2 = json['agenda2'] ?? 0;
      agenda3 = json['agenda3'] ?? 0;
      agenda4 = json['agenda4'] ?? 0;
      signatureAt =
          json['signatureAt'] != null ? parseDate(json['signatureAt']) : null;
      idCardAt = json['idCardAt'] != null ? parseDate(json['idCardAt']) : null;
      voteAt = json['voteAt'] != null ? parseDate(json['voteAt']) : null;
    }
  }
}
