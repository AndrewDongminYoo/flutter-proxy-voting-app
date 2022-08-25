import '../mts.dart';

class LogoutRequest implements MTSInterface {
  const LogoutRequest(
    this.module,
  );

  final CustomModule module; // 금융사
  final String job = '로그아웃';

  @override
  CustomRequest get json {
    return makeFunction(module, job)!;
  }

  @override
  Future<CustomResponse> fetch() async {
    return await json.fetch();
  }

  @override
  Future<void> post(List<String> output) async {
    CustomResponse response = await fetch();
    response.Output.Result.json.forEach((key, value) {
      print('$key: $value');
      output.add('$key: $value');
    });
  }

  @override
  String toString() => json.toString();
}
