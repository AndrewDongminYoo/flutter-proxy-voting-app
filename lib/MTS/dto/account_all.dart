import '../mts.dart';

class AccountAll implements MTSInterface {
  const AccountAll(
    this.module, {
    this.queryCode = 'S',
    required this.password,
  });

  final String module; // 금융사
  final String job = '전계좌조회';
  final String queryCode; // 조회구분
  final String password; // 사용자비밀번호

  @override
  CustomRequest get json {
    if (['', 'S', 'D'].contains(queryCode)) {
      return makeFunction(
        module,
        job,
        queryCode: queryCode,
        password: password,
      )!;
    } else {
      throw Exception('조회구분 코드를 확인해 주세요.');
    }
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

// class AllAccount {
//   String 계좌번호;
//   String 계좌번호표시용;
//   String 원금;
//   String 계좌명_유형;
//   String 매입금액;
//   String 대출금액;
//   String 평가금액;
//   String 평가손익;
//   String 출금가능금액;
//   String 예수금;
//   String 예수금_D1;
//   String 예수금_D2;
//   String 외화예수금;
//   String 수익률;
//   String 총자산;
// }