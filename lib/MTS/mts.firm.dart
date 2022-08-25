class CustomModule {
  CustomModule({
    required this.firmName,
    this.korName = '',
    this.logoImage = '',
  });

  late String firmName;
  late String korName;
  late String logoImage;
  @override
  String toString() => firmName;

  CustomModule.from(Map map) {
    firmName = map['module'];
    korName = map['name'];
    logoImage = map['image'];
  }
}
