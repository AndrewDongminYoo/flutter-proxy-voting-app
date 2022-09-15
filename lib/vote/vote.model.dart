// 🎯 Dart imports:
import 'dart:ui' show Color;

// 🌎 Project imports:
import '../theme.dart';

enum VoteType {
  none(-2),
  agree(-1),
  disagree(0),
  abstention(1);

  const VoteType(this.value);
  final int value;
}

extension IntToType on int {
  VoteType get vote {
    switch (this) {
      case 1:
        return VoteType.agree;
      case 0:
        return VoteType.abstention;
      case -1:
        return VoteType.disagree;
      default:
        return VoteType.none;
    }
  }
}

class VoteButton {
  final Color borderColor;
  final Color bgColor;
  final ColorType textColor;
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
  DateTime? backIdAt;

  VoteAgenda({
    required int id,
    required String company,
    required String curStatus,
    required int sharesNum,
    required int agenda1,
    required int agenda2,
    required int agenda3,
    required int agenda4,
    DateTime? signatureAt,
    DateTime? idCardAt,
    DateTime? voteAt,
    DateTime? backIdAt,
  });

  factory VoteAgenda.fromJson(Map<String, dynamic> json) {
    return VoteAgenda(
      id: (json['id'] ?? -1) as int,
      company: (json['company'] ?? '') as String,
      curStatus: (json['curStatus'] ?? '') as String,
      sharesNum: (json['sharesNum'] ?? 0) as int,
      agenda1: (json['agenda1'] ?? 0) as int,
      agenda2: (json['agenda2'] ?? 0) as int,
      agenda3: (json['agenda3'] ?? 0) as int,
      agenda4: (json['agenda4'] ?? 0) as int,
      signatureAt: json['signatureAt'] != null
          ? parseDate(json['signatureAt'] as String)
          : null,
      idCardAt: json['idCardAt'] != null
          ? parseDate(json['idCardAt'] as String)
          : null,
      voteAt:
          json['voteAt'] != null ? parseDate(json['voteAt'] as String) : null,
      backIdAt: json['backIdAt'] != null
          ? parseDate(json['backIdAt'] as String)
          : null,
    );
  }
}

DateTime parseDate(String time) {
  DateTime dateTime = DateTime.parse(time);
  return dateTime.toLocal();
}

class Shareholder {
  int id = -1;
  String username = '홍길동';
  String address = '';
  int sharesNum = 0;
  String company = 'tli';

  Shareholder({
    id,
    username,
    address,
    sharesNum,
    company,
  });

  factory Shareholder.fromJson(Map<String, dynamic> json) {
    return Shareholder(
      id: json['id'] ?? -1,
      username: json['name'] ?? '',
      address: json['address'] ?? '',
      sharesNum: json['sharesNum'] != null
          ? int.parse(json['sharesNum'] as String)
          : 0,
      company: json['company'] ?? 'tli',
    );
  }
}
