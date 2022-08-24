import 'dto/dto.dart';

abstract class MTSInterface {
  CustomRequest get json {
    throw UnimplementedError();
  }

  Future<CustomResponse> fetch() {
    throw UnimplementedError();
  }

  Future<void> post() {
    throw UnimplementedError();
  }
}
