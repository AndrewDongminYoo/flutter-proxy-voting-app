class User {
  int id = -1;
  String username = '홍길동';
  String frontId = '940101';
  String backId = '1';
  String telecom = 'SKT';
  String phoneNumber = '01012341234';
  String ci = '';
  String di = '';
  String address = '';

  User(
    this.username,
    this.frontId,
    this.backId,
    this.telecom,
    this.phoneNumber,
  );

  /// 'SKT':01, 'KT':02, 'LG U+':03, 'SKT 알뜰폰':04, 'KT 알뜰폰':05, 'LG U+ 알뜰폰':06
  String get telecomCode {
    switch (telecom) {
      case 'SKT':
        return '01';
      case 'KT':
        return '02';
      case 'LG U+':
        return '03';
      case 'SKT 알뜰폰':
        return '04';
      case 'KT 알뜰폰':
        return '05';
      case 'LG U+ 알뜰폰':
        return '06';
      default:
        return '00';
    }
  }

  String get regist =>
      frontId.startsWith(RegExp('[01]')) ? '20$frontId' : '19$frontId';

  /// sex: 남: 1, 여: 2
  int get sexCode => backId.startsWith(RegExp('[13]')) ? 1 : 2;

  User.fromJson(Map<String, dynamic>? json) {
    if (json != null) {
      id = json['id'] ?? -1;
      username = json['name'] ?? '';
      frontId = json['frontId'] ?? '';
      backId = json['backId'] == null ? '1' : json['backId'].toString();
      telecom = json['telecom'] ?? '';
      phoneNumber = json['phoneNumber'] ?? '';
      address = json['address'] ?? '';
      ci = json['ci'] ?? '';
      di = json['di'] ?? '';
    }
  }
}
