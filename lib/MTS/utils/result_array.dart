// 🎯 Dart imports:
import 'dart:collection' show SetBase;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// TODO: 직접 결과물 보여줄 리스트. 나중에 제거할 것.
class TextList extends SetBase<Text> {
  final Set<Text> _list = {};

  @override
  int get length => _list.length;

  @override
  bool add(dynamic value) {
    Text text;
    if (value is Text) {
      text = value;
    } else if (value is String) {
      text = Text(value);
    } else {
      text = Text(value.toString());
    }
    return _list.add(text);
  }

  @override
  void clear() => _list.clear();

  @override
  bool contains(Object? element) {
    return _list.contains(element);
  }

  @override
  Iterator<Text> get iterator => _list.iterator;

  @override
  Text? lookup(Object? element) => _list.lookup(element);

  @override
  bool remove(Object? value) => _list.remove(value);

  @override
  Set<Text> toSet() {
    return _list.toSet();
  }
}
