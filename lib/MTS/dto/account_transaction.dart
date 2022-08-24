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

  final String module; // 금융사
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
      accountPin: accountPin,
      accountType: accountType,
      accountNum: accountNum,
      queryCode: queryCode,
      start: strStart,
      end: strEnd,
    )!;
  }

  @override
  Future<CustomResponse> fetch() async {
    return await json.fetch();
  }
}

// class AllTransaction {
//   String 거래일자;
//   String 거래시각;
//   late String 거래유형;
//   String 적요;
//   String 종목명;
//   String 거래수량;
//   String 거래금액;
//   String 수수료;
//   String 금잔수량;
//   String 금잔금액;
//   String 금잔금액2;
//   String 통화코드;
//   String 정산금액;
//   String 외화거래금액;
//   String 세금;
//   String 원화거래금액;
//   String 국외수수료;
//   String 입금통장표시내용;
//   String 출금통장표시내용;
//   String 처리점;
//   String 입금은행;
//   String 입금계좌번호;
// }