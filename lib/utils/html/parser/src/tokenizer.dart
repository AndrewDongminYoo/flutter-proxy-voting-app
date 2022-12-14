// 🎯 Dart imports:
import 'dart:collection' show LinkedHashMap, Queue;

// 🌎 Project imports:
import '../html.parser.dart';
import 'src.dart';

Map<String, List<String>> entitiesByFirstChar = (() {
  final Map<String, List<String>> result = <String, List<String>>{};
  for (String k in entities.keys) {
    result.putIfAbsent(k[0], () => []).add(k);
  }
  return result;
})();

class HtmlTokenizer implements Iterator<Token> {
  final HtmlInputStream stream;

  final bool lowercaseElementName;

  final bool lowercaseAttrName;

  final bool generateSpans;

  final bool attributeSpans;

  HtmlParser? parser;

  final Queue<Token?> tokenQueue;

  Token? currentToken;

  late bool Function() state;

  final StringBuffer _buffer = StringBuffer();

  late int _lastOffset;

  List<TagAttribute>? _attributes;
  Set<String>? _attributeNames;

  HtmlTokenizer(doc,
      {String? encoding,
      bool parseMeta = true,
      this.lowercaseElementName = true,
      this.lowercaseAttrName = true,
      this.generateSpans = false,
      String? sourceUrl,
      this.attributeSpans = false})
      : stream =
            HtmlInputStream(doc, encoding, parseMeta, generateSpans, sourceUrl),
        tokenQueue = Queue() {
    reset();
  }

  TagToken get currentTagToken => currentToken as TagToken;
  DoctypeToken get currentDoctypeToken => currentToken as DoctypeToken;
  StringToken get currentStringToken => currentToken as StringToken;

  Token? _current;
  @override
  Token get current => _current!;

  final StringBuffer _attributeName = StringBuffer();
  final StringBuffer _attributeValue = StringBuffer();

  void _markAttributeEnd(int offset) {
    _attributes!.last.value = '$_attributeValue';
    if (attributeSpans) _attributes!.last.end = stream.position + offset;
  }

  void _markAttributeValueStart(int offset) {
    if (attributeSpans) _attributes!.last.startValue = stream.position + offset;
  }

  void _markAttributeValueEnd(int offset) {
    if (attributeSpans) _attributes!.last.endValue = stream.position + offset;
    _markAttributeEnd(offset);
  }

  void _markAttributeNameEnd(int offset) => _markAttributeEnd(offset);

  void _addAttribute(String name) {
    _attributes ??= [];
    _attributeName.clear();
    _attributeName.write(name);
    _attributeValue.clear();
    final TagAttribute attr = TagAttribute();
    _attributes!.add(attr);
    if (attributeSpans) attr.start = stream.position - name.length;
  }

  @override
  bool moveNext() {
    while (stream.errors.isEmpty && tokenQueue.isEmpty) {
      if (!state()) {
        _current = null;
        return false;
      }
    }
    if (stream.errors.isNotEmpty) {
      _current = ParseErrorToken(stream.errors.removeFirst());
    } else {
      assert(tokenQueue.isNotEmpty);
      _current = tokenQueue.removeFirst();
    }
    return true;
  }

  void reset() {
    _lastOffset = 0;
    tokenQueue.clear();
    currentToken = null;
    _buffer.clear();
    _attributes = null;
    _attributeNames = null;
    state = dataState;
  }

  void _addToken(Token token) {
    if (generateSpans && token.span == null) {
      final int offset = stream.position;
      token.span = stream.fileInfo!.span(_lastOffset, offset);
      if (token is! ParseErrorToken) {
        _lastOffset = offset;
      }
    }
    tokenQueue.add(token);
  }

  String consumeNumberEntity(bool isHex) {
    bool Function(String?) allowed = isDigit;
    int radix = 10;
    if (isHex) {
      allowed = isHexDigit;
      radix = 16;
    }

    final List<String?> charStack = [];

    String? c = stream.char();
    while (allowed(c) && c != eof) {
      charStack.add(c);
      c = stream.char();
    }

    final int charAsInt = int.parse(charStack.join(), radix: radix);

    String? char = replacementCharacters[charAsInt];
    if (char != null) {
      _addToken(ParseErrorToken('illegal-codepoint-for-numeric-entity',
          messageParams: {'charAsInt': charAsInt}));
    } else if ((0xD800 <= charAsInt && charAsInt <= 0xDFFF) ||
        (charAsInt > 0x10FFFF)) {
      char = '\uFFFD';
      _addToken(ParseErrorToken('illegal-codepoint-for-numeric-entity',
          messageParams: {'charAsInt': charAsInt}));
    } else {
      if ((0x0001 <= charAsInt && charAsInt <= 0x0008) ||
          (0x000E <= charAsInt && charAsInt <= 0x001F) ||
          (0x007F <= charAsInt && charAsInt <= 0x009F) ||
          (0xFDD0 <= charAsInt && charAsInt <= 0xFDEF) ||
          const [
            0x000B,
            0xFFFE,
            0xFFFF,
            0x1FFFE,
            0x1FFFF,
            0x2FFFE,
            0x2FFFF,
            0x3FFFE,
            0x3FFFF,
            0x4FFFE,
            0x4FFFF,
            0x5FFFE,
            0x5FFFF,
            0x6FFFE,
            0x6FFFF,
            0x7FFFE,
            0x7FFFF,
            0x8FFFE,
            0x8FFFF,
            0x9FFFE,
            0x9FFFF,
            0xAFFFE,
            0xAFFFF,
            0xBFFFE,
            0xBFFFF,
            0xCFFFE,
            0xCFFFF,
            0xDFFFE,
            0xDFFFF,
            0xEFFFE,
            0xEFFFF,
            0xFFFFE,
            0xFFFFF,
            0x10FFFE,
            0x10FFFF
          ].contains(charAsInt)) {
        _addToken(ParseErrorToken('illegal-codepoint-for-numeric-entity',
            messageParams: {'charAsInt': charAsInt}));
      }
      char = String.fromCharCodes([charAsInt]);
    }

    if (c != ';') {
      _addToken(ParseErrorToken('numeric-entity-without-semicolon'));
      stream.unget(c);
    }
    return char;
  }

