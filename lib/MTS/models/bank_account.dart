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

class BankAccount {
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
  late String yield; // 수익률
  late String totalAssets; // 총자산

  BankAccount.from(Map<String, String> json) {
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
    yield = json['수익률'] ?? '';
    totalAssets = json['총자산'] ?? '';
  }
}

class BankAccountDetail {
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
  late String yield; // 수익률
  late String monetaryCode; // 통화코드
  late String accountNumberExt; // 계좌번호확장
  late String oderableQuantity; // 주문가능수량

  BankAccountDetail.from(Map<String, String> json) {
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
    yield = json['수익률'] ?? '';
    monetaryCode = json['통화코드'] ?? '';
    accountNumberExt = json['계좌번호확장'] ?? '';
    oderableQuantity = json['주문가능수량'] ?? '';
  }
}
