// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../utils/exception.dart';
import '../mts.dart';

class AccountAll implements MTSInterface {
  AccountAll(
    this.module, {
    this.queryCode = 'S',
    required this.password,
  });

  final CustomModule module; // 금융사
  final String job = '전계좌조회';
  final String queryCode; // 조회구분
  final String password; // 사용자비밀번호

  @override
  CustomRequest get json {
    if (['', 'S', 'D'].contains(queryCode)) {
      return makeFunction(
        module,
        job,
        queryCode: queryCode,
        password: password,
      )!;
    } else {
      throw CustomException('조회구분 코드를 확인해 주세요.');
    }
  }

  @override
  Future<CustomResponse> fetch(String username) async {
    return await json.fetch(username);
  }

  @override
  Future<Set<String>> post(String username) async {
    CustomResponse response = await fetch(username);
    await response.fetch(username);
    Set<String> accounts = {};
    addResult('====================================');
    dynamic jobResult = response.Output.Result.accountAll;
    switch (jobResult.runtimeType) {
      case List:
        for (Map<String, dynamic> element in jobResult) {
          element.forEach((key, value) {
            if (element['총자산'] != '0') {
              if (key == '계좌번호') {
                if (!accounts.contains(value)) {
                  accounts.add(value);
                  addResult('$key: ${hypen(value)}');
                }
              } else if (key.contains('일자')) {
                addResult('$key: ${dayOf(value)}');
              } else if (key.contains('수익률')) {
                addResult('$key: ${comma(value)}%');
              } else {
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
  addResult(String value) {
    bool valueIsNotLast =
        controller.texts.isNotEmpty && controller.texts.last.data != value;
    if ((valueIsNotLast) || (controller.texts.isEmpty)) {
      controller.texts.add(Text(value));
    }
  }

  @override
  MtsController controller = MtsController.get();
}

// class AllAccount {
//   String 계좌번호;
//   String 계좌번호표시용;
//   String 원금;
//   String 계좌명_유형;
//   String 매입금액;
//   String 대출금액;
//   String 평가금액;
//   String 평가손익;
//   String 출금가능금액;
//   String 예수금;
//   String 예수금_D1;
//   String 예수금_D2;
//   String 외화예수금;
//   String 수익률;
//   String 총자산;
// }