// π Project imports:
import '../mts.dart';

class AccountStocks implements MTSInterface {
  AccountStocks(
    this.module,
    this.username,
    this.idOrCert,
  );

  final CustomModule module; // κΈμ΅μ¬
  final String job = 'μ¦κΆλ³΄μ κ³μ’μ‘°ν';
  final String username; // μ¬μ©μλͺ
  final String idOrCert; // λ‘κ·ΈμΈλ°©λ²

  @override
  CustomRequest get json {
    return makeFunction(module, job)!;
  }

  @override
  Future<CustomResponse> apply(String username) async {
    return await json.send(username);
  }

  @override
  Future<void> post() async {
    CustomResponse response = await apply(username);
    await response.send(username);
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
  late String accountNumber; // κ³μ’λ²νΈ
  late String productCode; // μνμ½λ
  late String productName; // μνλͺ

  StockAccount.from(Map<String, dynamic> json) {
    accountNumber = json['κ³μ’λ²νΈ'] ?? '';
    productCode = json['μνμ½λ'] ?? ''; // μ£ΌμμΈ κ²½μ° 01
    productName = json['μνλͺ'] ?? '';
  }

  @override
  Map<String, String> get json {
    Map<String, String> temp = {
      'κ³μ’λ²νΈ': accountNumber,
      'μνμ½λ': productCode,
      'μνλͺ': productName,
    };
    temp.removeWhere((String key, String value) => value.isEmpty);
    return temp;
  }
}
