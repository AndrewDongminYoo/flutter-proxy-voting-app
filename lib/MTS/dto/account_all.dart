import 'package:bside/lib.dart';
import '../mts_interface.dart';

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
  fetch() async {
    return await json.fetch();
  }
}
