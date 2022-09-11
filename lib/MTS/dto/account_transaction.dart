// 🌎 Project imports:
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
  }) : super();

  final CustomModule module; // 금융사
  final String job = '거래내역조회';
  final String accountExt; // 계좌번호확장
  final String accountPin; // 계좌비밀번호
  final String accountNum; // 계좌번호
  final String accountType; // 상품구분
  final String queryCode; // 조회구분
  final dynamic start; // 조회시작일
  final dynamic end; // 조회종료일

  @override
  CustomRequest get json {
    String strEnd = end;
    String strStart = start;
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
  Future<CustomResponse> fetch(String username) async {
    return await json.fetch(username);
  }

  @override
  Future<Set<String>> post(String username) async {
    CustomResponse response = await fetch(username);
    await response.fetch(username);
    Set<String> accounts = {};
    controller.addResult('====================================');
    dynamic jobResult = response.Output.Result.accountTransaction;
    switch (jobResult.runtimeType) {
      case List:
        for (Map<String, dynamic> element in jobResult) {
          if (element['거래유형'].contains('주식매수')) {
            element.forEach((key, value) {
              if (key == '입금계좌번호') {
                if (!accounts.contains(value)) {
                  accounts.add(value);
                  controller.addResult('$key: ${hypen(value)}');
                }
              } else if (key.contains('거래일자')) {
                controller.addResult('$key: ${dayOf(value)}');
              } else if (key == '종목명') {
                controller.addResult('$value의 주주입니다!!!!');
              } else if (key != '통화코드') {
                controller.addResult('$key: ${comma(value)}');
              }
            });
          }
          controller.addResult('-');
        }
        return accounts;
      default:
        return accounts;
    }
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}

class BankAccountTransaction {
  late String transactionDate; // 거래일자
  late String transactionTime; // 거래시각
  late String transactionType; // 거래유형
  late String briefs; // 적요
  late String issueName; // 종목명
  late String transactionCount; // 거래수량
  late String transactionVolume; // 거래금액
  late String settlementAmount; // 정산금액
  late String commission; // 수수료
  late String balanceCount; // 금잔수량
  late String balanceAmount; // 금잔금액
  late String balanceAmount2; // 금잔금액2
  late String monetaryCode; // 통화코드
  late String transactionVolFor; // 외화거래금액
  late String tax; // 세금
  late String transactionVolWon; // 원화거래금액
  late String foriegnCommission; // 국외수수료
  late String paidAccountMemo; // 입금통장표시내용
  late String receivedAccMemo; // 출금통장표시내용
  late String tradingBank; // 처리점
  late String bankOffice; // 입금은행
  late String paidAccountNum; // 입금계좌번호

  BankAccountTransaction.from(Map<String, String> json) {
    transactionDate = json['거래일자'] ?? '';
    transactionTime = json['거래시각'] ?? '';
    transactionType = json['거래유형'] ?? '';
    briefs = json['적요'] ?? '';
    issueName = json['종목명'] ?? '';
    transactionCount = json['거래수량'] ?? '';
    transactionVolume = json['거래금액'] ?? '';
    settlementAmount = json['정산금액'] ?? '';
    commission = json['수수료'] ?? '';
    balanceCount = json['금잔수량'] ?? '';
    balanceAmount = json['금잔금액'] ?? '';
    balanceAmount2 = json['금잔금액2'] ?? '';
    monetaryCode = json['통화코드'] ?? '';
    transactionVolFor = json['외화거래금액'] ?? '';
    tax = json['세금'] ?? '';
    transactionVolWon = json['원화거래금액'] ?? '';
    foriegnCommission = json['국외수수료'] ?? '';
    paidAccountMemo = json['입금통장표시내용'] ?? '';
    receivedAccMemo = json['출금통장표시내용'] ?? '';
    tradingBank = json['처리점'] ?? '';
    bankOffice = json['입금은행'] ?? '';
    paidAccountNum = json['입금계좌번호'] ?? '';
  }
}
