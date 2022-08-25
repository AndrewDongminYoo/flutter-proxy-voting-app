import '../mts.dart';

class AccountStocks implements MTSInterface {
  const AccountStocks(
    this.module,
  );

  final CustomModule module; // 금융사
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
            if (element['상품코드'] == '01' || element['상품명'].contains('주식')) {
              switch (key) {
                case '계좌번호':
                  if (!accounts.contains(value)) {
                    accounts.add(value);
                    output.add('$key: ${hypen(value)}');
                  }
                  break;
              }
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

  @override
  String toString() => json.toString();
}

// class StockAccount {
//   String 계좌번호;
//   String 상품코드; // 위탁 : 01, 펀드: 02, CMA: 05
//   String 상품명;
// }
