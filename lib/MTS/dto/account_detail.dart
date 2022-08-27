import 'package:flutter/material.dart';

import '../mts.dart';

class AccountDetail implements MTSInterface {
  AccountDetail(
    this.module, {
    required this.accountNum,
    required this.accountPin,
    required this.queryCode,
    required this.showISO,
  });

  final CustomModule module; // 금융사
  final String job = '계좌상세조회';
  final String accountNum; // 계좌번호
  final String accountPin; // 계좌비밀번호 // 입력 안해도 되지만 안하면 구매종목 안나옴.
  final String queryCode; // 조회구분 // 삼성 "K": 외화만, 없음: 기본조회
  final String showISO; // 통화코드출력여부 // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력

  @override
  CustomRequest get json {
    if (['', 'K'].contains(queryCode)) {
      if (['', '2'].contains(showISO)) {
        return makeFunction(
          module,
          job,
          accountNum: accountNum,
          accountPin: accountPin,
          queryCode: queryCode,
          showISO: showISO,
        )!;
      }
    }
    throw Exception('조회구분코드를 확인해 주세요.');
  }

  @override
  Future<CustomResponse> fetch() async {
    return await json.fetch();
  }

  @override
  Future<Set<String>> post() async {
    CustomResponse response = await fetch();
    await response.fetch();
    Set<String> accounts = {};
    addResult('====================================');
    dynamic jobResult = response.Output.Result.accountDetail;
    switch (jobResult.runtimeType) {
      case List:
        for (Map<String, dynamic> element in jobResult) {
          element.forEach((key, value) {
            if (element['상품유형코드'] == '01' || element['상품명']!.contains('주식')) {
              if (key == '계좌번호') {
                if (!accounts.contains(value)) {
                  accounts.add(value);
                  addResult('$key: ${hypen(value)}');
                }
              } else if (key.endsWith('일자')) {
                addResult('$key: ${dayOf(value)}');
              } else if (key == '수익률') {
                addResult('$key: ${comma(value)}%');
              } else if (key == '상품_종목명') {
                addResult('$value의 주주입니다!!!! ${element["수량"]}주');
              } else if (!key.contains('코드')) {
                addResult('$key: ${comma(value)}');
              }
            }
          });
          addResult('-');
        }
        return accounts;
      default:
        return accounts;
    }
  }

  @override
  String toString() => json.toString();

  @override
  late List<Text> result = MtsController.get().texts;

  @override
  addResult(String value) {
    if ((result.isNotEmpty && result.last.data != value) || (result.isEmpty)) {
      result.add(Text(value));
    }
  }
}

// class DetailAccount {
//   String 상품명;
//   String 계좌번호;
//   String 상품코드;
//   String 상품유형코드;
//   String 상품_종목명;
//   String 상품_종목코드;
//   String 잔고유형;
//   String 수량;
//   String 현재가;
//   String 평균매입가;
//   String 매입금액;
//   String 평가금액;
//   String 평가손익;
//   String 수익률;
//   String 통화코드;
//   String 계좌번호확장;
// }