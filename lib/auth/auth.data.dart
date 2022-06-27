class User {
  int id = -1;
  String username = '홍길동';
  String frontId = '940101';
  String backId = '1';
  String telecom = 'SKT';
  String phoneNum = '01012341234';
  String ci = '';
  String di = '';
  String address = '';
  String _idCardAt = '';
  String _signatureAt = '';

  get signaturedAt => _signatureAt;
  get idCardUploadAt => _idCardAt;

  User(
    this.username,
    this.frontId,
    this.backId,
    this.telecom,
    this.phoneNum,
  );

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    username = json['name'] ?? '';
    frontId = json['frontId'] ?? '';
    backId = json['backId'] == null ? '1' : json['backId'].toString();
    telecom = json['telecom'] ?? '';
    phoneNum = json['phoneNumber'] ?? '';
    address = json['address'] ?? '';
    ci = json['ci'] ?? '';
    di = json['di'] ?? '';
    _signatureAt = json['signatureAt'] ?? '';
    _idCardAt = json['idCardAt'] ?? '';
  }
}
