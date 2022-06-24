class User {
  int id = -1;
  // identification - user input
  String username = '홍길동';
  String frontId = '940101';
  String backId = '1';
  String telecom = 'SKT';
  String phoneNum = '01012341234';
  bool marketing = false;
  bool notification = false;
  String deviceName = '';
  String ci = '';
  String di = '';
  String address = "";
  String detailAddress = "";

  User(this.username, this.frontId, this.backId, this.telecom, this.phoneNum);

  // User.fromJson(Map<String, dynamic> json) {
  //   id = json['agenda']['id'] ?? -1;
  //   company = json['agenda']['company'] ?? '';
  //   email = json['agenda']['email'] ?? '';
  //   curStep = VoteProxyStage.values[json['agenda']['curStep'] ?? 0];

  //   username = json['agenda']['username'] ?? '';
  //   frontId = json['agenda']['frontId'] ?? '';
  //   backId = json['agenda']['backId'] == null
  //       ? '1'
  //       : json['agenda']['backId'].toString();
  //   telecom = json['agenda']['telecom'] ?? '';
  //   phoneNum = json['agenda']['phoneNum'] ?? '';
  //   sharesNum = json['agenda']['sharesNum'] ?? 0;
  //   deviceName = json['agenda']['deviceName'] ?? '';
  //   ci = json['agenda']['ci'] ?? '';
  //   di = json['agenda']['di'] ?? '';
  //   address = json['agenda']['address'] ?? '';

  //   marketing = json['agenda']['marketing'] ?? false;
  //   notification = json['agenda']['notification'] ?? false;
  // }
}