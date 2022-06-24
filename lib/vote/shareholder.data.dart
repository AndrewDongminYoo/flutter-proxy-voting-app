class Shareholder {
  int id = -1;
  String username = '홍길동';
  String address = "";
  int sharesNum = 0;

  Shareholder(this.id, this.username, this.address, this.sharesNum);

  Shareholder.fromSharesJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    username = json['name'] ?? '';
    address = json['address'] ?? '';
    sharesNum = int.parse(json['sharesNum']);
  }

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
