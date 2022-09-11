// 🌎 Project imports:
import '../mts.dart';

abstract class MTSInterface {
  MtsController controller = MtsController.get();

  CustomRequest get json {
    throw UnimplementedError();
  }

  Future<CustomResponse> fetch(String username) {
    throw UnimplementedError();
  }

  Future post(String username) {
    throw UnimplementedError();
  }

  @override
  String toString() => json.toString();
}

abstract class IOBase {
  IOBase();
  get json {}
  IOBase.from();
}

abstract class InputOutput {
  InputOutput();
  get data;
  Future fetch(String username) async {}
}
