import '../mts.dart';

class AccountStocks implements MTSInterface {
  const AccountStocks(
    this.module,
  );

  final String module; // 금융사
  final String job = '증권보유계좌조회';

  @override
  CustomRequest get json {
    return makeFunction(module, job)!;
  }

  @override
  Future<CustomResponse> fetch() async {
    return await json.fetch();
  }

  @override
  Future<void> post() async {
    CustomResponse response = await json.fetch();
    response.fetchDataAndUploadFB();
  }
}

// class StockAccount {
//   String 계좌번호;
//   String 상품코드;
//   String 상품명;
// }
