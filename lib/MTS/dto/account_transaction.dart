import '../mts.dart';

class AccountTransaction implements MTSInterface {
  const AccountTransaction(
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
  Future<CustomResponse> fetch() async {
    return await json.fetch();
  }

  @override
  Future<Set<String>> post(List<String> output) async {
    CustomResponse response = await fetch();
    await response.fetch();
    Set<String> accounts = {};
    output.add('=====================================');
    dynamic jobResult = response.Output.Result.accountTransaction;
    switch (jobResult.runtimeType) {
      case List:
        for (Map<String, dynamic> element in jobResult) {
          if (element['거래유형'].contains('주식매수')) {
            element.forEach((key, value) {
              if (key == '입금계좌번호') {
                if (!accounts.contains(value)) {
                  accounts.add(value);
                  output.add('$key: ${hypen(value)}');
                }
              } else if (key.contains('거래일자')) {
                output.add('$key: ${dayOf(value)}');
              } else if (key == '종목명') {
                output.add('$value의 주주입니다!!!!');
              } else if (key != '통화코드') {
                output.add('$key: ${comma(value)}');
              }
            });
          }
          if (output.last != '-') {
            output.add('-');
          }
        }
        return accounts;
      default:
        return accounts;
    }
  }

  @override
  String toString() => json.toString();
}

// class AllTransaction {
//   String 거래일자;
//   String 거래시각;
//   late String 거래유형;
//   String 적요;
//   String 종목명;
//   String 거래수량;
//   String 거래금액; // 삼성증권 외 필수출력
//   String 수수료;
//   String 금잔수량;
//   String 금잔금액;
//   String 금잔금액2; // 메리츠, 현대차증권만 사용
//   String 통화코드; // 유안타증권만 사용
//   String 정산금액;
//   String 외화거래금액;
//   String 세금;
//   String 원화거래금액;
//   String 국외수수료; // KB증권만 사용
//   String 입금통장표시내용;
//   String 출금통장표시내용;
//   String 처리점;
//   String 입금은행;
//   String 입금계좌번호;
// }