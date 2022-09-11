// 🎯 Dart imports:
import 'dart:collection' show ListBase;

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../utils/exception.dart';

class TextList extends ListBase<Text> {
  final _list = [];

  @override
  int get length => _list.length;

  @override
  set length(int newLength) {
    throw CustomException("cannot handle list's length");
  }

  @override
  Text operator [](int index) {
    for (int i = 0; i < _list.length; i++) {
      if (i == index) {
        return _list[index];
      }
    }
    throw CustomException('cannot reach the index');
  }

  @override
  void operator []=(int index, Text value) {
    for (int i = 0; i < _list.length; i++) {
      if (i == index) {
        _list[index] = value;
        return;
      }
    }
    throw CustomException('cannot reach the index');
  }

  @override
  void add(dynamic element) {
    Text text;
    if (element is Text) {
      text = element;
    } else if (element is String) {
      text = Text(element);
    } else {
      text = Text(element.toString());
    }
    if (_list.isNotEmpty && _list.last != text) {
      _list.add(text);
    }
  }

  @override
  void clear() => _list.clear();
}
