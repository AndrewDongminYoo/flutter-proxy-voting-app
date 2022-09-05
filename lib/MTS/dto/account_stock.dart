// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../mts.dart';

class AccountStocks implements MTSInterface {
  AccountStocks(
    this.module,
  );

  final CustomModule module; // 금융사
  final String job = '증권보유계좌조회';

  @override
  CustomRequest get json {
    return makeFunction(module, job)!;
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
    dynamic jobResult = response.Output.Result.accountStock;
    switch (jobResult.runtimeType) {
      case List:
        for (Map<String, dynamic> element in jobResult) {
          element.forEach((key, value) {
            if (element['상품코드'] == '01') {
              if (key == '계좌번호') {
                if (module.isException) {
                  value = processAcc(value);
                }
                if (!accounts.contains(value)) {
                  accounts.add(value);
                  addResult('$key: ${hypen(value)}');
                }
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
  MtsController controller = MtsController.get();

  @override
  addResult(String value) {
    bool valueIsNotLast =
        controller.texts.isNotEmpty && controller.texts.last.data != value;
    if ((valueIsNotLast) || (controller.texts.isEmpty)) {
      controller.texts.add(Text(value));
    }
  }
}

// class StockAccount {
//   String 계좌번호;
//   String 상품코드; // 위탁 : 01, 펀드: 02, CMA: 05
//   String 상품명;
// }

String processAcc(String acc) {
  int len = acc.length;
  try {
    return '${acc.substring(0, len - 2)}-${acc.substring(len - 2)}';
  } catch (e) {
    return acc;
  }
}
