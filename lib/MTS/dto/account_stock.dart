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
    controller.addResult('====================================');
    dynamic jobResult = response.Output.Result.accountStock;
    switch (jobResult.runtimeType) {
      case List:
        for (Map<String, dynamic> element in jobResult) {
          element.forEach((key, value) {
            if (element['상품코드'] == '01') {
              if (key == '계좌번호') {
                if (module.isException) {
                  value = hypen(value);
                }
                if (!accounts.contains(value)) {
                  accounts.add(value);
                  controller.addResult('$key: ${hypen(value)}');
                }
              }
            }
          });
          controller.addResult('-');
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
}

String hypen(String acc) {
  int len = acc.length;
  try {
    return '${acc.substring(0, len - 2)}-${acc.substring(len - 2)}';
  } catch (e) {
    return acc;
  }
}

class StockAccount {
  late String accountNumber; // 계좌번호
  late String productCode; // 상품코드
  late String productType; // 상품타입
  late String depositReceived; // 예수금
  late String depositReceivedF; // 외화예수금
  late String evaluationAmount; // 평가금액

  StockAccount.from(Map<String, String> json) {
    accountNumber = json['계좌번호'] ?? '';
    productCode = json['상품코드'] ?? '';
    productType = json['상품타입'] ?? '';
    depositReceived = json['예수금'] ?? '';
    depositReceivedF = json['외화예수금'] ?? '';
    evaluationAmount = json['평가금액'] ?? '';
  }
}
