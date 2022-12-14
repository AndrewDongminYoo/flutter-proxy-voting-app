// ๐ Project imports:
import '../mts.dart';

class AccountTransaction implements MTSInterface {
  AccountTransaction(
    this.module, {
    required this.accountNum,
    required this.accountPin,
    required this.accountExt,
    required this.accountType,
    required this.queryCode,
    this.start = '',
    this.end = '',
    required this.username,
    required this.idOrCert,
  }) : super();

  final CustomModule module; // ๊ธ์ต์ฌ
  final String job = '๊ฑฐ๋๋ด์ญ์กฐํ';
  final String accountExt; // ๊ณ์ข๋ฒํธํ์ฅ
  final String accountPin; // ๊ณ์ข๋น๋ฐ๋ฒํธ
  final String accountNum; // ๊ณ์ข๋ฒํธ
  final String accountType; // ์ํ๊ตฌ๋ถ
  final String queryCode; // ์กฐํ๊ตฌ๋ถ
  final dynamic start; // ์กฐํ์์์ผ
  final dynamic end; // ์กฐํ์ข๋ฃ์ผ
  final String username; // ์ฌ์ฉ์๋ช
  final String idOrCert; // ๋ก๊ทธ์ธ๋ฐฉ๋ฒ

  @override
  CustomRequest get json {
    String strEnd;
    String strStart;
    if (end.runtimeType == DateTime) {
      strEnd = end.toString();
    } else {
      strEnd = today();
    }
    if (start.runtimeType == DateTime) {
      strStart = start.toString();
    } else {
      strStart = sixAgo(strEnd);
    }

    return makeFunction(
      module,
      job,
      accountExt: accountExt,
      accountNum: accountNum,
      accountPin: accountPin,
      accountType: accountType,
      queryCode: queryCode,
      start: strStart,
      end: strEnd,
    )!;
  }

  @override
  Future<CustomResponse> apply(String username) async {
    return await json.send(username);
  }

  @override
  Future<void> post() async {
    CustomResponse response = await apply(username);
    await response.send(username);
    for (BankAccountTransaction trans
        in response.Output.Result.accountTransaction) {
      controller.tradeStock(accountNum, trans);
    }
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}

class BankAccountTransaction implements IOBase {
  late String transactionDate; // ๊ฑฐ๋์ผ์
  late String transactionTime; // ๊ฑฐ๋์๊ฐ
  late String transactionType; // ๊ฑฐ๋์?ํ
  late String transactionCount; // ๊ฑฐ๋์๋
  late String transactionVolume; // ๊ฑฐ๋๊ธ์ก
  late String transactionVolFor; // ์ธํ๊ฑฐ๋๊ธ์ก
  late String transactionVolWon; // ์ํ๊ฑฐ๋๊ธ์ก
  late String foriegnCommission; // ๊ตญ์ธ์์๋ฃ
  late String settlementAmount; // ์?์ฐ๊ธ์ก
  late String briefs; // ์?์
  late String issueName; // ์ข๋ชฉ๋ช
  late String commission; // ์์๋ฃ
  late String balanceCount; // ๊ธ์์๋
  late String balanceAmount; // ๊ธ์๊ธ์ก
  late String balanceAmount2; // ๊ธ์๊ธ์ก2
  late String monetaryCode; // ํตํ์ฝ๋
  late String tax; // ์ธ๊ธ
  late String bankOffice; // ์๊ธ์ํ
  late String paidAccountNum; // ์๊ธ๊ณ์ข๋ฒํธ
  late String paidAccountMemo; // ์๊ธํต์ฅํ์๋ด์ฉ
  late String receivedAccMemo; // ์ถ๊ธํต์ฅํ์๋ด์ฉ
  late String tradingBank; // ์ฒ๋ฆฌ์?

  BankAccountTransaction.from(Map<String, dynamic> json) {
    transactionDate = json['๊ฑฐ๋์ผ์'] ?? '';
    transactionTime = json['๊ฑฐ๋์๊ฐ'] ?? '';
    transactionType = json['๊ฑฐ๋์?ํ'] ?? '';
    briefs = json['์?์'] ?? '';
    issueName = json['์ข๋ชฉ๋ช'] ?? '';
    transactionCount = json['๊ฑฐ๋์๋'] ?? '';
    transactionVolume = json['๊ฑฐ๋๊ธ์ก'] ?? '';
    settlementAmount = json['์?์ฐ๊ธ์ก'] ?? '';
    commission = json['์์๋ฃ'] ?? '';
    balanceCount = json['๊ธ์์๋'] ?? '';
    balanceAmount = json['๊ธ์๊ธ์ก'] ?? '';
    balanceAmount2 = json['๊ธ์๊ธ์ก2'] ?? '';
    monetaryCode = json['ํตํ์ฝ๋'] ?? '';
    transactionVolFor = json['์ธํ๊ฑฐ๋๊ธ์ก'] ?? '';
    tax = json['์ธ๊ธ'] ?? '';
    transactionVolWon = json['์ํ๊ฑฐ๋๊ธ์ก'] ?? '';
    foriegnCommission = json['๊ตญ์ธ์์๋ฃ'] ?? '';
    paidAccountMemo = json['์๊ธํต์ฅํ์๋ด์ฉ'] ?? '';
    receivedAccMemo = json['์ถ๊ธํต์ฅํ์๋ด์ฉ'] ?? '';
    tradingBank = json['์ฒ๋ฆฌ์?'] ?? '';
    bankOffice = json['์๊ธ์ํ'] ?? '';
    paidAccountNum = json['์๊ธ๊ณ์ข๋ฒํธ'] ?? '';
  }

  @override
  Map<String, String> get json {
    Map<String, String> temp = {
      '๊ฑฐ๋์ผ์': transactionDate,
      '๊ฑฐ๋์๊ฐ': transactionTime,
      '๊ฑฐ๋์?ํ': transactionType,
      '์?์': briefs,
      '์ข๋ชฉ๋ช': issueName,
      '๊ฑฐ๋์๋': transactionCount,
      '๊ฑฐ๋๊ธ์ก': transactionVolume,
      '์?์ฐ๊ธ์ก': settlementAmount,
      '์์๋ฃ': commission,
      '๊ธ์์๋': balanceCount,
      '๊ธ์๊ธ์ก': balanceAmount,
      '๊ธ์๊ธ์ก2': balanceAmount2,
      'ํตํ์ฝ๋': monetaryCode,
      '์ธํ๊ฑฐ๋๊ธ์ก': transactionVolFor,
      '์ธ๊ธ': tax,
      '์ํ๊ฑฐ๋๊ธ์ก': transactionVolWon,
      '๊ตญ์ธ์์๋ฃ': foriegnCommission,
      '์๊ธํต์ฅํ์๋ด์ฉ': paidAccountMemo,
      '์ถ๊ธํต์ฅํ์๋ด์ฉ': receivedAccMemo,
      '์ฒ๋ฆฌ์?': tradingBank,
      '์๊ธ์ํ': bankOffice,
      '์๊ธ๊ณ์ข๋ฒํธ': paidAccountNum,
    };
    temp.removeWhere((String key, String value) => value.isEmpty);
    return temp;
  }
}
