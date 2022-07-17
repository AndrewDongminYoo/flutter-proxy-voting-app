// 🌎 Project imports:
import 'src.dart';

class EncodingBytes {
  final String _bytes;
  int __position = -1;

  EncodingBytes(this._bytes);

  int get _length => _bytes.length;

  String _next() {
    final p = __position = __position + 1;
    if (p >= _length) {
      throw StateError('No more elements');
    } else if (p < 0) {
      throw RangeError(p);
    }
    return _bytes[p];
  }

  String _previous() {
    var p = __position;
    if (p >= _length) {
      throw StateError('No more elements');
    } else if (p < 0) {
      throw RangeError(p);
    }
    __position = p = p - 1;
    return _bytes[p];
  }

  set _position(int value) {
    if (__position >= _length) {
      throw StateError('No more elements');
    }
    __position = value;
  }

  int get _position {
    if (__position >= _length) {
      throw StateError('No more elements');
    }
    if (__position >= 0) {
      return __position;
    } else {
      return 0;
    }
  }

  String get _currentByte => _bytes[_position];

  String? _skipChars([_CharPredicate? skipChars]) {
    skipChars ??= isWhitespace;
    var p = _position;
    while (p < _length) {
      final c = _bytes[p];
      if (!skipChars(c)) {
        __position = p;
        return c;
      }
      p += 1;
    }
    __position = p;
    return null;
  }

  String? _skipUntil(_CharPredicate untilChars) {
    var p = _position;
    while (p < _length) {
      final c = _bytes[p];
      if (untilChars(c)) {
        __position = p;
        return c;
      }
      p += 1;
    }
    return null;
  }

  bool _matchBytes(String bytes) {
    final p = _position;
    if (_bytes.length < p + bytes.length) {
      return false;
    }
    final data = _bytes.substring(p, p + bytes.length);
    if (data == bytes) {
      _position += bytes.length;
      return true;
    }
    return false;
  }

  bool _jumpTo(String bytes) {
    final newPosition = _bytes.indexOf(bytes, _position);
    if (newPosition >= 0) {
      __position = newPosition + bytes.length - 1;
      return true;
    } else {
      throw StateError('No more elements');
    }
  }

  String _slice(int start, [int? end]) {
    end ??= _length;
    if (end < 0) end += _length;
    return _bytes.substring(start, end);
  }
}

typedef _MethodHandler = bool Function();

class _DispatchEntry {
  final String pattern;
  final _MethodHandler handler;

  _DispatchEntry(this.pattern, this.handler);
}

class EncodingParser {
  final EncodingBytes _data;
  String? _encoding;

  EncodingParser(List<int> bytes)
      : _data = EncodingBytes(String.fromCharCodes(bytes).toLowerCase());

  String? getEncoding() {
    final methodDispatch = [
      _DispatchEntry('<!--', _handleComment),
      _DispatchEntry('<meta', _handleMeta),
      _DispatchEntry('</', _handlePossibleEndTag),
      _DispatchEntry('<!', _handleOther),
      _DispatchEntry('<?', _handleOther),
      _DispatchEntry('<', _handlePossibleStartTag),
    ];

    try {
      for (;;) {
        for (var dispatch in methodDispatch) {
          if (_data._matchBytes(dispatch.pattern)) {
            final keepParsing = dispatch.handler();
            if (keepParsing) break;

            return _encoding;
          }
        }
        _data._position += 1;
      }
    } on StateError catch (_) {}
    return _encoding;
  }

  bool _handleComment() => _data._jumpTo('-->');

  bool _handleMeta() {
    if (!isWhitespace(_data._currentByte)) {
      return true;
    }

    while (true) {
      final attr = _getAttribute();
      if (attr == null) return true;

      if (attr[0] == 'charset') {
        final tentativeEncoding = attr[1];
        final codec = codecName(tentativeEncoding);
        if (codec != null) {
          _encoding = codec;
          return false;
        }
      } else if (attr[0] == 'content') {
        final contentParser = ContentAttrParser(EncodingBytes(attr[1]));
        final tentativeEncoding = contentParser.parse();
        final codec = codecName(tentativeEncoding);
        if (codec != null) {
          _encoding = codec;
          return false;
        }
      }
    }
  }

  bool _handlePossibleStartTag() => _handlePossibleTag(false);

  bool _handlePossibleEndTag() {
    _data._next();
    return _handlePossibleTag(true);
  }

  bool _handlePossibleTag(bool endTag) {
    if (!isLetter(_data._currentByte)) {
      if (endTag) {
        _data._previous();
        _handleOther();
      }
      return true;
    }

    final c = _data._skipUntil(_isSpaceOrAngleBracket);
    if (c == '<') {
      _data._previous();
    } else {
      var attr = _getAttribute();
      while (attr != null) {
        attr = _getAttribute();
      }
    }
    return true;
  }

  bool _handleOther() => _data._jumpTo('>');

  List<String>? _getAttribute() {
    var c = _data._skipChars((x) => x == '/' || isWhitespace(x));

    if (c == '>' || c == null) {
      return null;
    }

    final attrName = [];
    final attrValue = [];

    while (true) {
      if (c == null) {
        return null;
      } else if (c == '=' && attrName.isNotEmpty) {
        break;
      } else if (isWhitespace(c)) {
        c = _data._skipChars();
        c = _data._next();
        break;
      } else if (c == '/' || c == '>') {
        return [attrName.join(), ''];
      } else if (isLetter(c)) {
        attrName.add(c.toLowerCase());
      } else {
        attrName.add(c);
      }

      c = _data._next();
    }

    if (c != '=') {
      _data._previous();
      return [attrName.join(), ''];
    }

    _data._next();

    c = _data._skipChars();

    if (c == "'" || c == '"') {
      final quoteChar = c;
      while (true) {
        c = _data._next();
        if (c == quoteChar) {
          _data._next();
          return [attrName.join(), attrValue.join()];
        } else if (isLetter(c)) {
          attrValue.add(c.toLowerCase());
        } else {
          attrValue.add(c);
        }
      }
    } else if (c == '>') {
      return [attrName.join(), ''];
    } else if (c == null) {
      return null;
    } else if (isLetter(c)) {
      attrValue.add(c.toLowerCase());
    } else {
      attrValue.add(c);
    }

    while (true) {
      c = _data._next();
      if (_isSpaceOrAngleBracket(c)) {
        return [attrName.join(), attrValue.join()];
      } else if (isLetter(c)) {
        attrValue.add(c.toLowerCase());
      } else {
        attrValue.add(c);
      }
    }
  }
}

class ContentAttrParser {
  final EncodingBytes data;

  ContentAttrParser(this.data);

  String? parse() {
    try {
      data._jumpTo('charset');
      data._position += 1;
      data._skipChars();
      if (data._currentByte != '=') {
        return null;
      }
      data._position += 1;
      data._skipChars();

      if (data._currentByte == '"' || data._currentByte == "'") {
        final quoteMark = data._currentByte;
        data._position += 1;
        final oldPosition = data._position;
        if (data._jumpTo(quoteMark)) {
          return data._slice(oldPosition, data._position);
        } else {
          return null;
        }
      } else {
        final oldPosition = data._position;
        try {
          data._skipUntil(isWhitespace);
          return data._slice(oldPosition, data._position);
        } on StateError catch (_) {
          return data._slice(oldPosition);
        }
      }
    } on StateError catch (_) {
      return null;
    }
  }
}

bool _isSpaceOrAngleBracket(String char) {
  return char == '>' || char == '<' || isWhitespace(char);
}

typedef _CharPredicate = bool Function(String char);
