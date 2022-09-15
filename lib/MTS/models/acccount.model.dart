// 🌎 Project imports:
import '../mts.dart';

class Account implements IOBase {
  late CustomModule module;
  late String idOrCert;
  late String accountNum;
  late String productCode;
  late String productName;
  late List<Stock> stocks = [];
  late List<Transaction> transactions = [];

  Account({
    required this.module,
    required this.idOrCert,
    required this.accountNum,
    required this.productCode,
    required this.productName,
  });

  @override
  Map<String, dynamic> get json => {
        '증권사명': module.korName,
        '아이디/인증서': idOrCert,
        '계좌번호': accountNum,
        '상품코드': productCode,
        '상품명': productName,
      };
}

class Stock implements IOBase {
  late String productName; // 상품명
  late String productTypeCode; // 상품유형코드
  late String productIssueName; // 상품_종목명
  late String quantity; // 수량
  late String presentValue; // 현재가
  late String averageValue; // 평균매입가
  late String evaluationAmount; // 평가금액
  late String valuationGain; // 평가손익
  late String yields; // 수익률

  Stock.from(BankAccountDetail detail) {
    productName = detail.productName;
    productTypeCode = detail.productTypeCode;
    productIssueName = detail.productIssueName;
    quantity = detail.quantity;
    presentValue = detail.presentValue;
    averageValue = detail.averageValue;
    evaluationAmount = detail.evaluationAmount;
    valuationGain = detail.valuationGain;
    yields = detail.yields;
  }

  @override
  Map<String, dynamic> get json => {
        '상품명': productName,
        '상품유형코드': productTypeCode,
        '상품_종목명': productIssueName,
        '수량': quantity,
        '현재가': presentValue,
        '평균매입가': averageValue,
        '평가금액': evaluationAmount,
        '평가손익': valuationGain,
        '수익률': yields,
      };
}

class Transaction implements IOBase {
  late String transactionDate; // 거래일자
  late String transactionType; // 거래유형
  late String transactionCount; // 거래수량
  late String transactionVolume; // 거래금액
  late String briefs; // 적요
  late String issueName; // 종목명
  late String commission; // 수수료

  Transaction.from(BankAccountTransaction detail) {
    transactionDate = detail.transactionDate;
    transactionType = detail.transactionType;
    briefs = detail.briefs;
    issueName = detail.issueName;
    transactionCount = detail.transactionCount;
    transactionVolume = detail.transactionVolume;
    commission = detail.commission;
  }

  @override
  Map<String, dynamic> get json => {
        '거래일자': transactionDate,
        '거래유형': transactionType,
        '거래수량': transactionCount,
        '거래금액': transactionVolume,
        '적요': briefs,
        '종목명': issueName,
        '수수료': commission,
      };
}
