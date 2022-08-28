// ignore_for_file: non_constant_identifier_names

part of '../parser.dart';

class Tokenizer extends TokenizerBase {
  final UNICODE_U = 'U'.codeUnitAt(0);
  final UNICODE_LOWER_U = 'u'.codeUnitAt(0);
  final UNICODE_PLUS = '+'.codeUnitAt(0);

  final QUESTION_MARK = '?'.codeUnitAt(0);

  final List<int> CDATA_NAME = 'CDATA'.codeUnits;

  Tokenizer(SourceFile file, String text, bool skipWhitespace, [int index = 0])
      : super(file, text, skipWhitespace, index);

  @override
  CssToken next({bool unicodeRange = false}) {
    _startIndex = _index;

    int ch;
    ch = _nextChar();
    switch (ch) {
      case TokenChar.NEWLINE:
      case TokenChar.RETURN:
      case TokenChar.SPACE:
      case TokenChar.TAB:
        return finishWhitespace();
      case TokenChar.END_OF_FILE:
        return _finishToken(CssTokenKind.END_OF_FILE);
      case TokenChar.AT:
        int peekCh = _peekChar();
        if (TokenizerHelpers.isIdentifierStart(peekCh)) {
          int oldIndex = _index;
          int oldStartIndex = _startIndex;

          _startIndex = _index;
          ch = _nextChar();
          finishIdentifier();

          int tokId = CssTokenKind.matchDirectives(
              _text, _startIndex, _index - _startIndex);
          if (tokId == -1) {
            tokId = CssTokenKind.matchMarginDirectives(
                _text, _startIndex, _index - _startIndex);
          }

          if (tokId != -1) {
            return _finishToken(tokId);
          } else {
            _startIndex = oldStartIndex;
            _index = oldIndex;
          }
        }
        return _finishToken(CssTokenKind.AT);
      case TokenChar.DOT:
        int start = _startIndex;
        if (maybeEatDigit()) {
          CssToken number = finishNumber();
          if (number.kind == CssTokenKind.INTEGER) {
            _startIndex = start;
            return _finishToken(CssTokenKind.DOUBLE);
          } else {
            return _errorToken();
          }
        }

        return _finishToken(CssTokenKind.DOT);
      case TokenChar.LPAREN:
        return _finishToken(CssTokenKind.LPAREN);
      case TokenChar.RPAREN:
        return _finishToken(CssTokenKind.RPAREN);
      case TokenChar.LBRACE:
        return _finishToken(CssTokenKind.LBRACE);
      case TokenChar.RBRACE:
        return _finishToken(CssTokenKind.RBRACE);
      case TokenChar.LBRACK:
        return _finishToken(CssTokenKind.LBRACK);
      case TokenChar.RBRACK:
        if (_maybeEatChar(TokenChar.RBRACK) &&
            _maybeEatChar(TokenChar.GREATER)) {
          return next();
        }
        return _finishToken(CssTokenKind.RBRACK);
      case TokenChar.HASH:
        return _finishToken(CssTokenKind.HASH);
      case TokenChar.PLUS:
        if (_nextCharsAreNumber(ch)) return finishNumber();
        return _finishToken(CssTokenKind.PLUS);
      case TokenChar.MINUS:
        if (inSelectorExpression || unicodeRange) {
          return _finishToken(CssTokenKind.MINUS);
        } else if (_nextCharsAreNumber(ch)) {
          return finishNumber();
        } else if (TokenizerHelpers.isIdentifierStart(ch)) {
          return finishIdentifier();
        }
        return _finishToken(CssTokenKind.MINUS);
      case TokenChar.GREATER:
        return _finishToken(CssTokenKind.GREATER);
      case TokenChar.TILDE:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(CssTokenKind.INCLUDES);
        }
        return _finishToken(CssTokenKind.TILDE);
      case TokenChar.ASTERISK:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(CssTokenKind.SUBSTRING_MATCH);
        }
        return _finishToken(CssTokenKind.ASTERISK);
      case TokenChar.AMPERSAND:
        return _finishToken(CssTokenKind.AMPERSAND);
      case TokenChar.NAMESPACE:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(CssTokenKind.DASH_MATCH);
        }
        return _finishToken(CssTokenKind.NAMESPACE);
      case TokenChar.COLON:
        return _finishToken(CssTokenKind.COLON);
      case TokenChar.COMMA:
        return _finishToken(CssTokenKind.COMMA);
      case TokenChar.SEMICOLON:
        return _finishToken(CssTokenKind.SEMICOLON);
      case TokenChar.PERCENT:
        return _finishToken(CssTokenKind.PERCENT);
      case TokenChar.SINGLE_QUOTE:
        return _finishToken(CssTokenKind.SINGLE_QUOTE);
      case TokenChar.DOUBLE_QUOTE:
        return _finishToken(CssTokenKind.DOUBLE_QUOTE);
      case TokenChar.SLASH:
        if (_maybeEatChar(TokenChar.ASTERISK)) return finishMultiLineComment();
        return _finishToken(CssTokenKind.SLASH);
      case TokenChar.LESS:
        if (_maybeEatChar(TokenChar.BANG)) {
          if (_maybeEatChar(TokenChar.MINUS) &&
              _maybeEatChar(TokenChar.MINUS)) {
            return finishHtmlComment();
          } else if (_maybeEatChar(TokenChar.LBRACK) &&
              _maybeEatChar(CDATA_NAME[0]) &&
              _maybeEatChar(CDATA_NAME[1]) &&
              _maybeEatChar(CDATA_NAME[2]) &&
              _maybeEatChar(CDATA_NAME[3]) &&
              _maybeEatChar(CDATA_NAME[4]) &&
              _maybeEatChar(TokenChar.LBRACK)) {
            return next();
          }
        }
        return _finishToken(CssTokenKind.LESS);
      case TokenChar.EQUALS:
        return _finishToken(CssTokenKind.EQUALS);
      case TokenChar.CARET:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(CssTokenKind.PREFIX_MATCH);
        }
        return _finishToken(CssTokenKind.CARET);
      case TokenChar.DOLLAR:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(CssTokenKind.SUFFIX_MATCH);
        }
        return _finishToken(CssTokenKind.DOLLAR);
      case TokenChar.BANG:
        return finishIdentifier();
      default:
        if (!inSelector && ch == TokenChar.BACKSLASH) {
          return _finishToken(CssTokenKind.BACKSLASH);
        }

        if (unicodeRange) {
          if (maybeEatHexDigit()) {
            CssToken t = finishHexNumber();

            if (maybeEatQuestionMark()) finishUnicodeRange();
            return t;
          } else if (maybeEatQuestionMark()) {
            return finishUnicodeRange();
          } else {
            return _errorToken();
          }
        } else if (inString &&
            (ch == UNICODE_U || ch == UNICODE_LOWER_U) &&
            (_peekChar() == UNICODE_PLUS)) {
          //

          _nextChar();
          _startIndex = _index;
          return _finishToken(CssTokenKind.UNICODE_RANGE);
        } else if (varDef(ch)) {
          return _finishToken(CssTokenKind.VAR_DEFINITION);
        } else if (varUsage(ch)) {
          return _finishToken(CssTokenKind.VAR_USAGE);
        } else if (TokenizerHelpers.isIdentifierStart(ch)) {
          return finishIdentifier();
        } else if (TokenizerHelpers.isDigit(ch)) {
          return finishNumber();
        }
        return _errorToken();
    }
  }

  bool varDef(int ch) {
    return ch == 'v'.codeUnitAt(0) &&
        _maybeEatChar('a'.codeUnitAt(0)) &&
        _maybeEatChar('r'.codeUnitAt(0)) &&
        _maybeEatChar('-'.codeUnitAt(0));
  }

  bool varUsage(int ch) {
    return ch == 'v'.codeUnitAt(0) &&
        _maybeEatChar('a'.codeUnitAt(0)) &&
        _maybeEatChar('r'.codeUnitAt(0)) &&
        (_peekChar() == '-'.codeUnitAt(0));
  }

  @override
  CssToken _errorToken([String? message]) {
    return _finishToken(CssTokenKind.ERROR);
  }

  @override
  int getIdentifierKind() {
    int tokId = -1;

    if (!inSelectorExpression && !inSelector) {
      tokId = CssTokenKind.matchUnits(_text, _startIndex, _index - _startIndex);
    }
    if (tokId == -1) {
      tokId = (_text.substring(_startIndex, _index) == '!important')
          ? CssTokenKind.IMPORTANT
          : -1;
    }

    return tokId >= 0 ? tokId : CssTokenKind.IDENTIFIER;
  }

  CssToken finishIdentifier() {
    List<int> chars = <int>[];

    int validateFrom = _index;
    _index = _startIndex;
    while (_index < _text.length) {
      int ch = _text.codeUnitAt(_index);

      if (ch == 92 /*\*/ && inString) {
        int startHex = ++_index;
        eatHexDigits(startHex + 6);
        if (_index != startHex) {
          chars.add(int.parse('0x${_text.substring(startHex, _index)}'));

          if (_index == _text.length) break;

          ch = _text.codeUnitAt(_index);
          if (_index - startHex != 6 &&
              (ch == TokenChar.SPACE ||
                  ch == TokenChar.TAB ||
                  ch == TokenChar.RETURN ||
                  ch == TokenChar.NEWLINE)) {
            _index++;
          }
        } else {
          if (_index == _text.length) break;
          chars.add(_text.codeUnitAt(_index++));
        }
      } else if (_index < validateFrom ||
          (inSelectorExpression
              ? TokenizerHelpers.isIdentifierPartExpr(ch)
              : TokenizerHelpers.isIdentifierPart(ch))) {
        chars.add(ch);
        _index++;
      } else {
        break;
      }
    }

    FileSpan span = _file.span(_startIndex, _index);
    String text = String.fromCharCodes(chars);

    return IdentifierToken(text, getIdentifierKind(), span);
  }

  @override
  CssToken finishNumber() {
    eatDigits();

    if (_peekChar() == 46 /*.*/) {
      _nextChar();
      if (TokenizerHelpers.isDigit(_peekChar())) {
        eatDigits();
        return _finishToken(CssTokenKind.DOUBLE);
      } else {
        _index -= 1;
      }
    }

    return _finishToken(CssTokenKind.INTEGER);
  }

  bool maybeEatDigit() {
    if (_index < _text.length &&
        TokenizerHelpers.isDigit(_text.codeUnitAt(_index))) {
      _index += 1;
      return true;
    }
    return false;
  }

  CssToken finishHexNumber() {
    eatHexDigits(_text.length);
    return _finishToken(CssTokenKind.HEX_INTEGER);
  }

  void eatHexDigits(int end) {
    end = math.min(end, _text.length);
    while (_index < end) {
      if (TokenizerHelpers.isHexDigit(_text.codeUnitAt(_index))) {
        _index += 1;
      } else {
        return;
      }
    }
  }

  bool maybeEatHexDigit() {
    if (_index < _text.length &&
        TokenizerHelpers.isHexDigit(_text.codeUnitAt(_index))) {
      _index += 1;
      return true;
    }
    return false;
  }

  bool maybeEatQuestionMark() {
    if (_index < _text.length && _text.codeUnitAt(_index) == QUESTION_MARK) {
      _index += 1;
      return true;
    }
    return false;
  }

  void eatQuestionMarks() {
    while (_index < _text.length) {
      if (_text.codeUnitAt(_index) == QUESTION_MARK) {
        _index += 1;
      } else {
        return;
      }
    }
  }

  CssToken finishUnicodeRange() {
    eatQuestionMarks();
    return _finishToken(CssTokenKind.HEX_RANGE);
  }

  CssToken finishHtmlComment() {
    while (true) {
      int ch = _nextChar();
      if (ch == 0) {
        return _finishToken(CssTokenKind.INCOMPLETE_COMMENT);
      } else if (ch == TokenChar.MINUS) {
        /* Check if close part of Comment Definition --> (CDC). */
        if (_maybeEatChar(TokenChar.MINUS)) {
          if (_maybeEatChar(TokenChar.GREATER)) {
            if (inString) {
              return next();
            } else {
              return _finishToken(CssTokenKind.HTML_COMMENT);
            }
          }
        }
      }
    }
  }

  @override
  CssToken finishMultiLineComment() {
    while (true) {
      int ch = _nextChar();
      if (ch == 0) {
        return _finishToken(CssTokenKind.INCOMPLETE_COMMENT);
      } else if (ch == 42 /*'*'*/) {
        if (_maybeEatChar(47 /*'/'*/)) {
          if (inString) {
            return next();
          } else {
            return _finishToken(CssTokenKind.COMMENT);
          }
        }
      }
    }
  }
}

class TokenizerHelpers {
  static bool isIdentifierStart(int c) {
    return isIdentifierStartExpr(c) || c == 45 /*-*/;
  }

  static bool isDigit(int c) {
    return (c >= 48 /*0*/ && c <= 57 /*9*/);
  }

  static bool isHexDigit(int c) {
    return (isDigit(c) ||
        (c >= 97 /*a*/ && c <= 102 /*f*/) ||
        (c >= 65 /*A*/ && c <= 70 /*F*/));
  }

  static bool isIdentifierPart(int c) {
    return isIdentifierPartExpr(c) || c == 45 /*-*/;
  }

  static bool isIdentifierStartExpr(int c) {
    return ((c >= 97 /*a*/ && c <= 122 /*z*/) ||
        (c >= 65 /*A*/ && c <= 90 /*Z*/) ||
        c == 95 /*_*/ ||
        c >= 0xA0 ||
        c == 92 /*\*/);
  }

  static bool isIdentifierPartExpr(int c) {
    return (isIdentifierStartExpr(c) || isDigit(c));
  }
}
