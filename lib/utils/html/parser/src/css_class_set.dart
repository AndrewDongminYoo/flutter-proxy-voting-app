// 🎯 Dart imports:
import 'dart:collection';

// 🌎 Project imports:
import '../dom.dart';

class ElementCssClassSet extends _CssClassSetImpl {
  final Element _element;

  ElementCssClassSet(this._element);

  @override
  Set<String> readClasses() {
    // ignore: prefer_collection_literals
    final LinkedHashSet<String> s = LinkedHashSet<String>();
    final String classname = _element.className;

    for (String name in classname.split(' ')) {
      final String trimmed = name.trim();
      if (trimmed.isNotEmpty) {
        s.add(trimmed);
      }
    }
    return s;
  }

  @override
  void writeClasses(Set<String> s) {
    _element.className = s.join(' ');
  }
}

abstract class CssClassSet implements Set<String> {
  bool toggle(String value, [bool? shouldAdd]);

  bool get frozen;

  @override
  bool contains(Object? value);

  @override
  bool add(String value);

  @override
  bool remove(Object? value);

  @override
  void addAll(Iterable<String> iterable);

  @override
  void removeAll(Iterable<Object?> iterable);

  void toggleAll(Iterable<String> iterable, [bool? shouldAdd]);
}

abstract class _CssClassSetImpl extends SetBase<String> implements CssClassSet {
  @override
  String toString() {
    return readClasses().join(' ');
  }

  @override
  bool toggle(String value, [bool? shouldAdd]) {
    final Set<String> s = readClasses();
    bool result = false;
    shouldAdd ??= !s.contains(value);
    if (shouldAdd) {
      s.add(value);
      result = true;
    } else {
      s.remove(value);
    }
    writeClasses(s);
    return result;
  }

  @override
  bool get frozen => false;

  @override
  Iterator<String> get iterator => readClasses().iterator;

  @override
  int get length => readClasses().length;

  @override
  bool contains(Object? value) => readClasses().contains(value);

  @override
  String? lookup(Object? value) => contains(value) ? value as String? : null;

  @override
  Set<String> toSet() => readClasses().toSet();

  @override
  bool add(String value) {
    return _modify((s) => s.add(value));
  }

  @override
  bool remove(Object? value) {
    if (value is! String) return false;
    final Set<String> s = readClasses();
    final bool result = s.remove(value);
    writeClasses(s);
    return result;
  }

  @override
  void toggleAll(Iterable<String> iterable, [bool? shouldAdd]) {
    for (String e in iterable) {
      toggle(e, shouldAdd);
    }
  }

  bool _modify(bool Function(Set<String>) f) {
    final Set<String> s = readClasses();
    final bool ret = f(s);
    writeClasses(s);
    return ret;
  }

  Set<String> readClasses();

  void writeClasses(Set<String> s);
}
