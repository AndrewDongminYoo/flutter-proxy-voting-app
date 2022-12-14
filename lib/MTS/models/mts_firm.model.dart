// ๐ Project imports:
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
    canLoginWithID = (map['์์ด๋๋ก๊ทธ์ธ์ฌ๋ถ'] ?? true) as bool;
    isException = (map['๊ณ์ข๋ฒํธ์ด์์ฌ๋ถ'] ?? false) as bool;
  }

  static CustomModule? get(String name) => stockTradingFirms
      .firstWhere((CustomModule firm) => firm.firmName == name);
}
