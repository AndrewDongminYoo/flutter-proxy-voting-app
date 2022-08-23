import 'package:bside/mts/mts_functions.dart';

import '../mts_interface.dart';

class LogoutRequest implements MTSInterface {
  const LogoutRequest(
    this.module,
  );

  final String module; // 금융사
  final String job = '로그아웃';

  @override
  CustomRequest get json {
    return makeFunction(module, job)!;
  }

  @override
  fetch() async {
    return await json.fetch();
  }
}
