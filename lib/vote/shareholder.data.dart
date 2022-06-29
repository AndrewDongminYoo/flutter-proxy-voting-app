class Shareholder {
  int id = -1;
  String username = '홍길동';
  String address = '';
  int sharesNum = 0;
  String company = 'tli';

  Shareholder(this.id, this.username, this.address, this.sharesNum);

  Shareholder.fromSharesJson(Map<String, dynamic> json) {
    id = json['id'] ?? -1;
    username = json['name'] ?? '';
    address = json['address'] ?? '';
    sharesNum = json['sharesNum'] != null ? int.parse(json['sharesNum']) : 0;
    company = json['company'] ?? 'tli';
  }
}
