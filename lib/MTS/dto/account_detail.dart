// ๐ Project imports:
import '../../utils/exception.dart';
import '../mts.dart';

class AccountDetail implements MTSInterface {
  AccountDetail(
    this.module, {
    required this.accountNum,
    required this.accountPin,
    required this.queryCode,
    required this.showISO,
    required this.username,
    required this.idOrCert,
  });

  final CustomModule module; // ๊ธ์ต์ฌ
  final String job = '๊ณ์ข์์ธ์กฐํ';
  final String accountNum; // ๊ณ์ข๋ฒํธ
  final String accountPin; // ๊ณ์ข๋น๋ฐ๋ฒํธ // ์๋ ฅ ์ํด๋ ๋์ง๋ง ์ํ๋ฉด ๊ตฌ๋งค์ข๋ชฉ ์๋์ด.
  final String queryCode; // ์กฐํ๊ตฌ๋ถ // ์ผ์ฑ "K": ์ธํ๋ง, ์์: ๊ธฐ๋ณธ์กฐํ
  final String showISO; // ํตํ์ฝ๋์ถ๋ ฅ์ฌ๋ถ // KB "2": ํตํ์ฝ๋,ํ์ฌ๊ฐ,๋งค์ํ๊ท ๊ฐ ๋ฏธ์ถ๋ ฅ, ์์: ๋ชจ๋์ถ๋ ฅ
  final String username; // ์ฌ์ฉ์๋ช
  final String idOrCert; // ๋ก๊ทธ์ธ๋ฐฉ๋ฒ

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
    throw CustomException('์กฐํ๊ตฌ๋ถ์ฝ๋๋ฅผ ํ์ธํด ์ฃผ์ธ์.');
  }

  @override
  Future<CustomResponse> apply(String username) async {
    return await json.send(username);
  }

  @override
  Future<void> post() async {
    CustomResponse res = await apply(username);
    await res.send(username);
    String accountNum = res.Output.Result.accountNum;
    List<BankAccountDetail> details = res.Output.Result.accountDetail;
    for (BankAccountDetail detail in details) {
      if (detail.productTypeCode == '01') {
        controller.updateDetail(accountNum, detail);
      }
    }
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}

class BankAccountDetail implements IOBase {
  late String productName; // ์ํ๋ช
  late String productTypeCode; // ์ํ์ ํ์ฝ๋
  late String productIssueName; // ์ํ_์ข๋ชฉ๋ช
  late String productIssueCode; // ์ํ_์ข๋ชฉ์ฝ๋
  late String balanceType; // ์๊ณ ์ ํ
  late String quantity; // ์๋
  late String presentValue; // ํ์ฌ๊ฐ
  late String averageValue; // ํ๊ท ๋งค์๊ฐ
  late String purchaseAmount; // ๋งค์๊ธ์ก
  late String evaluationAmount; // ํ๊ฐ๊ธ์ก
  late String valuationGain; // ํ๊ฐ์์ต
  late String yields; // ์์ต๋ฅ 
  late String monetaryCode; // ํตํ์ฝ๋
  late String accountNumberExt; // ๊ณ์ข๋ฒํธํ์ฅ
  late String oderableQuantity; // ์ฃผ๋ฌธ๊ฐ๋ฅ์๋

  BankAccountDetail.from(Map<String, dynamic> json) {
    productName = (json['์ํ๋ช'] ?? '') as String;
    productTypeCode = (json['์ํ์ ํ์ฝ๋'] ?? '') as String;
    productIssueName = (json['์ํ_์ข๋ชฉ๋ช'] ?? '') as String;
    productIssueCode = (json['์ํ_์ข๋ชฉ์ฝ๋'] ?? '') as String;
    balanceType = (json['์๊ณ ์ ํ'] ?? '') as String;
    quantity = (json['์๋'] ?? '') as String;
    presentValue = (json['ํ์ฌ๊ฐ'] ?? '') as String;
    averageValue = (json['ํ๊ท ๋งค์๊ฐ'] ?? '') as String;
    purchaseAmount = (json['๋งค์๊ธ์ก'] ?? '') as String;
    evaluationAmount = (json['ํ๊ฐ๊ธ์ก'] ?? '') as String;
    valuationGain = (json['ํ๊ฐ์์ต'] ?? '') as String;
    yields = (json['์์ต๋ฅ '] ?? '') as String;
    monetaryCode = (json['ํตํ์ฝ๋'] ?? '') as String;
    accountNumberExt = (json['๊ณ์ข๋ฒํธํ์ฅ'] ?? '') as String;
    oderableQuantity = (json['์ฃผ๋ฌธ๊ฐ๋ฅ์๋'] ?? '') as String;
  }

  @override
  Map<String, String> get json {
    Map<String, String> temp = {
      '์ํ๋ช': productName,
      '์ํ์ ํ์ฝ๋': productTypeCode,
      '์ํ_์ข๋ชฉ๋ช': productIssueName,
      '์ํ_์ข๋ชฉ์ฝ๋': productIssueCode,
      '์๊ณ ์ ํ': balanceType,
      '์๋': quantity,
      'ํ์ฌ๊ฐ': presentValue,
      'ํ๊ท ๋งค์๊ฐ': averageValue,
      '๋งค์๊ธ์ก': purchaseAmount,
      'ํ๊ฐ๊ธ์ก': evaluationAmount,
      'ํ๊ฐ์์ต': valuationGain,
      '์์ต๋ฅ ': yields,
      'ํตํ์ฝ๋': monetaryCode,
      '๊ณ์ข๋ฒํธํ์ฅ': accountNumberExt,
      '์ฃผ๋ฌธ๊ฐ๋ฅ์๋': oderableQuantity,
    };
    temp.removeWhere((String key, String value) => value.isEmpty);
    return temp;
  }
}
