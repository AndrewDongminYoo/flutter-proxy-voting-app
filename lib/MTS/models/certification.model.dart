import 'package:bside/lib.dart';

class RKSWCertItem implements IOBase {
  @override
  get json => {
        'issuerName': issuerName,
        'expiredImg': expiredImg,
        'expiredTime': expiredTime,
        'policy': policy,
        'subjectName': subjectName,
        'privateKey': privateKey,
        'publicKey': publicKey,
      };

  RKSWCertItem.from(Map<Object?, Object?> json) {
    issuerName = json['issuerName']!.toString();
    expiredImg = json['expiredImg']!.toString();
    expiredTime = json['expiredTime']!.toString();
    subjectName = json['subjectName']!.toString();
    privateKey = json['privateKey']!.toString();
    publicKey = json['publicKey']!.toString();
    policy = json['policy']!.toString();
    username = nRegex.firstMatch(subjectName)!.group(1)!;
    origin = fRegex
        .allMatches(subjectName)
        .firstWhere((element) =>
            element.group(1) != null && _banks.contains(element.group(1)!))
        .group(1)!;
    expireDate = DateTime.parse(expiredTime.replaceAll('.', ''));
  }

  late String issuerName;
  late String expiredImg;
  late String expiredTime;
  // 범용개인/은행개인/범용기업/은행기업/기업뱅킹
  // 신용카드/전자세금용/신용카드/증권보험
  late String policy;
  late String subjectName;
  late String username;
  // 금융결제원/한국전산원/증권전산/한국정보인증/전자인증/
  // 한국정보보호진흥원/한국무역정보통신/우리은행/
  // 한국정보인증/한국전자인증/한국증권전산/
  late String origin;
  late String privateKey;
  late String publicKey;
  late DateTime expireDate;
  String get objective => policy;
}

RegExp fRegex = RegExp(r'ou=([A-Za-z가-힣]+)');
RegExp nRegex = RegExp(r'cn=([A-Za-z가-힣0-9]+)');
Set _banks = {
  '한국은행',
  '중국은행',
  '산업은행',
  '산림조합',
  '기업은행',
  '대화은행',
  '국민은행',
  '우체국은행',
  'KEB하나',
  '수협은행',
  '수출입은행',
  '신용보증기금',
  '농협은행',
  '기술보증기금',
  '농협중앙회',
  '우리은행',
  '새마을금고',
  '신한은행',
  '케이뱅크',
  'SC제일은행',
  '카카오뱅크',
  '금융결제원',
  '유안타증권',
  '한국씨티은행',
  '현대증권',
  'KB투자증권',
  'KTB투자증권',
  '대구은행',
  '미래에셋대우',
  '부산은행',
  '삼성증권',
  '광주은행',
  '한국투자증권',
  '제주은행',
  'NH투자증권',
  '교보증권',
  '전북은행',
  '하이투자증권',
  '경남은행',
  'HMC투자증권',
  '키움증권',
  '이베스트투자증권',
  '신협은행',
  '에스케이증권',
  '대신증권',
  '메리츠종합금융증권',
  '상호저축은행',
  '한화투자증권',
  '하나금융투자',
  '모간스탠리',
  '신한금융투자',
  '동부증권',
  '유진투자증권',
  '도이치은행',
  '알비에스피엘씨',
  'JP모간체이스',
  '부국증권',
  '미즈호은행',
  '신영증권',
  '미쓰비시도쿄UFJ은행',
  '케이프투자증권',
  '펀드온라인코리아',
  '비엔피파리바',
  '미래에셋생명',
  '중국공상은행',
  '삼성생명'
      '금융결제원',
  '한국전산원',
  '증권전산',
  '한국정보인증',
  '전자인증',
  '한국정보보호진흥원',
  '한국무역정보통신',
  '한국전자인증',
  '한국증권전산'
};
