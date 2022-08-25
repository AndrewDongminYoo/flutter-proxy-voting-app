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
  Future<Set<String>> post(List<String> output) async {
    CustomResponse response = await fetch();
    await response.fetchDataAndUploadFB();
    Set<String> accounts = {};
    output.add('=====================================');
    dynamic jobResult = response.Output.Result[job];
    switch (jobResult.runtimeType) {
      case List:
        for (Map<String, dynamic> element in jobResult) {
          element.forEach((key, value) {
            switch (key) {
              case '계좌번호':
                if (!accounts.contains(value)) {
                  accounts.add(value);
                  output.add('$key: ${hypen(value)}');
                }
                break;
              case '상품명':
                output.add('$key: ${comma(value)}');
                break;
              case '상품코드':
                output.add('$key: $value');
                break;
            }
          });
          if (output.last != '-') {
            output.add('-');
          }
        }
        return accounts;
      default:
        return accounts;
    }
  }
}

// class StockAccount {
//   String 계좌번호;
//   String 상품코드; // 위탁 : 01, 펀드: 02, CMA: 05
//   String 상품명;
// }
