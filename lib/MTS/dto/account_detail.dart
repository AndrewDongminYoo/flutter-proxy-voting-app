// 🌎 Project imports:
import '../../utils/exception.dart';
import '../mts.dart';

class AccountDetail implements MTSInterface {
  AccountDetail(
    this.module, {
    required this.accountNum,
    required this.accountPin,
    required this.queryCode,
    required this.showISO,
  });

  final CustomModule module; // 금융사
  final String job = '계좌상세조회';
  final String accountNum; // 계좌번호
  final String accountPin; // 계좌비밀번호 // 입력 안해도 되지만 안하면 구매종목 안나옴.
  final String queryCode; // 조회구분 // 삼성 "K": 외화만, 없음: 기본조회
  final String showISO; // 통화코드출력여부 // KB "2": 통화코드,현재가,매입평균가 미출력, 없음: 모두출력

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
    throw CustomException('조회구분코드를 확인해 주세요.');
  }

  @override
  Future<CustomResponse> fetch(String username) async {
    return await json.fetch(username);
  }

  @override
  post(String username) async {
    CustomResponse res = await fetch(username);
    await res.fetch(username);
    controller.addResult('====================================');
    List<BankAccountDetail> jobResult = res.Output.Result.accountDetail;
    for (BankAccountDetail acc in jobResult) {
      if (acc.productTypeCode == '01' || acc.productName.contains('주식')) {
        controller.addAccount(res.Output.Result.accountNum);
        controller.addResult('계좌번호: ${hypen(res.Output.Result.accountNum)}');
        controller.addResult('수익률: ${comma(acc.yields)}%');
        controller
            .addResult('${acc.productIssueName}의 주주입니다. ${acc.quantity}주');
      }
      controller.addResult('-');
    }
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}

class BankAccountDetail implements IOBase {
  late String productName; // 상품명
  late String productTypeCode; // 상품유형코드
  late String productIssueName; // 상품_종목명
  late String productIssueCode; // 상품_종목코드
  late String balanceType; // 잔고유형
  late String quantity; // 수량
  late String presentValue; // 현재가
  late String averageValue; // 평균매입가
  late String purchaseAmount; // 매입금액
  late String evaluationAmount; // 평가금액
  late String valuationGain; // 평가손익
  late String yields; // 수익률
  late String monetaryCode; // 통화코드
  late String accountNumberExt; // 계좌번호확장
  late String oderableQuantity; // 주문가능수량

  BankAccountDetail.from(Map<String, dynamic> json) {
    productName = json['상품명'] ?? '';
    productTypeCode = json['상품유형코드'] ?? '';
    productIssueName = json['상품_종목명'] ?? '';
    productIssueCode = json['상품_종목코드'] ?? '';
    balanceType = json['잔고유형'] ?? '';
    quantity = json['수량'] ?? '';
    presentValue = json['현재가'] ?? '';
    averageValue = json['평균매입가'] ?? '';
    purchaseAmount = json['매입금액'] ?? '';
    evaluationAmount = json['평가금액'] ?? '';
    valuationGain = json['평가손익'] ?? '';
    yields = json['수익률'] ?? '';
    monetaryCode = json['통화코드'] ?? '';
    accountNumberExt = json['계좌번호확장'] ?? '';
    oderableQuantity = json['주문가능수량'] ?? '';
  }

  @override
  Map<String, String> get json {
    Map<String, String> temp = {
      '상품명': productName,
      '상품유형코드': productTypeCode,
      '상품_종목명': productIssueName,
      '상품_종목코드': productIssueCode,
      '잔고유형': balanceType,
      '수량': quantity,
      '현재가': presentValue,
      '평균매입가': averageValue,
      '매입금액': purchaseAmount,
      '평가금액': evaluationAmount,
      '평가손익': valuationGain,
      '수익률': yields,
      '통화코드': monetaryCode,
      '계좌번호확장': accountNumberExt,
      '주문가능수량': oderableQuantity,
    };
    temp.removeWhere((key, value) => value.isEmpty);
    return temp;
  }
}
