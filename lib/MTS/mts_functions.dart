// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'widgets/formatters.dart';

enum Module {
  NHqv,
  Daishin,
  Samsung,
  Myasset,
  Hanaw,
  Kyobo,
  Imeritz,
  Cape,
  Ibk,
  Woori,
  Hi,
  Hmc,
  Namuh,
  Foss,
  SKs,
  Mirae,
  Shinhan,
  Kiwoom,
  KB,
  DBfi,
  Hanwhawm,
  Eugenefn,
  Ktb,
  EBest,
  Korea,
  Shinyoung,
  Creon,
}

enum Action {
  logIn, // '로그인'
  stockAccount, // '증권보유계좌조회'
  allAccount, // '전계좌조회'
  detailAccount, // '계좌상세조회'
  transaction, // '거래내역조회'
  logOut, // '로그아웃'
}

enum Service {
  stockFirm, // '증권서비스'
  homeTax, // '홈택스'
}

final customModule = {
  Module.NHqv: 'secNHqv',
  Module.Daishin: 'secDaishin',
  Module.Samsung: 'secSamsung',
  Module.Myasset: 'secMyasset',
  Module.Hanaw: 'secHanaw',
  Module.Kyobo: 'secKyobo',
  Module.Imeritz: 'secImeritz',
  Module.Cape: 'secCape',
  Module.Ibk: 'secIbk',
  Module.Woori: 'secWoori',
  Module.Hi: 'secHi',
  Module.Hmc: 'secHmc',
  Module.Namuh: 'secNamuh',
  Module.Foss: 'secFoss',
  Module.SKs: 'secSKs',
  Module.Mirae: 'secMirae',
  Module.Shinhan: 'secShinhan',
  Module.Kiwoom: 'secKiwoom',
  Module.KB: 'secKB',
  Module.DBfi: 'secDBfi',
  Module.Hanwhawm: 'secHanwhawm',
  Module.Eugenefn: 'secEugenefn',
  Module.Ktb: 'secKtb',
  Module.EBest: 'secEBest',
  Module.Korea: 'secKorea',
  Module.Shinyoung: 'secShinyoung',
  Module.Creon: 'secCreon',
};
final customAction = {
  Action.logIn: '로그인',
  Action.stockAccount: '증권보유계좌조회',
  Action.allAccount: '전계좌조회',
  Action.detailAccount: '계좌상세조회',
  Action.transaction: '거래내역조회',
  Action.logOut: '로그아웃',
};
final customService = {
  Service.stockFirm: '증권서비스',
  Service.homeTax: '홈택스',
};

abstract class RequestResponse {
  late Service service;
  late Module module;
  late Action action;
  late dynamic input;

  String makeJSON() {
    return jsonEncode({
      'Class': service.toString(),
      'Module': module.toString(),
      'Job': action.toString(),
      'Input': input,
    });
  }
}

commonBody(
  String module,
  String action,
) =>
    {
      'Class': '증권서비스',
      'Module': module,
      'Job': action,
      'Input': {},
    };

login(
  String module,
  String username,
  String password, {
  bool idLogin = true,
}) {
  return {
    ...commonBody(module, '로그인'),
    'Input': {
      '로그인방식': idLogin ? 'ID' : 'CERT', // CERT: 인증서, ID: 아이디
      '사용자아이디': username, // required // IBK, KTB 필수 입력
      '사용자비밀번호': password, // required // IBK, KTB 필수 입력
      '인증서': {}, // 있을 경우 "이름", "만료일자", "비밀번호" 키로 입력
    },
  };
}

queryStocks(String module) => commonBody(module, '증권보유계좌조회');

queryAll(
  String module,
  String password, {
  String code = '',
}) {
  return {
    ...commonBody(module, '전계좌조회'),
    'Input': {
      '사용자비밀번호': password, // 키움 증권만 사용
      '조회구분': code, // "S": 키움 간편조회, 메리츠 전체계좌, 삼성 계좌잔고
    }, // 없음: 키움 일반조회, 메리츠 계좌평가, 삼성 종합잔고평가
  }; // "D": 대신,크레온 종합번호+계좌번호, 없음: 일반조회
}

queryDetail(
  String module,
  String accountNum,
  String password,
  String code,
  String unit,
) {
  return {
    ...commonBody(module, '계좌상세조회'), // 상세잔고조회
    'Input': {
      '계좌번호': accountNum,
      '계좌비밀번호': password, // 입력 안해도 되지만 안하면 구매종목 안나옴.
      '조회구분': code, // 삼성 "K": 외화만, 없음: 기본조회
      '통화코드출력여부': unit, // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력
    },
  };
}

queryTrades(
  String module,
  String accountNum,
  String passNum, {
  String type = '',
  String code = '1',
  String start = '',
  String end = '',
  String ext = '',
}) {
  if (!['000', '001', '002', ''].contains(ext)) return;
  if (!['01', '02', '05', ''].contains(type)) return;
  if (!['1', '2', 'D'].contains(code)) return;
  if (start.isEmpty) start = sixAgo(start);
  if (end.isEmpty) end = today();
  return {
    ...commonBody(module, '거래내역조회'), // 상세거래내역조회
    'Input': {
      '상품구분': '', // "01"위탁 "02"펀드 "05"CMA
      '조회구분': code, // "1"종합거래내역 "2"입출금내역 "D"종합거래내역 간단히
      '계좌번호': accountNum,
      '계좌비밀번호': passNum,
      '계좌번호확장': ext, // 하나증권만 사용("000"~"002")
      '조회시작일': start, // YYYYMMDD
      '조회종료일': end, // YYYYMMDD
    },
  };
}

logOut(String module) => commonBody(module, '로그아웃');
