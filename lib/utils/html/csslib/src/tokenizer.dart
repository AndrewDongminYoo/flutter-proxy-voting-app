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
  Token next({bool unicodeRange = false}) {
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
        return _finishToken(TokenKind.END_OF_FILE);
      case TokenChar.AT:
        int peekCh = _peekChar();
        if (TokenizerHelpers.isIdentifierStart(peekCh)) {
          var oldIndex = _index;
          var oldStartIndex = _startIndex;

          _startIndex = _index;
          ch = _nextChar();
          finishIdentifier();

          var tokId = TokenKind.matchDirectives(
              _text, _startIndex, _index - _startIndex);
          if (tokId == -1) {
            tokId = TokenKind.matchMarginDirectives(
                _text, _startIndex, _index - _startIndex);
          }

          if (tokId != -1) {
            return _finishToken(tokId);
          } else {
            _startIndex = oldStartIndex;
            _index = oldIndex;
          }
        }
        return _finishToken(TokenKind.AT);
      case TokenChar.DOT:
        var start = _startIndex;
        if (maybeEatDigit()) {
          var number = finishNumber();
          if (number.kind == TokenKind.INTEGER) {
            _startIndex = start;
            return _finishToken(TokenKind.DOUBLE);
          } else {
            return _errorToken();
          }
        }

        return _finishToken(TokenKind.DOT);
      case TokenChar.LPAREN:
        return _finishToken(TokenKind.LPAREN);
      case TokenChar.RPAREN:
        return _finishToken(TokenKind.RPAREN);
      case TokenChar.LBRACE:
        return _finishToken(TokenKind.LBRACE);
      case TokenChar.RBRACE:
        return _finishToken(TokenKind.RBRACE);
      case TokenChar.LBRACK:
        return _finishToken(TokenKind.LBRACK);
      case TokenChar.RBRACK:
        if (_maybeEatChar(TokenChar.RBRACK) &&
            _maybeEatChar(TokenChar.GREATER)) {
          return next();
        }
        return _finishToken(TokenKind.RBRACK);
      case TokenChar.HASH:
        return _finishToken(TokenKind.HASH);
      case TokenChar.PLUS:
        if (_nextCharsAreNumber(ch)) return finishNumber();
        return _finishToken(TokenKind.PLUS);
      case TokenChar.MINUS:
        if (inSelectorExpression || unicodeRange) {
          return _finishToken(TokenKind.MINUS);
        } else if (_nextCharsAreNumber(ch)) {
          return finishNumber();
        } else if (TokenizerHelpers.isIdentifierStart(ch)) {
          return finishIdentifier();
        }
        return _finishToken(TokenKind.MINUS);
      case TokenChar.GREATER:
        return _finishToken(TokenKind.GREATER);
      case TokenChar.TILDE:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(TokenKind.INCLUDES);
        }
        return _finishToken(TokenKind.TILDE);
      case TokenChar.ASTERISK:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(TokenKind.SUBSTRING_MATCH);
        }
        return _finishToken(TokenKind.ASTERISK);
      case TokenChar.AMPERSAND:
        return _finishToken(TokenKind.AMPERSAND);
      case TokenChar.NAMESPACE:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(TokenKind.DASH_MATCH);
        }
        return _finishToken(TokenKind.NAMESPACE);
      case TokenChar.COLON:
        return _finishToken(TokenKind.COLON);
      case TokenChar.COMMA:
        return _finishToken(TokenKind.COMMA);
      case TokenChar.SEMICOLON:
        return _finishToken(TokenKind.SEMICOLON);
      case TokenChar.PERCENT:
        return _finishToken(TokenKind.PERCENT);
      case TokenChar.SINGLE_QUOTE:
        return _finishToken(TokenKind.SINGLE_QUOTE);
      case TokenChar.DOUBLE_QUOTE:
        return _finishToken(TokenKind.DOUBLE_QUOTE);
      case TokenChar.SLASH:
        if (_maybeEatChar(TokenChar.ASTERISK)) return finishMultiLineComment();
        return _finishToken(TokenKind.SLASH);
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
        return _finishToken(TokenKind.LESS);
      case TokenChar.EQUALS:
        return _finishToken(TokenKind.EQUALS);
      case TokenChar.CARET:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(TokenKind.PREFIX_MATCH);
        }
        return _finishToken(TokenKind.CARET);
      case TokenChar.DOLLAR:
        if (_maybeEatChar(TokenChar.EQUALS)) {
          return _finishToken(TokenKind.SUFFIX_MATCH);
        }
        return _finishToken(TokenKind.DOLLAR);
      case TokenChar.BANG:
        return finishIdentifier();
      default:
        if (!inSelector && ch == TokenChar.BACKSLASH) {
          return _finishToken(TokenKind.BACKSLASH);
        }

        if (unicodeRange) {
          if (maybeEatHexDigit()) {
            var t = finishHexNumber();

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
          return _finishToken(TokenKind.UNICODE_RANGE);
        } else if (varDef(ch)) {
          return _finishToken(TokenKind.VAR_DEFINITION);
        } else if (varUsage(ch)) {
          return _finishToken(TokenKind.VAR_USAGE);
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
  Token _errorToken([String? message]) {
    return _finishToken(TokenKind.ERROR);
  }

  @override
  int getIdentifierKind() {
    var tokId = -1;

    if (!inSelectorExpression && !inSelector) {
      tokId = TokenKind.matchUnits(_text, _startIndex, _index - _startIndex);
    }
    if (tokId == -1) {
      tokId = (_text.substring(_startIndex, _index) == '!important')
          ? TokenKind.IMPORTANT
          : -1;
    }

    return tokId >= 0 ? tokId : TokenKind.IDENTIFIER;
  }

  Token finishIdentifier() {
    List<int> chars = <int>[];

    var validateFrom = _index;
    _index = _startIndex;
    while (_index < _text.length) {
      var ch = _text.codeUnitAt(_index);

      if (ch == 92 /*\*/ && inString) {
        var startHex = ++_index;
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

    var span = _file.span(_startIndex, _index);
    var text = String.fromCharCodes(chars);

    return IdentifierToken(text, getIdentifierKind(), span);
  }

  @override
  Token finishNumber() {
    eatDigits();

    if (_peekChar() == 46 /*.*/) {
      _nextChar();
      if (TokenizerHelpers.isDigit(_peekChar())) {
        eatDigits();
        return _finishToken(TokenKind.DOUBLE);
      } else {
        _index -= 1;
      }
    }

    return _finishToken(TokenKind.INTEGER);
  }

  bool maybeEatDigit() {
    if (_index < _text.length &&
        TokenizerHelpers.isDigit(_text.codeUnitAt(_index))) {
      _index += 1;
      return true;
    }
    return false;
  }

  Token finishHexNumber() {
    eatHexDigits(_text.length);
    return _finishToken(TokenKind.HEX_INTEGER);
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

  Token finishUnicodeRange() {
    eatQuestionMarks();
    return _finishToken(TokenKind.HEX_RANGE);
  }

  Token finishHtmlComment() {
    while (true) {
      var ch = _nextChar();
      if (ch == 0) {
        return _finishToken(TokenKind.INCOMPLETE_COMMENT);
      } else if (ch == TokenChar.MINUS) {
        /* Check if close part of Comment Definition --> (CDC). */
        if (_maybeEatChar(TokenChar.MINUS)) {
          if (_maybeEatChar(TokenChar.GREATER)) {
            if (inString) {
              return next();
            } else {
              return _finishToken(TokenKind.HTML_COMMENT);
            }
          }
        }
      }
    }
  }

  @override
  Token finishMultiLineComment() {
    while (true) {
      var ch = _nextChar();
      if (ch == 0) {
        return _finishToken(TokenKind.INCOMPLETE_COMMENT);
      } else if (ch == 42 /*'*'*/) {
        if (_maybeEatChar(47 /*'/'*/)) {
          if (inString) {
            return next();
          } else {
            return _finishToken(TokenKind.COMMENT);
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
