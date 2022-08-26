import '../dto/dto.dart';

abstract class MTSInterface {
  CustomRequest get json {
    throw UnimplementedError();
  }

  Future<CustomResponse> fetch() {
    throw UnimplementedError();
  }

  Future post(List<String> output) {
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
  fetch() async {}
}
