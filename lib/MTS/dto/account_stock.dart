// 🌎 Project imports:
import '../mts.dart';

class AccountStocks implements MTSInterface {
  AccountStocks(
    this.module,
    this.username,
    this.idOrCert,
  );

  final CustomModule module; // 금융사
  final String job = '증권보유계좌조회';
  final String username; // 사용자명
  final String idOrCert; // 로그인방법

  @override
  CustomRequest get json {
    return makeFunction(module, job)!;
  }

  @override
  Future<CustomResponse> fetch(String username) async {
    return await json.fetch(username);
  }

  @override
  post() async {
    CustomResponse response = await fetch(username);
    await response.fetch(username);
    controller.addResult('====================================');
    List<StockAccount> jobResult = response.Output.Result.accountStock;
    for (StockAccount account in jobResult) {
      if (account.productCode == '01') {
        if (module.isException) {
          account.accountNumber = process(account.accountNumber);
        }
        controller.addAccount(module, idOrCert, account.accountNumber);
        controller.addResult('계좌번호: ${hypen(account.accountNumber)}');
      }
      controller.addResult('-');
    }
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}

String process(String acc) {
  int len = acc.length;
  try {
    return '${acc.substring(0, len - 2)}-${acc.substring(len - 2)}';
  } catch (e) {
    return acc;
  }
}

class StockAccount implements IOBase {
  late String accountNumber; // 계좌번호
  late String productCode; // 상품코드
  late String productType; // 상품타입
  late String depositReceived; // 예수금
  late String depositReceivedF; // 외화예수금
  late String evaluationAmount; // 평가금액

  StockAccount.from(Map<String, dynamic> json) {
    accountNumber = json['계좌번호'] ?? '';
    productCode = json['상품코드'] ?? ''; // 주식인 경우 01
    productType = json['상품타입'] ?? '';
    depositReceived = json['예수금'] ?? '';
    depositReceivedF = json['외화예수금'] ?? '';
    evaluationAmount = json['평가금액'] ?? '';
  }

  @override
  Map<String, String> get json {
    Map<String, String> temp = {
      '계좌번호': accountNumber,
      '상품코드': productCode,
      '상품타입': productType,
      '예수금': depositReceived,
      '외화예수금': depositReceivedF,
      '평가금액': evaluationAmount,
    };
    temp.removeWhere((key, value) => value.isEmpty);
    return temp;
  }
}
