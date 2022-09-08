part of '../parser.dart';

class CssTokenizerState {
  final int index;
  final int startIndex;
  final bool inSelectorExpression;
  final bool inSelector;

  CssTokenizerState(CssTokenizerBase base)
      : index = base._index,
        startIndex = base._startIndex,
        inSelectorExpression = base.inSelectorExpression,
        inSelector = base.inSelector;
}

abstract class CssTokenizerBase {
  final SourceFile _file;
  final String _text;

  bool inString;

  bool inSelectorExpression = false;

  bool inSelector = false;

  int _index = 0;
  int _startIndex = 0;

  CssTokenizerBase(this._file, this._text, this.inString, [this._index = 0]);

  CssToken next();
  int getIdentifierKind();

  CssTokenizerState get mark => CssTokenizerState(this);

  void restore(CssTokenizerState markedData) {
    _index = markedData.index;
    _startIndex = markedData.startIndex;
    inSelectorExpression = markedData.inSelectorExpression;
    inSelector = markedData.inSelector;
  }

  int _nextChar() {
    if (_index < _text.length) {
      return _text.codeUnitAt(_index++);
    } else {
      return 0;
    }
  }

  int _peekChar([int offset = 0]) {
    if (_index + offset < _text.length) {
      return _text.codeUnitAt(_index + offset);
    } else {
      return 0;
    }
  }

