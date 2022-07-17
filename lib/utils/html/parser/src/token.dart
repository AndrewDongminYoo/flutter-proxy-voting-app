// 🎯 Dart imports:
import 'dart:collection';

// 📦 Package imports:
import 'package:source_span/source_span.dart';

abstract class Token {
  FileSpan? span;

  int get kind;
}

abstract class TagToken extends Token {
  String? name;

  bool selfClosing;

  TagToken(this.name, this.selfClosing);
}

class StartTagToken extends TagToken {
  LinkedHashMap<Object, String> data;

  List<TagAttribute>? attributeSpans;

  bool selfClosingAcknowledged;

  String? namespace;

  StartTagToken(String? name,
      {LinkedHashMap<Object, String>? data,
      bool selfClosing = false,
      this.selfClosingAcknowledged = false,
      this.namespace})
      // ignore: prefer_collection_literals
      : data = data ?? LinkedHashMap(),
        super(name, selfClosing);

  @override
  int get kind => TokenKind.startTag;
}

class EndTagToken extends TagToken {
  EndTagToken(String? name, {bool selfClosing = false})
      : super(name, selfClosing);

  @override
  int get kind => TokenKind.endTag;
}

abstract class StringToken extends Token {
  StringBuffer? _buffer;

  String? _string;
  String get data {
    if (_string == null) {
      _string = _buffer.toString();
      _buffer = null;
    }
    return _string!;
  }

  StringToken(this._string) : _buffer = _string == null ? StringBuffer() : null;

  StringToken add(String data) {
    _buffer!.write(data);
    return this;
  }
}

class ParseErrorToken extends StringToken {
  Map? messageParams;

  ParseErrorToken(String data, {this.messageParams}) : super(data);

  @override
  int get kind => TokenKind.parseError;
}

class CharactersToken extends StringToken {
  CharactersToken([String? data]) : super(data);

  @override
  int get kind => TokenKind.characters;

  void replaceData(String newData) {
    _string = newData;
    _buffer = null;
  }
}

class SpaceCharactersToken extends StringToken {
  SpaceCharactersToken([String? data]) : super(data);

  @override
  int get kind => TokenKind.spaceCharacters;
}

class CommentToken extends StringToken {
  CommentToken([String? data]) : super(data);

  @override
  int get kind => TokenKind.comment;
}

class DoctypeToken extends Token {
  String? publicId;
  String? systemId;
  String? name = '';
  bool correct;

  DoctypeToken({this.publicId, this.systemId, this.correct = false});

  @override
  int get kind => TokenKind.doctype;
}

class TagAttribute {
  String? name;
  late String value;

  late int start;
  late int end;
  int? startValue;
  late int endValue;

  TagAttribute();
}

class TokenKind {
  static const int spaceCharacters = 0;
  static const int characters = 1;
  static const int startTag = 2;
  static const int endTag = 3;
  static const int comment = 4;
  static const int doctype = 5;
  static const int parseError = 6;
}
