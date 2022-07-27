// 🐦 Flutter imports:
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SharedPreferences', () {
    const String testString = 'hello world';
    const bool testBool = true;
    const int testInt = 42;
    const double testDouble = 3.14159;
    const List<String> testList = <String>['foo', 'bar'];
    const Map<String, Object> testValues = <String, Object>{
      'flutter.String': testString,
      'flutter.bool': testBool,
      'flutter.int': testInt,
      'flutter.double': testDouble,
      'flutter.List': testList,
    };

    late FakeSharedPreferencesStore store;
    late SharedPreferences preferences;

    setUp(() async {
      store = FakeSharedPreferencesStore(testValues);
      SharedPreferencesStorePlatform.instance = store;
      preferences = await SharedPreferences.getInstance();
      store.log.clear();
    });

    test('reading', () async {
      expect(preferences.get('String'), testString);
      expect(preferences.get('bool'), testBool);
      expect(preferences.get('int'), testInt);
      expect(preferences.get('double'), testDouble);
      expect(preferences.get('List'), testList);
      expect(preferences.getString('String'), testString);
      expect(preferences.getBool('bool'), testBool);
      expect(preferences.getInt('int'), testInt);
      expect(preferences.getDouble('double'), testDouble);
      expect(preferences.getStringList('List'), testList);
      expect(store.log, <Matcher>[]);
    });
  });
}

class FakeSharedPreferencesStore implements SharedPreferencesStorePlatform {
  FakeSharedPreferencesStore(Map<String, Object> data)
      : backend = InMemorySharedPreferencesStore.withData(data);

  final InMemorySharedPreferencesStore backend;
  final List<MethodCall> log = <MethodCall>[];

  @override
  bool get isMock => true;

  @override
  Future<bool> clear() {
    log.add(const MethodCall('clear'));
    return backend.clear();
  }

  @override
  Future<Map<String, Object>> getAll() {
    log.add(const MethodCall('getAll'));
    return backend.getAll();
  }

  @override
  Future<bool> remove(String key) {
    log.add(MethodCall('remove', key));
    return backend.remove(key);
  }

  @override
  Future<bool> setValue(String valueType, String key, Object value) {
    log.add(MethodCall('setValue', <dynamic>[valueType, key, value]));
    return backend.setValue(valueType, key, value);
  }
}