  void consumeEntity({String? allowedChar, bool fromAttribute = false}) {
    String? output = '&';

    final List<String?> charStack = [stream.char()];
    if (isWhitespace(charStack[0]) ||
        charStack[0] == '<' ||
        charStack[0] == '&' ||
        charStack[0] == eof ||
        allowedChar == charStack[0]) {
      stream.unget(charStack[0]);
    } else if (charStack[0] == '#') {
      bool hex = false;
      charStack.add(stream.char());
      if (charStack.last == 'x' || charStack.last == 'X') {
        hex = true;
        charStack.add(stream.char());
      }

      if (hex && isHexDigit(charStack.last) ||
          (!hex && isDigit(charStack.last))) {
        stream.unget(charStack.last);
        output = consumeNumberEntity(hex);
      } else {
        _addToken(ParseErrorToken('expected-numeric-entity'));
        stream.unget(charStack.removeLast());
        output = '&${charStack.join()}';
      }
    } else {
      //

      List<String> filteredEntityList =
          entitiesByFirstChar[charStack[0]!] ?? const [];

      while (charStack.last != eof) {
        final name = charStack.join();
        filteredEntityList =
            filteredEntityList.where((e) => e.startsWith(name)).toList();

        if (filteredEntityList.isEmpty) {
          break;
        }
        charStack.add(stream.char());
      }

      String? entityName;

      int entityLen;
      for (entityLen = charStack.length - 1; entityLen > 1; entityLen--) {
        final String possibleEntityName =
            charStack.sublist(0, entityLen).join();
        if (entities.containsKey(possibleEntityName)) {
          entityName = possibleEntityName;
          break;
        }
      }

      if (entityName != null) {
        final String lastChar = entityName[entityName.length - 1];
        if (lastChar != ';') {
          _addToken(ParseErrorToken('named-entity-without-semicolon'));
        }
        if (lastChar != ';' &&
            fromAttribute &&
            (isLetterOrDigit(charStack[entityLen]) ||
                charStack[entityLen] == '=')) {
          stream.unget(charStack.removeLast());
          output = '&${charStack.join()}';
        } else {
          output = entities[entityName];
          stream.unget(charStack.removeLast());
          output = '$output${slice(charStack, entityLen).join()}';
        }
      } else {
        _addToken(ParseErrorToken('expected-named-entity'));
        stream.unget(charStack.removeLast());
        output = '&${charStack.join()}';
      }
    }
    if (fromAttribute) {
      _attributeValue.write(output);
    } else {
      Token token;
      if (isWhitespace(output)) {
        token = SpaceCharactersToken(output);
      } else {
        token = CharactersToken(output);
      }
      _addToken(token);
    }
  }

  void processEntityInAttribute(String allowedChar) {
    consumeEntity(allowedChar: allowedChar, fromAttribute: true);
  }

  void emitCurrentToken() {
    final Token token = currentToken!;

    if (token is TagToken) {
      if (lowercaseElementName) {
        token.name = token.name?.toAsciiLowerCase();
      }
      if (token is EndTagToken) {
        if (_attributes != null) {
          _addToken(ParseErrorToken('attributes-in-end-tag'));
        }
        if (token.selfClosing) {
          _addToken(ParseErrorToken('this-closing-flag-on-end-tag'));
        }
      } else if (token is StartTagToken) {
        // ignore: prefer_collection_literals
        token.data = LinkedHashMap<Object, String>();
        if (_attributes != null) {
          for (TagAttribute attr in _attributes!) {
            token.data.putIfAbsent(attr.name!, () => attr.value);
          }
          if (attributeSpans) token.attributeSpans = _attributes;
        }
      }
      _attributes = null;
      _attributeNames = null;
    }
    _addToken(token);
    state = dataState;
  }

  bool dataState() {
    final String? data = stream.char();
    if (data == '&') {
      state = entityDataState;
    } else if (data == '<') {
      state = tagOpenState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\u0000'));
    } else if (data == eof) {
      return false;
    } else if (isWhitespace(data)) {
      _addToken(SpaceCharactersToken(
          '$data${stream.charsUntil(spaceCharacters, true)}'));
    } else {
      final String chars = stream.charsUntil('&<\u0000');
      _addToken(CharactersToken('$data$chars'));
    }
    return true;
  }

  bool entityDataState() {
    consumeEntity();
    state = dataState;
    return true;
  }

  bool rcdataState() {
    final String? data = stream.char();
    if (data == '&') {
      state = characterReferenceInRcdata;
    } else if (data == '<') {
      state = rcdataLessThanSignState;
    } else if (data == eof) {
      return false;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
    } else if (isWhitespace(data)) {
      _addToken(SpaceCharactersToken(
          '$data${stream.charsUntil(spaceCharacters, true)}'));
    } else {
      final String chars = stream.charsUntil('&<');
      _addToken(CharactersToken('$data$chars'));
    }
    return true;
  }

  bool characterReferenceInRcdata() {
    consumeEntity();
    state = rcdataState;
    return true;
  }

