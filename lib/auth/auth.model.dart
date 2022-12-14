import '../utils/exception.dart';

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
      n.startsWith(RegExp('[1-4]')) ? n : throw CustomException('wrong backId');
  set ci(String n) =>
      _ci = n.length == 88 ? n : throw CustomException('88bytes');
  set di(String n) =>
      _ci = n.length == 64 ? n : throw CustomException('64bytes');

  User(
    this.username,
    this.frontId,
    this._backId,
    this.telecom,
    this.phoneNumber,
  );

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

  int get sexCode => backId.startsWith(RegExp('[13]')) ? 1 : 2;

  User.fromJson(Map<String, dynamic> json) {
    _id = (json['id'] ?? -1) as int;
    username = (json['name'] ?? '') as String;
    frontId = (json['frontId'] ?? '') as String;
    backId = json['backId'] == null ? '1' : json['backId'].toString();
    telecom = (json['telecom'] ?? '') as String;
    phoneNumber = (json['phoneNumber'] ?? '') as String;
    address = (json['address'] ?? '') as String;
    _ci = (json['ci'] ?? '') as String;
    _di = (json['di'] ?? '') as String;
  }
}
