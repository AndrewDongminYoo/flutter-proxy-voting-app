// ๐ Project imports:
import '../../utils/exception.dart';
import '../mts.dart';

class AccountAll implements MTSInterface {
  AccountAll(
    this.module, {
    this.queryCode = 'S',
    required this.password,
    required this.username,
    required this.idOrCert,
  });

  final CustomModule module; // ๊ธ์ต์ฌ
  final String job = '์ ๊ณ์ข์กฐํ';
  final String queryCode; // ์กฐํ๊ตฌ๋ถ
  final String password; // ์ฌ์ฉ์๋น๋ฐ๋ฒํธ
  final String username; // ์ฌ์ฉ์๋ช
  final String idOrCert; // ๋ก๊ทธ์ธ๋ฐฉ๋ฒ

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
      throw CustomException('์กฐํ๊ตฌ๋ถ ์ฝ๋๋ฅผ ํ์ธํด ์ฃผ์ธ์.');
    }
  }

  @override
  Future<CustomResponse> apply(String username) async {
    return await json.send(username);
  }

  @override
  Future<void> post() async {
    CustomResponse res = await apply(username);
    await res.send(username);
    for (BankAccountAll account in res.Output.Result.accountAll) {
      controller.updateAccount(account);
    }
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}

class BankAccountAll implements IOBase {
  late String accountNumber; // ๊ณ์ข๋ฒํธ
  late String accountPreNum; // ๊ณ์ข๋ฒํธํ์์ฉ
  late String accountType; // ๊ณ์ข๋ช_์ ํ
  late String accountCost; // ์๊ธ
  late String purchaseAmount; // ๋งค์๊ธ์ก
  late String loanAmount; // ๋์ถ๊ธ์ก
  late String valuationAmount; // ํ๊ฐ๊ธ์ก
  late String valuationIncome; // ํ๊ฐ์์ต
  late String availableAmount; // ์ถ๊ธ๊ฐ๋ฅ๊ธ์ก
  late String depositReceived; // ์์๊ธ
  late String depositReceivedD1; // ์์๊ธ_D1
  late String depositReceivedD2; // ์์๊ธ_D2
  late String depositReceivedF; // ์ธํ์์๊ธ
  late String yields; // ์์ต๋ฅ 
  late String totalAssets; // ์ด์์ฐ

  BankAccountAll.from(Map<String, dynamic> json) {
    accountNumber = json['๊ณ์ข๋ฒํธ'] ?? '';
    accountPreNum = json['๊ณ์ข๋ฒํธํ์์ฉ'] ?? '';
    accountType = json['๊ณ์ข๋ช_์ ํ'] ?? '';
    accountCost = json['์๊ธ'] ?? '';
    purchaseAmount = json['๋งค์๊ธ์ก'] ?? '';
    loanAmount = json['๋์ถ๊ธ์ก'] ?? '';
    valuationAmount = json['ํ๊ฐ๊ธ์ก'] ?? '';
    valuationIncome = json['ํ๊ฐ์์ต'] ?? '';
    availableAmount = json['์ถ๊ธ๊ฐ๋ฅ๊ธ์ก'] ?? '';
    depositReceived = json['์์๊ธ'] ?? '';
    depositReceivedD1 = json['์์๊ธ_D1'] ?? '';
    depositReceivedD2 = json['์์๊ธ_D2'] ?? '';
    depositReceivedF = json['์ธํ์์๊ธ'] ?? '';
    yields = json['์์ต๋ฅ '] ?? '';
    totalAssets = json['์ด์์ฐ'] ?? '';
  }

  @override
  Map<String, String> get json {
    Map<String, String> temp = {
      '๊ณ์ข๋ฒํธ': accountNumber,
      '๊ณ์ข๋ฒํธํ์์ฉ': accountPreNum,
      '๊ณ์ข๋ช_์ ํ': accountType,
      '์๊ธ': accountCost,
      '๋งค์๊ธ์ก': purchaseAmount,
      '๋์ถ๊ธ์ก': loanAmount,
      'ํ๊ฐ๊ธ์ก': valuationAmount,
      'ํ๊ฐ์์ต': valuationIncome,
      '์ถ๊ธ๊ฐ๋ฅ๊ธ์ก': availableAmount,
      '์์๊ธ': depositReceived,
      '์์๊ธ_D1': depositReceivedD1,
      '์์๊ธ_D2': depositReceivedD2,
      '์ธํ์์๊ธ': depositReceivedF,
      '์์ต๋ฅ ': yields,
      '์ด์์ฐ': totalAssets,
    };
    temp.removeWhere((String key, String value) {
      return value.isEmpty;
    });
    return temp;
  }

  @override
  String toString() => json.toString();
}
