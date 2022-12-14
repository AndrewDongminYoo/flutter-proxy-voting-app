// ๐ Project imports:
import 'package:intl/intl.dart' show DateFormat;

class RKSWCertItem {
  late String issuerName;
  late String expiredImg;
  late String certExpire;
  // ๋ฒ์ฉ๊ฐ์ธ/์ํ๊ฐ์ธ/๋ฒ์ฉ๊ธฐ์/์ํ๊ธฐ์/๊ธฐ์๋ฑํน
  // ์ ์ฉ์นด๋/์ ์์ธ๊ธ์ฉ/์ ์ฉ์นด๋/์ฆ๊ถ๋ณดํ
  late String policy;
  late String certName;
  late String username;
  // ๊ธ์ต๊ฒฐ์ ์/ํ๊ตญ์ ์ฐ์/์ฆ๊ถ์ ์ฐ/ํ๊ตญ์ ๋ณด์ธ์ฆ/์ ์์ธ์ฆ/
  // ํ๊ตญ์ ๋ณด๋ณดํธ์งํฅ์/ํ๊ตญ๋ฌด์ญ์ ๋ณดํต์ /์ฐ๋ฆฌ์ํ/
  // ํ๊ตญ์ ๋ณด์ธ์ฆ/ํ๊ตญ์ ์์ธ์ฆ/ํ๊ตญ์ฆ๊ถ์ ์ฐ/
  late String origin;
  late DateTime expireDate;

  RKSWCertItem.from(Map<Object?, Object?> json) {
    issuerName = toString(json['issuerName']);
    expiredImg = toString(json['expiredImg']);
    certExpire = toString(json['expiredTime']);
    certName = toString(json['subjectName']);
    policy = toString(json['policy']);
    username = nRegex.firstMatch(certName)!.group(1)!;
    origin = fRegex
        .allMatches(certName)
        .firstWhere((element) =>
            element.group(1) != null && _banks.contains(element.group(1)!))
        .group(1)!;
    expireDate = DateTime.parse(certExpire.replaceAll('.', ''));
  }

  Map<String, String> get json => {
        '์ธ์ฆ์์ด๋ฆ': certName,
        '์ ํจ๊ธฐ๊ฐ': formatter.format(expireDate),
        '๋ฐ๊ธ๊ธฐ๊ด': origin,
        '์ฉ๋๊ตฌ๋ถ': policy,
        '์ธ์ฆ๊ธฐ๊ด': issuerName,
        '๋ฐ๊ธ์': username,
      };
}

String toString(Object? obj) {
  String str = obj.toString();
  if (str == 'null') {
    return '';
  } else {
    return str;
  }
}

DateFormat formatter = DateFormat('yyyy๋ MM์ dd์ผ');
RegExp fRegex = RegExp(r'ou=([A-Za-z๊ฐ-ํฃ]+)');
RegExp nRegex = RegExp(r'cn=([A-Za-z๊ฐ-ํฃ0-9]+)');
Set<String> _banks = {
  'ํ๊ตญ์ํ',
  '์ค๊ตญ์ํ',
  '์ฐ์์ํ',
  '์ฐ๋ฆผ์กฐํฉ',
  '๊ธฐ์์ํ',
  '๋ํ์ํ',
  '๊ตญ๋ฏผ์ํ',
  '์ฐ์ฒด๊ตญ์ํ',
  'KEBํ๋',
  '์ํ์ํ',
  '์์ถ์์ํ',
  '์ ์ฉ๋ณด์ฆ๊ธฐ๊ธ',
  '๋ํ์ํ',
  '๊ธฐ์ ๋ณด์ฆ๊ธฐ๊ธ',
  '๋ํ์ค์ํ',
  '์ฐ๋ฆฌ์ํ',
  '์๋ง์๊ธ๊ณ ',
  '์ ํ์ํ',
  '์ผ์ด๋ฑํฌ',
  'SC์ ์ผ์ํ',
  '์นด์นด์ค๋ฑํฌ',
  '๊ธ์ต๊ฒฐ์ ์',
  '์ ์ํ์ฆ๊ถ',
  'ํ๊ตญ์จํฐ์ํ',
  'ํ๋์ฆ๊ถ',
  'KBํฌ์์ฆ๊ถ',
  'KTBํฌ์์ฆ๊ถ',
  '๋๊ตฌ์ํ',
  '๋ฏธ๋์์๋์ฐ',
  '๋ถ์ฐ์ํ',
  '์ผ์ฑ์ฆ๊ถ',
  '๊ด์ฃผ์ํ',
  'ํ๊ตญํฌ์์ฆ๊ถ',
  '์ ์ฃผ์ํ',
  'NHํฌ์์ฆ๊ถ',
  '๊ต๋ณด์ฆ๊ถ',
  '์ ๋ถ์ํ',
  'ํ์ดํฌ์์ฆ๊ถ',
  '๊ฒฝ๋จ์ํ',
  'HMCํฌ์์ฆ๊ถ',
  'ํค์์ฆ๊ถ',
  '์ด๋ฒ ์คํธํฌ์์ฆ๊ถ',
  '์ ํ์ํ',
  '์์ค์ผ์ด์ฆ๊ถ',
  '๋์ ์ฆ๊ถ',
  '๋ฉ๋ฆฌ์ธ ์ขํฉ๊ธ์ต์ฆ๊ถ',
  '์ํธ์ ์ถ์ํ',
  'ํํํฌ์์ฆ๊ถ',
  'ํ๋๊ธ์ตํฌ์',
  '๋ชจ๊ฐ์คํ ๋ฆฌ',
  '์ ํ๊ธ์ตํฌ์',
  '๋๋ถ์ฆ๊ถ',
  '์ ์งํฌ์์ฆ๊ถ',
  '๋์ด์น์ํ',
  '์๋น์์คํผ์์จ',
  'JP๋ชจ๊ฐ์ฒด์ด์ค',
  '๋ถ๊ตญ์ฆ๊ถ',
  '๋ฏธ์ฆํธ์ํ',
  '์ ์์ฆ๊ถ',
  '๋ฏธ์ฐ๋น์๋์ฟUFJ์ํ',
  '์ผ์ดํํฌ์์ฆ๊ถ',
  'ํ๋์จ๋ผ์ธ์ฝ๋ฆฌ์',
  '๋น์ํผํ๋ฆฌ๋ฐ',
  '๋ฏธ๋์์์๋ช',
  '์ค๊ตญ๊ณต์์ํ',
  '์ผ์ฑ์๋ช',
  'ํ๊ตญ์ ์ฐ์',
  '์ฆ๊ถ์ ์ฐ',
  'ํ๊ตญ์ ๋ณด์ธ์ฆ',
  '์ ์์ธ์ฆ',
  'ํ๊ตญ์ ๋ณด๋ณดํธ์งํฅ์',
  'ํ๊ตญ๋ฌด์ญ์ ๋ณดํต์ ',
  'ํ๊ตญ์ ์์ธ์ฆ',
  'ํ๊ตญ์ฆ๊ถ์ ์ฐ'
};
