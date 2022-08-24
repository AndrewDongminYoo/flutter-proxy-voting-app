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
}
