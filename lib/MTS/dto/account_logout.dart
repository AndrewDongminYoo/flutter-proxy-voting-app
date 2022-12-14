// ๐ Project imports:
import '../mts.dart';

class LogoutRequest implements MTSInterface {
  LogoutRequest(
    this.module,
    this.username,
    this.idOrCert,
  );

  final CustomModule module; // ๊ธ์ต์ฌ
  final String job = '๋ก๊ทธ์์';
  final String username; // ์ฌ์ฉ์๋ช
  final String idOrCert; // ๋ก๊ทธ์ธ๋ฐฉ๋ฒ

  @override
  CustomRequest get json {
    return makeFunction(module, job)!;
  }

  @override
  Future<CustomResponse> apply(String username) async {
    return await json.send(username);
  }

  @override
  Future<void> post() async {
    CustomResponse response = await apply(username);
    response.Output.Result.json.forEach((String key, dynamic value) {
      print('$key: $value');
    });
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();
}
