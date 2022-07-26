library plugin_platform_interface;

// 📦 Package imports:
import 'package:meta/meta.dart';

abstract class PlatformInterface {
  PlatformInterface({required Object token}) : _instanceToken = token;

  final Object? _instanceToken;

  static void verify(PlatformInterface instance, Object token) {
    _verify(instance, token, preventConstObject: true);
  }

  static void verifyToken(PlatformInterface instance, Object token) {
    _verify(instance, token, preventConstObject: false);
  }

  static void _verify(
    PlatformInterface instance,
    Object token, {
    required bool preventConstObject,
  }) {
    if (instance is MockPlatformInterfaceMixin) {
      bool assertionsEnabled = false;
      assert(() {
        assertionsEnabled = true;
        return true;
      }());
      if (!assertionsEnabled) {
        throw AssertionError(
            '`MockPlatformInterfaceMixin` is not intended for use in release builds.');
      }
      return;
    }
    if (preventConstObject &&
        identical(instance._instanceToken, const Object())) {
      throw AssertionError('`const Object()` cannot be used as the token.');
    }
    if (!identical(token, instance._instanceToken)) {
      throw AssertionError(
          'Platform interfaces must not be implemented with `implements`');
    }
  }
}

@visibleForTesting
abstract class MockPlatformInterfaceMixin implements PlatformInterface {}
