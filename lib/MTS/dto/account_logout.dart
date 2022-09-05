// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
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
  Future<CustomResponse> fetch(String username) async {
    return await json.fetch(username);
  }

  @override
  Future<void> post(String username) async {
    CustomResponse response = await fetch(username);
    response.Output.Result.json.forEach((key, value) {
      print('$key: $value');
      addResult('$key: $value');
    });
  }

  @override
  String toString() => json.toString();

  @override
  MtsController controller = MtsController.get();

  @override
  addResult(String value) {
    bool valueIsNotLast =
        controller.texts.isNotEmpty && controller.texts.last.data != value;
    if ((valueIsNotLast) || (controller.texts.isEmpty)) {
      controller.texts.add(Text(value));
    }
  }
}