  bool rawtextState() {
    final String? data = stream.char();
    if (data == '<') {
      state = rawtextLessThanSignState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
    } else if (data == eof) {
      return false;
    } else {
      final String chars = stream.charsUntil('<\u0000');
      _addToken(CharactersToken('$data$chars'));
    }
    return true;
  }

  bool scriptDataState() {
    final String? data = stream.char();
    if (data == '<') {
      state = scriptDataLessThanSignState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
    } else if (data == eof) {
      return false;
    } else {
      final String chars = stream.charsUntil('<\u0000');
      _addToken(CharactersToken('$data$chars'));
    }
    return true;
  }

  bool plaintextState() {
    final String? data = stream.char();
    if (data == eof) {
      return false;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
    } else {
      _addToken(CharactersToken('$data${stream.charsUntil("\u0000")}'));
    }
    return true;
  }

  bool tagOpenState() {
    final String? data = stream.char();
    if (data == '!') {
      state = markupDeclarationOpenState;
    } else if (data == '/') {
      state = closeTagOpenState;
    } else if (isLetter(data)) {
      currentToken = StartTagToken(data);
      state = tagNameState;
    } else if (data == '>') {
      _addToken(ParseErrorToken('expected-tag-name-but-got-right-bracket'));
      _addToken(CharactersToken('<>'));
      state = dataState;
    } else if (data == '?') {
      _addToken(ParseErrorToken('expected-tag-name-but-got-question-mark'));
      stream.unget(data);
      state = bogusCommentState;
    } else {
      _addToken(ParseErrorToken('expected-tag-name'));
      _addToken(CharactersToken('<'));
      stream.unget(data);
      state = dataState;
    }
    return true;
  }

