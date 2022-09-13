// 🌎 Project imports:
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

  final CustomModule module; // 금융사
  final String job = '전계좌조회';
  final String queryCode; // 조회구분
  final String password; // 사용자비밀번호
  final String username; // 사용자명
  final String idOrCert; // 로그인방법

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
  post() async {
    CustomResponse res = await fetch(username);
    await res.fetch(username);
    List<BankAccount> jobResult = res.Output.Result.accountAll;
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}

class BankAccount implements IOBase {
  late String accountNumber; // 계좌번호
  late String accountPreNum; // 계좌번호표시용
  late String accountType; // 계좌명_유형
  late String accountCost; // 원금
  late String purchaseAmount; // 매입금액
  late String loanAmount; // 대출금액
  late String valuationAmount; // 평가금액
  late String valuationIncome; // 평가손익
  late String availableAmount; // 출금가능금액
  late String depositReceived; // 예수금
  late String depositReceivedD1; // 예수금_D1
  late String depositReceivedD2; // 예수금_D2
  late String depositReceivedF; // 외화예수금
  late String yields; // 수익률
  late String totalAssets; // 총자산

  BankAccount.from(Map<String, dynamic> json) {
    accountNumber = json['계좌번호'] ?? '';
    accountPreNum = json['계좌번호표시용'] ?? '';
    accountType = json['계좌명_유형'] ?? '';
    accountCost = json['원금'] ?? '';
    purchaseAmount = json['매입금액'] ?? '';
    loanAmount = json['대출금액'] ?? '';
    valuationAmount = json['평가금액'] ?? '';
    valuationIncome = json['평가손익'] ?? '';
    availableAmount = json['출금가능금액'] ?? '';
    depositReceived = json['예수금'] ?? '';
    depositReceivedD1 = json['예수금_D1'] ?? '';
    depositReceivedD2 = json['예수금_D2'] ?? '';
    depositReceivedF = json['외화예수금'] ?? '';
    yields = json['수익률'] ?? '';
    totalAssets = json['총자산'] ?? '';
  }

  @override
  Map<String, String> get json {
    Map<String, String> temp = {
      '계좌번호': accountNumber,
      '계좌번호표시용': accountPreNum,
      '계좌명_유형': accountType,
      '원금': accountCost,
      '매입금액': purchaseAmount,
      '대출금액': loanAmount,
      '평가금액': valuationAmount,
      '평가손익': valuationIncome,
      '출금가능금액': availableAmount,
      '예수금': depositReceived,
      '예수금_D1': depositReceivedD1,
      '예수금_D2': depositReceivedD2,
      '외화예수금': depositReceivedF,
      '수익률': yields,
      '총자산': totalAssets,
    };
    temp.removeWhere((key, value) => value.isEmpty);
    return temp;
  }

  @override
  String toString() => json.toString();
}
