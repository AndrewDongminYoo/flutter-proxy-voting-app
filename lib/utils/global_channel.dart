// 🐦 Flutter imports:
import 'package:flutter/services.dart';

MethodChannel? _channel;

MethodChannel get channel {
  if (_channel != null) {
    return _channel!;
  } else {
    _channel = const MethodChannel('flutter.native.dev/info');
    return _channel!;
  }
}
