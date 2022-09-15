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
    List<StockAccount> jobResult = response.Output.Result.accountStock;
    for (StockAccount account in jobResult) {
      if (account.productCode == '01') {
        if (module.isException) {
          account.accountNumber = process(account.accountNumber);
        }
        controller.addAccount(
          module,
          idOrCert,
          account.accountNumber,
          account.productCode,
          account.productName,
        );
      }
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
  late String productName; // 상품명

  StockAccount.from(Map<String, dynamic> json) {
    accountNumber = json['계좌번호'] ?? '';
    productCode = json['상품코드'] ?? ''; // 주식인 경우 01
    productName = json['상품명'] ?? '';
  }

  @override
  Map<String, String> get json {
    Map<String, String> temp = {
      '계좌번호': accountNumber,
      '상품코드': productCode,
      '상품명': productName,
    };
    temp.removeWhere((key, value) => value.isEmpty);
    return temp;
  }
}
