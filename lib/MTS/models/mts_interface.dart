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

  Future post() {
    throw UnimplementedError();
  }

  @override
  String toString() => json.toString();
}

abstract class IOBase {
  IOBase();
  Map<String, dynamic> get json => {};
  IOBase.from();
}

abstract class InputOutput {
  InputOutput();
  Map<String, dynamic> get data;
  Future fetch(String username) async {}
}
