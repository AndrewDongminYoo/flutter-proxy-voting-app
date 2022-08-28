import 'package:flutter/material.dart';

import '../mts.dart';

class LogoutRequest implements MTSInterface {
  LogoutRequest(
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
  Future<void> post() async {
    CustomResponse response = await fetch();
    response.Output.Result.json.forEach((key, value) {
      print('$key: $value');
      addResult('$key: $value');
    });
  }

  @override
  String toString() => json.toString();

  @override
  late List<Text> result = MtsController.get().texts;

  @override
  addResult(String value) {
    bool valueIsNotLast = result.isNotEmpty && result.last.data != value;
    if ((valueIsNotLast) || (result.isEmpty)) {
      result.add(Text(value));
    }
  }
}
