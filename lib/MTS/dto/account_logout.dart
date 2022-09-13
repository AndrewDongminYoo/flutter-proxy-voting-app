// 🌎 Project imports:
import '../mts.dart';

class LogoutRequest implements MTSInterface {
  LogoutRequest(
    this.module,
    this.username,
    this.idOrCert,
  );

  final CustomModule module; // 금융사
  final String job = '로그아웃';
  final String username; // 사용자명
  final String idOrCert; // 로그인방법

  @override
  CustomRequest get json {
    return makeFunction(module, job)!;
  }

  @override
  Future<CustomResponse> fetch(String username) async {
    return await json.fetch(username);
  }

  @override
  Future<void> post() async {
    CustomResponse response = await fetch(username);
    response.Output.Result.json.forEach((key, value) {
      print('$key: $value');
      controller.addResult('$key: $value');
    });
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}
