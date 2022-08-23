import 'package:bside/mts/mts_functions.dart';
import 'package:bside/mts/widgets/formatters.dart';

import '../mts_interface.dart';

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
  fetch() async {
    return await json.fetch();
  }
}
