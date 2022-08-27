import 'package:flutter/material.dart';

import '../dto/dto.dart';

abstract class MTSInterface {
  List<Text> result = [];

  CustomRequest get json {
    throw UnimplementedError();
  }

  Future<CustomResponse> fetch() {
    throw UnimplementedError();
  }

  Future post() {
    throw UnimplementedError();
  }

  @override
  String toString() => json.toString();

  addResult(String value) {
    result.add(Text(value));
  }
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