  bool _maybeEatChar(int ch) {
    if (_index < _text.length) {
      if (_text.codeUnitAt(_index) == ch) {
        _index++;
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool _nextCharsAreNumber(int first) {
    if (TokenizerHelpers.isDigit(first)) return true;
    int second = _peekChar();
    if (first == CssTokenChar.DOT) return TokenizerHelpers.isDigit(second);
    if (first == CssTokenChar.PLUS || first == CssTokenChar.MINUS) {
      return TokenizerHelpers.isDigit(second) ||
          (second == CssTokenChar.DOT &&
              TokenizerHelpers.isDigit(_peekChar(1)));
    }
    return false;
  }

  CssToken _finishToken(int kind) {
    return CssToken(kind, _file.span(_startIndex, _index));
  }

  CssToken _errorToken([String? message]) {
    return CssErrorToken(
        CssTokenKind.ERROR, _file.span(_startIndex, _index), message);
  }

  CssToken finishWhitespace() {
    _index--;
    while (_index < _text.length) {
      final int ch = _text.codeUnitAt(_index++);
      if (ch == CssTokenChar.SPACE ||
          ch == CssTokenChar.TAB ||
          ch == CssTokenChar.RETURN) {
      } else if (ch == CssTokenChar.NEWLINE) {
        if (!inString) {}
      } else {
        _index--;
        if (inString) {
          return next();
        } else {
          return _finishToken(CssTokenKind.WHITESPACE);
        }
      }
    }
    return _finishToken(CssTokenKind.END_OF_FILE);
  }

  CssToken finishMultiLineComment() {
    int nesting = 1;
    do {
      int ch = _nextChar();
      if (ch == 0) {
        return _errorToken();
      } else if (ch == CssTokenChar.ASTERISK) {
        if (_maybeEatChar(CssTokenChar.SLASH)) {
          nesting--;
        }
      } else if (ch == CssTokenChar.SLASH) {
        if (_maybeEatChar(CssTokenChar.ASTERISK)) {
          nesting++;
        }
      }
    } while (nesting > 0);

    if (inString) {
      return next();
    } else {
      return _finishToken(CssTokenKind.COMMENT);
    }
  }

  void eatDigits() {
    while (_index < _text.length) {
      if (TokenizerHelpers.isDigit(_text.codeUnitAt(_index))) {
        _index++;
      } else {
        return;
      }
    }
  }

  static int _hexDigit(int c) {
    if (c >= 48 /*0*/ && c <= 57 /*9*/) {
      return c - 48;
    } else if (c >= 97 /*a*/ && c <= 102 /*f*/) {
      return c - 87;
    } else if (c >= 65 /*A*/ && c <= 70 /*F*/) {
      return c - 55;
    } else {
      return -1;
    }
  }

  int readHex([int? hexLength]) {
    int maxIndex;
    if (hexLength == null) {
      maxIndex = _text.length - 1;
    } else {
      maxIndex = _index + hexLength;
      if (maxIndex >= _text.length) return -1;
    }
    int result = 0;
    while (_index < maxIndex) {
      final int digit = _hexDigit(_text.codeUnitAt(_index));
      if (digit == -1) {
        if (hexLength == null) {
          return result;
        } else {
          return -1;
        }
      }
      _hexDigit(_text.codeUnitAt(_index));
      result = (result * 16) + digit;
      _index++;
    }

    return result;
  }

  CssToken finishNumber() {
    eatDigits();

    if (_peekChar() == CssTokenChar.DOT) {
      _nextChar();
      if (TokenizerHelpers.isDigit(_peekChar())) {
        eatDigits();
        return finishNumberExtra(CssTokenKind.DOUBLE);
      } else {
        _index--;
      }
    }

    return finishNumberExtra(CssTokenKind.INTEGER);
  }

  CssToken finishNumberExtra(int kind) {
    if (_maybeEatChar(101 /*e*/) || _maybeEatChar(69 /*E*/)) {
      kind = CssTokenKind.DOUBLE;
      _maybeEatChar(CssTokenKind.MINUS);
      _maybeEatChar(CssTokenKind.PLUS);
      eatDigits();
    }
    if (_peekChar() != 0 && TokenizerHelpers.isIdentifierStart(_peekChar())) {
      _nextChar();
      return _errorToken('illegal character in number');
    }

    return _finishToken(kind);
  }

  CssToken _makeStringToken(List<int> buf, bool isPart) {
    final String s = String.fromCharCodes(buf);
    final int kind = isPart ? CssTokenKind.STRING_PART : CssTokenKind.STRING;
    return CssLiteralToken(kind, _file.span(_startIndex, _index), s);
  }

  CssToken makeIEFilter(int start, int end) {
    String filter = _text.substring(start, end);
    return CssLiteralToken(CssTokenKind.STRING, _file.span(start, end), filter);
  }

  CssToken _makeRawStringToken(bool isMultiline) {
    String s;
    if (isMultiline) {
      int start = _startIndex + 4;
      if (_text[start] == '\n') start++;
      s = _text.substring(start, _index - 3);
    } else {
      s = _text.substring(_startIndex + 2, _index - 1);
    }
    return CssLiteralToken(
        CssTokenKind.STRING, _file.span(_startIndex, _index), s);
  }

  CssToken finishMultilineString(int quote) {
    List<int> buf = <int>[];
    while (true) {
      int ch = _nextChar();
      if (ch == 0) {
        return _errorToken();
      } else if (ch == quote) {
        if (_maybeEatChar(quote)) {
          if (_maybeEatChar(quote)) {
            return _makeStringToken(buf, false);
          }
          buf.add(quote);
        }
        buf.add(quote);
      } else if (ch == CssTokenChar.BACKSLASH) {
        int escapeVal = readEscapeSequence();
        if (escapeVal == -1) {
          return _errorToken('invalid hex escape sequence');
        } else {
          buf.add(escapeVal);
        }
      } else {
        buf.add(ch);
      }
    }
  }

  CssToken finishString(int quote) {
    if (_maybeEatChar(quote)) {
      if (_maybeEatChar(quote)) {
        _maybeEatChar(CssTokenChar.NEWLINE);
        return finishMultilineString(quote);
      } else {
        return _makeStringToken(<int>[], false);
      }
    }
    return finishStringBody(quote);
  }

  CssToken finishRawString(int quote) {
    if (_maybeEatChar(quote)) {
      if (_maybeEatChar(quote)) {
        return finishMultilineRawString(quote);
      } else {
        return _makeStringToken(<int>[], false);
      }
    }
    while (true) {
      int ch = _nextChar();
      if (ch == quote) {
        return _makeRawStringToken(false);
      } else if (ch == 0) {
        return _errorToken();
      }
    }
  }

  CssToken finishMultilineRawString(int quote) {
    while (true) {
      int ch = _nextChar();
      if (ch == 0) {
        return _errorToken();
      } else if (ch == quote && _maybeEatChar(quote) && _maybeEatChar(quote)) {
        return _makeRawStringToken(true);
      }
    }
  }

  CssToken finishStringBody(int quote) {
    List<int> buf = <int>[];
    while (true) {
      int ch = _nextChar();
      if (ch == quote) {
        return _makeStringToken(buf, false);
      } else if (ch == 0) {
        return _errorToken();
      } else if (ch == CssTokenChar.BACKSLASH) {
        int escapeVal = readEscapeSequence();
        if (escapeVal == -1) {
          return _errorToken('invalid hex escape sequence');
        } else {
          buf.add(escapeVal);
        }
      } else {
        buf.add(ch);
      }
    }
  }

  int readEscapeSequence() {
    final int ch = _nextChar();
    int hexValue;
    switch (ch) {
      case 110 /*n*/ :
        return CssTokenChar.NEWLINE;
      case 114 /*r*/ :
        return CssTokenChar.RETURN;
      case 102 /*f*/ :
        return CssTokenChar.FF;
      case 98 /*b*/ :
        return CssTokenChar.BACKSPACE;
      case 116 /*t*/ :
        return CssTokenChar.TAB;
      case 118 /*v*/ :
        return CssTokenChar.FF;
      case 120 /*x*/ :
        hexValue = readHex(2);
        break;
      case 117 /*u*/ :
        if (_maybeEatChar(CssTokenChar.LBRACE)) {
          hexValue = readHex();
          if (!_maybeEatChar(CssTokenChar.RBRACE)) {
            return -1;
          }
        } else {
          hexValue = readHex(4);
        }
        break;
      default:
        return ch;
    }

    if (hexValue == -1) return -1;

    if (hexValue < 0xD800 || hexValue > 0xDFFF && hexValue <= 0xFFFF) {
      return hexValue;
    } else if (hexValue <= 0x10FFFF) {
      messages.error('unicode values greater than 2 bytes not implemented yet',
          _file.span(_startIndex, _startIndex + 1));
      return -1;
    } else {
      return -1;
    }
  }

  CssToken finishDot() {
    if (TokenizerHelpers.isDigit(_peekChar())) {
      eatDigits();
      return finishNumberExtra(CssTokenKind.DOUBLE);
    } else {
      return _finishToken(CssTokenKind.DOT);
    }
  }
}