  bool closeTagOpenState() {
    final String? data = stream.char();
    if (isLetter(data)) {
      currentToken = EndTagToken(data);
      state = tagNameState;
    } else if (data == '>') {
      _addToken(ParseErrorToken('expected-closing-tag-but-got-right-bracket'));
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('expected-closing-tag-but-got-eof'));
      _addToken(CharactersToken('</'));
      state = dataState;
    } else {
      _addToken(ParseErrorToken('expected-closing-tag-but-got-char',
          messageParams: {'data': data}));
      stream.unget(data);
      state = bogusCommentState;
    }
    return true;
  }

  bool tagNameState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      state = beforeAttributeNameState;
    } else if (data == '>') {
      emitCurrentToken();
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-tag-name'));
      state = dataState;
    } else if (data == '/') {
      state = selfClosingStartTagState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentTagToken.name = '${currentTagToken.name}\uFFFD';
    } else {
      currentTagToken.name = '${currentTagToken.name}$data';
    }
    return true;
  }

  bool rcdataLessThanSignState() {
    final String? data = stream.char();
    if (data == '/') {
      _buffer.clear();
      state = rcdataEndTagOpenState;
    } else {
      _addToken(CharactersToken('<'));
      stream.unget(data);
      state = rcdataState;
    }
    return true;
  }

  bool rcdataEndTagOpenState() {
    final String? data = stream.char();
    if (isLetter(data)) {
      _buffer.write(data);
      state = rcdataEndTagNameState;
    } else {
      _addToken(CharactersToken('</'));
      stream.unget(data);
      state = rcdataState;
    }
    return true;
  }

  bool _tokenIsAppropriate() {
    return currentToken is TagToken &&
        currentTagToken.name!.toLowerCase() == '$_buffer'.toLowerCase();
  }

  bool rcdataEndTagNameState() {
    final bool appropriate = _tokenIsAppropriate();
    final String? data = stream.char();
    if (isWhitespace(data) && appropriate) {
      currentToken = EndTagToken('$_buffer');
      state = beforeAttributeNameState;
    } else if (data == '/' && appropriate) {
      currentToken = EndTagToken('$_buffer');
      state = selfClosingStartTagState;
    } else if (data == '>' && appropriate) {
      currentToken = EndTagToken('$_buffer');
      emitCurrentToken();
      state = dataState;
    } else if (isLetter(data)) {
      _buffer.write(data);
    } else {
      _addToken(CharactersToken('</$_buffer'));
      stream.unget(data);
      state = rcdataState;
    }
    return true;
  }

  bool rawtextLessThanSignState() {
    final String? data = stream.char();
    if (data == '/') {
      _buffer.clear();
      state = rawtextEndTagOpenState;
    } else {
      _addToken(CharactersToken('<'));
      stream.unget(data);
      state = rawtextState;
    }
    return true;
  }

  bool rawtextEndTagOpenState() {
    final String? data = stream.char();
    if (isLetter(data)) {
      _buffer.write(data);
      state = rawtextEndTagNameState;
    } else {
      _addToken(CharactersToken('</'));
      stream.unget(data);
      state = rawtextState;
    }
    return true;
  }

  bool rawtextEndTagNameState() {
    final bool appropriate = _tokenIsAppropriate();
    final String? data = stream.char();
    if (isWhitespace(data) && appropriate) {
      currentToken = EndTagToken('$_buffer');
      state = beforeAttributeNameState;
    } else if (data == '/' && appropriate) {
      currentToken = EndTagToken('$_buffer');
      state = selfClosingStartTagState;
    } else if (data == '>' && appropriate) {
      currentToken = EndTagToken('$_buffer');
      emitCurrentToken();
      state = dataState;
    } else if (isLetter(data)) {
      _buffer.write(data);
    } else {
      _addToken(CharactersToken('</$_buffer'));
      stream.unget(data);
      state = rawtextState;
    }
    return true;
  }

  bool scriptDataLessThanSignState() {
    final String? data = stream.char();
    if (data == '/') {
      _buffer.clear();
      state = scriptDataEndTagOpenState;
    } else if (data == '!') {
      _addToken(CharactersToken('<!'));
      state = scriptDataEscapeStartState;
    } else {
      _addToken(CharactersToken('<'));
      stream.unget(data);
      state = scriptDataState;
    }
    return true;
  }

  bool scriptDataEndTagOpenState() {
    final String? data = stream.char();
    if (isLetter(data)) {
      _buffer.write(data);
      state = scriptDataEndTagNameState;
    } else {
      _addToken(CharactersToken('</'));
      stream.unget(data);
      state = scriptDataState;
    }
    return true;
  }

  bool scriptDataEndTagNameState() {
    final bool appropriate = _tokenIsAppropriate();
    final String? data = stream.char();
    if (isWhitespace(data) && appropriate) {
      currentToken = EndTagToken('$_buffer');
      state = beforeAttributeNameState;
    } else if (data == '/' && appropriate) {
      currentToken = EndTagToken('$_buffer');
      state = selfClosingStartTagState;
    } else if (data == '>' && appropriate) {
      currentToken = EndTagToken('$_buffer');
      emitCurrentToken();
      state = dataState;
    } else if (isLetter(data)) {
      _buffer.write(data);
    } else {
      _addToken(CharactersToken('</$_buffer'));
      stream.unget(data);
      state = scriptDataState;
    }
    return true;
  }

  bool scriptDataEscapeStartState() {
    final String? data = stream.char();
    if (data == '-') {
      _addToken(CharactersToken('-'));
      state = scriptDataEscapeStartDashState;
    } else {
      stream.unget(data);
      state = scriptDataState;
    }
    return true;
  }

  bool scriptDataEscapeStartDashState() {
    final String? data = stream.char();
    if (data == '-') {
      _addToken(CharactersToken('-'));
      state = scriptDataEscapedDashDashState;
    } else {
      stream.unget(data);
      state = scriptDataState;
    }
    return true;
  }

  bool scriptDataEscapedState() {
    final String? data = stream.char();
    if (data == '-') {
      _addToken(CharactersToken('-'));
      state = scriptDataEscapedDashState;
    } else if (data == '<') {
      state = scriptDataEscapedLessThanSignState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
    } else if (data == eof) {
      state = dataState;
    } else {
      final String chars = stream.charsUntil('<-\u0000');
      _addToken(CharactersToken('$data$chars'));
    }
    return true;
  }

  bool scriptDataEscapedDashState() {
    final String? data = stream.char();
    if (data == '-') {
      _addToken(CharactersToken('-'));
      state = scriptDataEscapedDashDashState;
    } else if (data == '<') {
      state = scriptDataEscapedLessThanSignState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
      state = scriptDataEscapedState;
    } else if (data == eof) {
      state = dataState;
    } else {
      _addToken(CharactersToken(data));
      state = scriptDataEscapedState;
    }
    return true;
  }

  bool scriptDataEscapedDashDashState() {
    final String? data = stream.char();
    if (data == '-') {
      _addToken(CharactersToken('-'));
    } else if (data == '<') {
      state = scriptDataEscapedLessThanSignState;
    } else if (data == '>') {
      _addToken(CharactersToken('>'));
      state = scriptDataState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
      state = scriptDataEscapedState;
    } else if (data == eof) {
      state = dataState;
    } else {
      _addToken(CharactersToken(data));
      state = scriptDataEscapedState;
    }
    return true;
  }

  bool scriptDataEscapedLessThanSignState() {
    final String? data = stream.char();
    if (data == '/') {
      _buffer.clear();
      state = scriptDataEscapedEndTagOpenState;
    } else if (isLetter(data)) {
      _addToken(CharactersToken('<$data'));
      _buffer.clear();
      _buffer.write(data);
      state = scriptDataDoubleEscapeStartState;
    } else {
      _addToken(CharactersToken('<'));
      stream.unget(data);
      state = scriptDataEscapedState;
    }
    return true;
  }

  bool scriptDataEscapedEndTagOpenState() {
    final String? data = stream.char();
    if (isLetter(data)) {
      _buffer.clear();
      _buffer.write(data);
      state = scriptDataEscapedEndTagNameState;
    } else {
      _addToken(CharactersToken('</'));
      stream.unget(data);
      state = scriptDataEscapedState;
    }
    return true;
  }

  bool scriptDataEscapedEndTagNameState() {
    final bool appropriate = _tokenIsAppropriate();
    final String? data = stream.char();
    if (isWhitespace(data) && appropriate) {
      currentToken = EndTagToken('$_buffer');
      state = beforeAttributeNameState;
    } else if (data == '/' && appropriate) {
      currentToken = EndTagToken('$_buffer');
      state = selfClosingStartTagState;
    } else if (data == '>' && appropriate) {
      currentToken = EndTagToken('$_buffer');
      emitCurrentToken();
      state = dataState;
    } else if (isLetter(data)) {
      _buffer.write(data);
    } else {
      _addToken(CharactersToken('</$_buffer'));
      stream.unget(data);
      state = scriptDataEscapedState;
    }
    return true;
  }

  bool scriptDataDoubleEscapeStartState() {
    final String? data = stream.char();
    if (isWhitespace(data) || data == '/' || data == '>') {
      _addToken(CharactersToken(data));
      if ('$_buffer'.toLowerCase() == 'script') {
        state = scriptDataDoubleEscapedState;
      } else {
        state = scriptDataEscapedState;
      }
    } else if (isLetter(data)) {
      _addToken(CharactersToken(data));
      _buffer.write(data);
    } else {
      stream.unget(data);
      state = scriptDataEscapedState;
    }
    return true;
  }

  bool scriptDataDoubleEscapedState() {
    final String? data = stream.char();
    if (data == '-') {
      _addToken(CharactersToken('-'));
      state = scriptDataDoubleEscapedDashState;
    } else if (data == '<') {
      _addToken(CharactersToken('<'));
      state = scriptDataDoubleEscapedLessThanSignState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-script-in-script'));
      state = dataState;
    } else {
      _addToken(CharactersToken(data));
    }
    return true;
  }

  bool scriptDataDoubleEscapedDashState() {
    final String? data = stream.char();
    if (data == '-') {
      _addToken(CharactersToken('-'));
      state = scriptDataDoubleEscapedDashDashState;
    } else if (data == '<') {
      _addToken(CharactersToken('<'));
      state = scriptDataDoubleEscapedLessThanSignState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
      state = scriptDataDoubleEscapedState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-script-in-script'));
      state = dataState;
    } else {
      _addToken(CharactersToken(data));
      state = scriptDataDoubleEscapedState;
    }
    return true;
  }

  bool scriptDataDoubleEscapedDashDashState() {
    final String? data = stream.char();
    if (data == '-') {
      _addToken(CharactersToken('-'));
    } else if (data == '<') {
      _addToken(CharactersToken('<'));
      state = scriptDataDoubleEscapedLessThanSignState;
    } else if (data == '>') {
      _addToken(CharactersToken('>'));
      state = scriptDataState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addToken(CharactersToken('\uFFFD'));
      state = scriptDataDoubleEscapedState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-script-in-script'));
      state = dataState;
    } else {
      _addToken(CharactersToken(data));
      state = scriptDataDoubleEscapedState;
    }
    return true;
  }

  bool scriptDataDoubleEscapedLessThanSignState() {
    final String? data = stream.char();
    if (data == '/') {
      _addToken(CharactersToken('/'));
      _buffer.clear();
      state = scriptDataDoubleEscapeEndState;
    } else {
      stream.unget(data);
      state = scriptDataDoubleEscapedState;
    }
    return true;
  }

  bool scriptDataDoubleEscapeEndState() {
    final String? data = stream.char();
    if (isWhitespace(data) || data == '/' || data == '>') {
      _addToken(CharactersToken(data));
      if ('$_buffer'.toLowerCase() == 'script') {
        state = scriptDataEscapedState;
      } else {
        state = scriptDataDoubleEscapedState;
      }
    } else if (isLetter(data)) {
      _addToken(CharactersToken(data));
      _buffer.write(data);
    } else {
      stream.unget(data);
      state = scriptDataDoubleEscapedState;
    }
    return true;
  }

  bool beforeAttributeNameState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      stream.charsUntil(spaceCharacters, true);
    } else if (data != null && isLetter(data)) {
      _addAttribute(data);
      state = attributeNameState;
    } else if (data == '>') {
      emitCurrentToken();
    } else if (data == '/') {
      state = selfClosingStartTagState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('expected-attribute-name-but-got-eof'));
      state = dataState;
    } else if ("'\"=<".contains(data!)) {
      _addToken(ParseErrorToken('invalid-character-in-attribute-name'));
      _addAttribute(data);
      state = attributeNameState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addAttribute('\uFFFD');
      state = attributeNameState;
    } else {
      _addAttribute(data);
      state = attributeNameState;
    }
    return true;
  }

  bool attributeNameState() {
    final String? data = stream.char();
    bool leavingThisState = true;
    bool emitToken = false;
    if (data == '=') {
      state = beforeAttributeValueState;
    } else if (isLetter(data)) {
      _attributeName.write(data);
      _attributeName.write(stream.charsUntil(asciiLetters, true));
      leavingThisState = false;
    } else if (data == '>') {
      emitToken = true;
    } else if (isWhitespace(data)) {
      state = afterAttributeNameState;
    } else if (data == '/') {
      state = selfClosingStartTagState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _attributeName.write('\uFFFD');
      leavingThisState = false;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-attribute-name'));
      state = dataState;
    } else if ("'\"<".contains(data!)) {
      _addToken(ParseErrorToken('invalid-character-in-attribute-name'));
      _attributeName.write(data);
      leavingThisState = false;
    } else {
      _attributeName.write(data);
      leavingThisState = false;
    }

    if (leavingThisState) {
      _markAttributeNameEnd(-1);

      String attrName = _attributeName.toString();
      if (lowercaseAttrName) {
        attrName = attrName.toAsciiLowerCase();
      }
      _attributes!.last.name = attrName;
      _attributeNames ??= {};
      if (_attributeNames!.contains(attrName)) {
        _addToken(ParseErrorToken('duplicate-attribute'));
      }
      _attributeNames!.add(attrName);

      if (emitToken) {
        emitCurrentToken();
      }
    }
    return true;
  }

  bool afterAttributeNameState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      stream.charsUntil(spaceCharacters, true);
    } else if (data == '=') {
      state = beforeAttributeValueState;
    } else if (data == '>') {
      emitCurrentToken();
    } else if (data != null && isLetter(data)) {
      _addAttribute(data);
      state = attributeNameState;
    } else if (data == '/') {
      state = selfClosingStartTagState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _addAttribute('\uFFFD');
      state = attributeNameState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('expected-end-of-tag-but-got-eof'));
      state = dataState;
    } else if ("'\"<".contains(data!)) {
      _addToken(ParseErrorToken('invalid-character-after-attribute-name'));
      _addAttribute(data);
      state = attributeNameState;
    } else {
      _addAttribute(data);
      state = attributeNameState;
    }
    return true;
  }

  bool beforeAttributeValueState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      stream.charsUntil(spaceCharacters, true);
    } else if (data == '"') {
      _markAttributeValueStart(0);
      state = attributeValueDoubleQuotedState;
    } else if (data == '&') {
      state = attributeValueUnQuotedState;
      stream.unget(data);
      _markAttributeValueStart(0);
    } else if (data == "'") {
      _markAttributeValueStart(0);
      state = attributeValueSingleQuotedState;
    } else if (data == '>') {
      _addToken(
          ParseErrorToken('expected-attribute-value-but-got-right-bracket'));
      emitCurrentToken();
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _markAttributeValueStart(-1);
      _attributeValue.write('\uFFFD');
      state = attributeValueUnQuotedState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('expected-attribute-value-but-got-eof'));
      state = dataState;
    } else if ('=<`'.contains(data!)) {
      _addToken(ParseErrorToken('equals-in-unquoted-attribute-value'));
      _markAttributeValueStart(-1);
      _attributeValue.write(data);
      state = attributeValueUnQuotedState;
    } else {
      _markAttributeValueStart(-1);
      _attributeValue.write(data);
      state = attributeValueUnQuotedState;
    }
    return true;
  }

  bool attributeValueDoubleQuotedState() {
    final String? data = stream.char();
    if (data == '"') {
      _markAttributeValueEnd(-1);
      _markAttributeEnd(0);
      state = afterAttributeValueState;
    } else if (data == '&') {
      processEntityInAttribute('"');
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _attributeValue.write('\uFFFD');
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-attribute-value-double-quote'));
      _markAttributeValueEnd(-1);
      state = dataState;
    } else {
      _attributeValue.write(data);
      _attributeValue.write(stream.charsUntil('"&'));
    }
    return true;
  }

  bool attributeValueSingleQuotedState() {
    final String? data = stream.char();
    if (data == "'") {
      _markAttributeValueEnd(-1);
      _markAttributeEnd(0);
      state = afterAttributeValueState;
    } else if (data == '&') {
      processEntityInAttribute("'");
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _attributeValue.write('\uFFFD');
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-attribute-value-single-quote'));
      _markAttributeValueEnd(-1);
      state = dataState;
    } else {
      _attributeValue.write(data);
      _attributeValue.write(stream.charsUntil("'&"));
    }
    return true;
  }

  bool attributeValueUnQuotedState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      _markAttributeValueEnd(-1);
      state = beforeAttributeNameState;
    } else if (data == '&') {
      processEntityInAttribute('>');
    } else if (data == '>') {
      _markAttributeValueEnd(-1);
      emitCurrentToken();
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-attribute-value-no-quotes'));
      _markAttributeValueEnd(-1);
      state = dataState;
    } else if ('"\'=<`'.contains(data!)) {
      _addToken(
          ParseErrorToken('unexpected-character-in-unquoted-attribute-value'));
      _attributeValue.write(data);
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      _attributeValue.write('\uFFFD');
    } else {
      _attributeValue.write(data);
      _attributeValue.write(stream.charsUntil("&>\"'=<`$spaceCharacters"));
    }
    return true;
  }

  bool afterAttributeValueState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      state = beforeAttributeNameState;
    } else if (data == '>') {
      emitCurrentToken();
    } else if (data == '/') {
      state = selfClosingStartTagState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('unexpected-EOF-after-attribute-value'));
      stream.unget(data);
      state = dataState;
    } else {
      _addToken(ParseErrorToken('unexpected-character-after-attribute-value'));
      stream.unget(data);
      state = beforeAttributeNameState;
    }
    return true;
  }

  bool selfClosingStartTagState() {
    final String? data = stream.char();
    if (data == '>') {
      currentTagToken.selfClosing = true;
      emitCurrentToken();
    } else if (data == eof) {
      _addToken(ParseErrorToken('unexpected-EOF-after-solidus-in-tag'));
      stream.unget(data);
      state = dataState;
    } else {
      _addToken(ParseErrorToken('unexpected-character-after-soldius-in-tag'));
      stream.unget(data);
      state = beforeAttributeNameState;
    }
    return true;
  }

  bool bogusCommentState() {
    String data = stream.charsUntil('>');
    data = data.replaceAll('\u0000', '\uFFFD');
    _addToken(CommentToken(data));

    stream.char();
    state = dataState;
    return true;
  }

  bool markupDeclarationOpenState() {
    final List<String?> charStack = [stream.char()];
    if (charStack.last == '-') {
      charStack.add(stream.char());
      if (charStack.last == '-') {
        currentToken = CommentToken();
        state = commentStartState;
        return true;
      }
    } else if (charStack.last == 'd' || charStack.last == 'D') {
      bool matched = true;
      for (String expected in const ['oO', 'cC', 'tT', 'yY', 'pP', 'eE']) {
        final String? char = stream.char();
        charStack.add(char);
        if (char == eof || !expected.contains(char!)) {
          matched = false;
          break;
        }
      }
      if (matched) {
        currentToken = DoctypeToken(correct: true);
        state = doctypeState;
        return true;
      }
    } else if (charStack.last == '[' &&
        parser != null &&
        parser!.tree.openElements.isNotEmpty &&
        parser!.tree.openElements.last.namespaceUri !=
            parser!.tree.defaultNamespace) {
      bool matched = true;
      for (String expected in const ['C', 'D', 'A', 'T', 'A', '[']) {
        charStack.add(stream.char());
        if (charStack.last != expected) {
          matched = false;
          break;
        }
      }
      if (matched) {
        state = cdataSectionState;
        return true;
      }
    }

    _addToken(ParseErrorToken('expected-dashes-or-doctype'));

    while (charStack.isNotEmpty) {
      stream.unget(charStack.removeLast());
    }
    state = bogusCommentState;
    return true;
  }

  bool commentStartState() {
    final String? data = stream.char();
    if (data == '-') {
      state = commentStartDashState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentStringToken.add('\uFFFD');
    } else if (data == '>') {
      _addToken(ParseErrorToken('incorrect-comment'));
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-comment'));
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentStringToken.add(data!);
      state = commentState;
    }
    return true;
  }

  bool commentStartDashState() {
    final String? data = stream.char();
    if (data == '-') {
      state = commentEndState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentStringToken.add('-\uFFFD');
    } else if (data == '>') {
      _addToken(ParseErrorToken('incorrect-comment'));
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-comment'));
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentStringToken.add('-').add(data!);
      state = commentState;
    }
    return true;
  }

  bool commentState() {
    final String? data = stream.char();
    if (data == '-') {
      state = commentEndDashState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentStringToken.add('\uFFFD');
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-comment'));
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentStringToken.add(data!).add(stream.charsUntil('-\u0000'));
    }
    return true;
  }

  bool commentEndDashState() {
    final String? data = stream.char();
    if (data == '-') {
      state = commentEndState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentStringToken.add('-\uFFFD');
      state = commentState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-comment-end-dash'));
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentStringToken.add('-').add(data!);
      state = commentState;
    }
    return true;
  }

  bool commentEndState() {
    final String? data = stream.char();
    if (data == '>') {
      _addToken(currentToken!);
      state = dataState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentStringToken.add('--\uFFFD');
      state = commentState;
    } else if (data == '!') {
      _addToken(
          ParseErrorToken('unexpected-bang-after-double-dash-in-comment'));
      state = commentEndBangState;
    } else if (data == '-') {
      _addToken(
          ParseErrorToken('unexpected-dash-after-double-dash-in-comment'));
      currentStringToken.add(data!);
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-comment-double-dash'));
      _addToken(currentToken!);
      state = dataState;
    } else {
      _addToken(ParseErrorToken('unexpected-char-in-comment'));
      currentStringToken.add('--').add(data!);
      state = commentState;
    }
    return true;
  }

  bool commentEndBangState() {
    final String? data = stream.char();
    if (data == '>') {
      _addToken(currentToken!);
      state = dataState;
    } else if (data == '-') {
      currentStringToken.add('--!');
      state = commentEndDashState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentStringToken.add('--!\uFFFD');
      state = commentState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-comment-end-bang-state'));
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentStringToken.add('--!').add(data!);
      state = commentState;
    }
    return true;
  }

  bool doctypeState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      state = beforeDoctypeNameState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('expected-doctype-name-but-got-eof'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      _addToken(ParseErrorToken('need-space-after-doctype'));
      stream.unget(data);
      state = beforeDoctypeNameState;
    }
    return true;
  }

  bool beforeDoctypeNameState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      return true;
    } else if (data == '>') {
      _addToken(ParseErrorToken('expected-doctype-name-but-got-right-bracket'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentDoctypeToken.name = '\uFFFD';
      state = doctypeNameState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('expected-doctype-name-but-got-eof'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentDoctypeToken.name = data;
      state = doctypeNameState;
    }
    return true;
  }

  bool doctypeNameState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      currentDoctypeToken.name = currentDoctypeToken.name?.toAsciiLowerCase();
      state = afterDoctypeNameState;
    } else if (data == '>') {
      currentDoctypeToken.name = currentDoctypeToken.name?.toAsciiLowerCase();
      _addToken(currentToken!);
      state = dataState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentDoctypeToken.name = '${currentDoctypeToken.name}\uFFFD';
      state = doctypeNameState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype-name'));
      currentDoctypeToken.correct = false;
      currentDoctypeToken.name = currentDoctypeToken.name?.toAsciiLowerCase();
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentDoctypeToken.name = '${currentDoctypeToken.name}$data';
    }
    return true;
  }

  bool afterDoctypeNameState() {
    String? data = stream.char();
    if (isWhitespace(data)) {
      return true;
    } else if (data == '>') {
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      currentDoctypeToken.correct = false;
      stream.unget(data);
      _addToken(ParseErrorToken('eof-in-doctype'));
      _addToken(currentToken!);
      state = dataState;
    } else {
      if (data == 'p' || data == 'P') {
        bool matched = true;
        for (String expected in const ['uU', 'bB', 'lL', 'iI', 'cC']) {
          data = stream.char();
          if (data == eof || !expected.contains(data!)) {
            matched = false;
            break;
          }
        }
        if (matched) {
          state = afterDoctypePublicKeywordState;
          return true;
        }
      } else if (data == 's' || data == 'S') {
        bool matched = true;
        for (String expected in const ['yY', 'sS', 'tT', 'eE', 'mM']) {
          data = stream.char();
          if (data == eof || !expected.contains(data!)) {
            matched = false;
            break;
          }
        }
        if (matched) {
          state = afterDoctypeSystemKeywordState;
          return true;
        }
      }

      stream.unget(data);
      _addToken(ParseErrorToken('expected-space-or-right-bracket-in-doctype',
          messageParams: {'data': data}));
      currentDoctypeToken.correct = false;
      state = bogusDoctypeState;
    }
    return true;
  }

  bool afterDoctypePublicKeywordState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      state = beforeDoctypePublicIdentifierState;
    } else if (data == "'" || data == '"') {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      stream.unget(data);
      state = beforeDoctypePublicIdentifierState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      stream.unget(data);
      state = beforeDoctypePublicIdentifierState;
    }
    return true;
  }

  bool beforeDoctypePublicIdentifierState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      return true;
    } else if (data == '"') {
      currentDoctypeToken.publicId = '';
      state = doctypePublicIdentifierDoubleQuotedState;
    } else if (data == "'") {
      currentDoctypeToken.publicId = '';
      state = doctypePublicIdentifierSingleQuotedState;
    } else if (data == '>') {
      _addToken(ParseErrorToken('unexpected-end-of-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      currentDoctypeToken.correct = false;
      state = bogusDoctypeState;
    }
    return true;
  }

  bool doctypePublicIdentifierDoubleQuotedState() {
    final String? data = stream.char();
    if (data == '"') {
      state = afterDoctypePublicIdentifierState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentDoctypeToken.publicId = '${currentDoctypeToken.publicId}\uFFFD';
    } else if (data == '>') {
      _addToken(ParseErrorToken('unexpected-end-of-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentDoctypeToken.publicId = '${currentDoctypeToken.publicId}$data';
    }
    return true;
  }

  bool doctypePublicIdentifierSingleQuotedState() {
    final String? data = stream.char();
    if (data == "'") {
      state = afterDoctypePublicIdentifierState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentDoctypeToken.publicId = '${currentDoctypeToken.publicId}\uFFFD';
    } else if (data == '>') {
      _addToken(ParseErrorToken('unexpected-end-of-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentDoctypeToken.publicId = '${currentDoctypeToken.publicId}$data';
    }
    return true;
  }

  bool afterDoctypePublicIdentifierState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      state = betweenDoctypePublicAndSystemIdentifiersState;
    } else if (data == '>') {
      _addToken(currentToken!);
      state = dataState;
    } else if (data == '"') {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      currentDoctypeToken.systemId = '';
      state = doctypeSystemIdentifierDoubleQuotedState;
    } else if (data == "'") {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      currentDoctypeToken.systemId = '';
      state = doctypeSystemIdentifierSingleQuotedState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      currentDoctypeToken.correct = false;
      state = bogusDoctypeState;
    }
    return true;
  }

  bool betweenDoctypePublicAndSystemIdentifiersState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      return true;
    } else if (data == '>') {
      _addToken(currentToken!);
      state = dataState;
    } else if (data == '"') {
      currentDoctypeToken.systemId = '';
      state = doctypeSystemIdentifierDoubleQuotedState;
    } else if (data == "'") {
      currentDoctypeToken.systemId = '';
      state = doctypeSystemIdentifierSingleQuotedState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      currentDoctypeToken.correct = false;
      state = bogusDoctypeState;
    }
    return true;
  }

  bool afterDoctypeSystemKeywordState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      state = beforeDoctypeSystemIdentifierState;
    } else if (data == "'" || data == '"') {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      stream.unget(data);
      state = beforeDoctypeSystemIdentifierState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      stream.unget(data);
      state = beforeDoctypeSystemIdentifierState;
    }
    return true;
  }

  bool beforeDoctypeSystemIdentifierState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      return true;
    } else if (data == '"') {
      currentDoctypeToken.systemId = '';
      state = doctypeSystemIdentifierDoubleQuotedState;
    } else if (data == "'") {
      currentDoctypeToken.systemId = '';
      state = doctypeSystemIdentifierSingleQuotedState;
    } else if (data == '>') {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      currentDoctypeToken.correct = false;
      state = bogusDoctypeState;
    }
    return true;
  }

  bool doctypeSystemIdentifierDoubleQuotedState() {
    final String? data = stream.char();
    if (data == '"') {
      state = afterDoctypeSystemIdentifierState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentDoctypeToken.systemId = '${currentDoctypeToken.systemId}\uFFFD';
    } else if (data == '>') {
      _addToken(ParseErrorToken('unexpected-end-of-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentDoctypeToken.systemId = '${currentDoctypeToken.systemId}$data';
    }
    return true;
  }

  bool doctypeSystemIdentifierSingleQuotedState() {
    final String? data = stream.char();
    if (data == "'") {
      state = afterDoctypeSystemIdentifierState;
    } else if (data == '\u0000') {
      _addToken(ParseErrorToken('invalid-codepoint'));
      currentDoctypeToken.systemId = '${currentDoctypeToken.systemId}\uFFFD';
    } else if (data == '>') {
      _addToken(ParseErrorToken('unexpected-end-of-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      currentDoctypeToken.systemId = '${currentDoctypeToken.systemId}$data';
    }
    return true;
  }

  bool afterDoctypeSystemIdentifierState() {
    final String? data = stream.char();
    if (isWhitespace(data)) {
      return true;
    } else if (data == '>') {
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      _addToken(ParseErrorToken('eof-in-doctype'));
      currentDoctypeToken.correct = false;
      _addToken(currentToken!);
      state = dataState;
    } else {
      _addToken(ParseErrorToken('unexpected-char-in-doctype'));
      state = bogusDoctypeState;
    }
    return true;
  }

  bool bogusDoctypeState() {
    final String? data = stream.char();
    if (data == '>') {
      _addToken(currentToken!);
      state = dataState;
    } else if (data == eof) {
      stream.unget(data);
      _addToken(currentToken!);
      state = dataState;
    }
    return true;
  }

  bool cdataSectionState() {
    final List<String> data = <String>[];
    int matchedEnd = 0;
    while (true) {
      String? ch = stream.char();
      if (ch == null) {
        break;
      }

      if (ch == '\u0000') {
        _addToken(ParseErrorToken('invalid-codepoint'));
        ch = '\uFFFD';
      }
      data.add(ch);

      if (ch == ']' && matchedEnd < 2) {
        matchedEnd++;
      } else if (ch == '>' && matchedEnd == 2) {
        data.removeLast();
        data.removeLast();
        data.removeLast();
        break;
      } else {
        matchedEnd = 0;
      }
    }

    if (data.isNotEmpty) {
      _addToken(CharactersToken(data.join()));
    }
    state = dataState;
    return true;
  }
}
