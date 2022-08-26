class CustomModule {
  CustomModule({
    required this.firmName,
    this.korName = '',
    this.logoImage = '',
  });

  late String firmName;
  late String korName;
  late String logoImage;
  late bool canLoginWithID;
  late bool isException;

  @override
  String toString() => firmName;

  CustomModule.from(Map map) {
    firmName = map['module'] ?? '';
    korName = map['name'] ?? '';
    logoImage = map['image'] ?? '';
    canLoginWithID = map['아이디로그인여부'] ?? true;
    isException = map['계좌번호이상여부'] ?? false;
  }
}
