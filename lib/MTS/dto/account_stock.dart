import 'package:bside/mts/mts_functions.dart';

import '../mts_interface.dart';

class AccountStocks implements MTSInterface {
  const AccountStocks(
    this.module,
  );

  final String module; // 금융사
  final String job = '증권보유계좌조회';

  @override
  dynamic get json {
    return makeFunction(module, job);
  }
}
