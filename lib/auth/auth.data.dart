class User {
  int _id = -1;
  String username = '홍길동';
  String frontId = '940101';
  String _backId = '1';
  String telecom = 'SKT';
  String phoneNumber = '01012341234';
  String _ci = '';
  String _di = '';
  String address = '';

  int get id => _id;
  String get backId => _backId;
  String get ci => _ci;
  String get di => _di;
  set backId(String n) => _backId =
      n.startsWith(RegExp('[1-4]')) ? n : throw Exception('wrong backId');
  set ci(String n) => _ci = n.length == 88 ? n : throw Exception('88bytes');
  set di(String n) => _ci = n.length == 64 ? n : throw Exception('64bytes');

  User(
    this.username,
    this.frontId,
    this._backId,
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
      _id = json['id'] ?? -1;
      username = json['name'] ?? '';
      frontId = json['frontId'] ?? '';
      backId = json['backId'] == null ? '1' : json['backId'].toString();
      telecom = json['telecom'] ?? '';
      phoneNumber = json['phoneNumber'] ?? '';
      address = json['address'] ?? '';
      _ci = json['ci'] ?? '';
      _di = json['di'] ?? '';
    }
  }
}
