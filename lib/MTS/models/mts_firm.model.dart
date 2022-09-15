// 🌎 Project imports:
import '../mts.dart';

class CustomModule {
  late String firmName;
  late String korName;
  late String logoImage;
  late bool canLoginWithID;
  late bool isException;

  @override
  String toString() => firmName;

  CustomModule.from(Map<String, dynamic> map) {
    firmName = (map['module'] ?? '') as String;
    korName = (map['name'] ?? '') as String;
    logoImage = (map['image'] ?? '') as String;
    canLoginWithID = (map['아이디로그인여부'] ?? true) as bool;
    isException = (map['계좌번호이상여부'] ?? false) as bool;
  }

  static CustomModule? get(String name) => stockTradingFirms
      .firstWhere((CustomModule firm) => firm.firmName == name);
}
