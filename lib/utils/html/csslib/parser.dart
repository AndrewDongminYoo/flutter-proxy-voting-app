// 🎯 Dart imports:
import 'dart:math' as math;

// 📦 Package imports:
import 'package:source_span/source_span.dart'
    show FileSpan, SourceFile, SourceSpan;

// 🌎 Project imports:
import 'src/src.dart';
import 'visitor.dart';

export 'src/src.dart';

part 'src/analyzer.dart';
part 'src/polyfill.dart';
part 'src/property.dart';
part 'src/token.dart';
part 'src/token_kind.dart';
part 'src/tokenizer.dart';
part 'src/tokenizer_base.dart';

enum ClauseType {
  none,
  conjunction,
  disjunction,
}

class ParserState extends TokenizerState {
  final Token peekToken;
  final Token? previousToken;

  ParserState(this.peekToken, this.previousToken, Tokenizer tokenizer)
      : super(tokenizer);
}

void _createMessages({List<Message>? errors, PreprocessorOptions? options}) {
  errors ??= [];

  options ??= const PreprocessorOptions(useColors: false, inputFile: 'memory');

  messages = Messages(options: options, printHandler: errors.add);
}

bool get isChecked => messages.options.checked;

StyleSheet compile(input,
    {List<Message>? errors,
    PreprocessorOptions? options,
    bool nested = true,
    bool polyfill = false,
    List<StyleSheet>? includes}) {
  includes ??= [];

  var source = _inputAsString(input);

  _createMessages(errors: errors, options: options);

  var file = SourceFile.fromString(source);

  var tree = _Parser(file, source).parse();

  analyze([tree], errors: errors, options: options);

  if (polyfill) {
    var processCss = PolyFill(messages);
    processCss.process(tree, includes: includes);
  }

  return tree;
}

void analyze(List<StyleSheet> styleSheets,
    {List<Message>? errors, PreprocessorOptions? options}) {
  _createMessages(errors: errors, options: options);
  Analyzer(styleSheets, messages).run();
}

StyleSheet parse(input, {List<Message>? errors, PreprocessorOptions? options}) {
  var source = _inputAsString(input);

  _createMessages(errors: errors, options: options);

  var file = SourceFile.fromString(source);
  return _Parser(file, source).parse();
}

StyleSheet selector(input, {List<Message>? errors}) {
  var source = _inputAsString(input);

  _createMessages(errors: errors);

  var file = SourceFile.fromString(source);
  return (_Parser(file, source)..tokenizer.inSelector = true).parseSelector();
}

SelectorGroup? parseSelectorGroup(input, {List<Message>? errors}) {
  var source = _inputAsString(input);

  _createMessages(errors: errors);

  var file = SourceFile.fromString(source);
  return (_Parser(file, source)..tokenizer.inSelector = true)
      .processSelectorGroup();
}

String _inputAsString(input) {
  String source;

  if (input is String) {
    source = input;
  } else if (input is List) {
    source = String.fromCharCodes(input as List<int>);
  } else {
    throw ArgumentError("'source' must be a String or "
        'List<int> (of bytes). RandomAccessFile not supported from this '
        'simple interface');
  }

  return source;
}

class Parser {
  final _Parser _parser;

  Parser(SourceFile file, String text, {int start = 0, String? baseUrl})
      : _parser = _Parser(file, text, start: start);

  StyleSheet parse() => _parser.parse();
}

const _legacyPseudoElements = <String>{
  'after',
  'before',
  'first-letter',
  'first-line',
};

class _Parser {
  final Tokenizer tokenizer;

  final SourceFile file;

  Token? _previousToken;
  late Token _peekToken;

  _Parser(this.file, String text, {int start = 0})
      : tokenizer = Tokenizer(file, text, true, start) {
    _peekToken = tokenizer.next();
  }

  StyleSheet parse() {
    var productions = <TreeNode>[];

    var start = _peekToken.span;
    while (!_maybeEat(TokenKind.END_OF_FILE) && !_peekKind(TokenKind.RBRACE)) {
      final rule = processRule();
      if (rule != null) {
        productions.add(rule);
      } else {
        break;
      }
    }

    checkEndOfFile();

    return StyleSheet(productions, _makeSpan(start));
  }

  StyleSheet parseSelector() {
    var productions = <TreeNode>[];

    var start = _peekToken.span;
    while (!_maybeEat(TokenKind.END_OF_FILE) && !_peekKind(TokenKind.RBRACE)) {
      var selector = processSelector();
      if (selector != null) {
        productions.add(selector);
      } else {
        break;
      }
    }

    checkEndOfFile();

    return StyleSheet.selector(productions, _makeSpan(start));
  }

  void checkEndOfFile() {
    if (!(_peekKind(TokenKind.END_OF_FILE) ||
        _peekKind(TokenKind.INCOMPLETE_COMMENT))) {
      _error('premature end of file unknown CSS', _peekToken.span);
    }
  }

  bool isPrematureEndOfFile() {
    if (_maybeEat(TokenKind.END_OF_FILE)) {
      _error('unexpected end of file', _peekToken.span);
      return true;
    } else {
      return false;
    }
  }

  int _peek() {
    return _peekToken.kind;
  }

  Token _next({bool unicodeRange = false}) {
    final next = _previousToken = _peekToken;
    _peekToken = tokenizer.next(unicodeRange: unicodeRange);
    return next;
  }

  bool _peekKind(int kind) {
    return _peekToken.kind == kind;
  }

  bool _peekIdentifier() {
    return TokenKind.isIdentifier(_peekToken.kind);
  }

  ParserState get _mark => ParserState(_peekToken, _previousToken, tokenizer);

  void _restore(ParserState markedData) {
    tokenizer.restore(markedData);
    _peekToken = markedData.peekToken;
    _previousToken = markedData.previousToken;
  }

  bool _maybeEat(int kind, {bool unicodeRange = false}) {
    if (_peekToken.kind == kind) {
      _previousToken = _peekToken;
      _peekToken = tokenizer.next(unicodeRange: unicodeRange);
      return true;
    } else {
      return false;
    }
  }

  void _eat(int kind, {bool unicodeRange = false}) {
    if (!_maybeEat(kind, unicodeRange: unicodeRange)) {
      _errorExpected(TokenKind.kindToString(kind));
    }
  }

  void _errorExpected(String expected) {
    var tok = _next();
    String message;
    try {
      message = 'expected $expected, but found $tok';
    } catch (e) {
      message = 'parsing error expected $expected';
    }
    _error(message, tok.span);
  }

  void _error(String message, SourceSpan? location) {
    location ??= _peekToken.span;
    messages.error(message, location);
  }

  void _warning(String message, SourceSpan? location) {
    location ??= _peekToken.span;
    messages.warning(message, location);
  }

  SourceSpan _makeSpan(FileSpan start) {
    if (_previousToken == null || _previousToken!.span.compareTo(start) < 0) {
      return start;
    }
    return start.expand(_previousToken!.span);
  }

  List<MediaQuery> processMediaQueryList() {
    var mediaQueries = <MediaQuery>[];

    do {
      var mediaQuery = processMediaQuery();
      if (mediaQuery != null) {
        mediaQueries.add(mediaQuery);
      } else {
        break;
      }
    } while (_maybeEat(TokenKind.COMMA));

    return mediaQueries;
  }

  MediaQuery? processMediaQuery() {
    var start = _peekToken.span;

    var op = _peekToken.text;
    var opLen = op.length;
    var unaryOp = TokenKind.matchMediaOperator(op, 0, opLen);
    if (unaryOp != -1) {
      if (isChecked) {
        if (unaryOp != TokenKind.MEDIA_OP_NOT ||
            unaryOp != TokenKind.MEDIA_OP_ONLY) {
          _warning('Only the unary operators NOT and ONLY allowed',
              _makeSpan(start));
        }
      }
      _next();
      start = _peekToken.span;
    }

    Identifier? type;
    if (_peekIdentifier()) type = identifier();

    var exprs = <MediaExpression>[];

    while (true) {
      var andOp = exprs.isNotEmpty || type != null;
      if (andOp) {
        op = _peekToken.text;
        opLen = op.length;
        if (TokenKind.matchMediaOperator(op, 0, opLen) !=
            TokenKind.MEDIA_OP_AND) {
          break;
        }
        _next();
      }

      var expr = processMediaExpression(andOp);
      if (expr == null) break;

      exprs.add(expr);
    }

    if (unaryOp != -1 || type != null || exprs.isNotEmpty) {
      return MediaQuery(unaryOp, type, exprs, _makeSpan(start));
    }
    return null;
  }

  MediaExpression? processMediaExpression([bool andOperator = false]) {
    var start = _peekToken.span;

    if (_maybeEat(TokenKind.LPAREN)) {
      if (_peekIdentifier()) {
        var feature = identifier();
        var exprs = _maybeEat(TokenKind.COLON)
            ? processExpr()
            : Expressions(_makeSpan(_peekToken.span));
        if (_maybeEat(TokenKind.RPAREN)) {
          return MediaExpression(andOperator, feature, exprs, _makeSpan(start));
        } else if (isChecked) {
          _warning(
              'Missing parenthesis around media expression', _makeSpan(start));
          return null;
        }
      } else if (isChecked) {
        _warning('Missing media feature in media expression', _makeSpan(start));
      }
    }
    return null;
  }

  Directive? processDirective() {
    var start = _peekToken.span;

    var tokId = processVariableOrDirective();
    if (tokId is VarDefinitionDirective) return tokId;
    final tokenId = tokId as int;
    switch (tokenId) {
      case TokenKind.DIRECTIVE_IMPORT:
        _next();

        String? importStr;
        if (_peekIdentifier()) {
          var func = processFunction(identifier());
          if (func is UriTerm) {
            importStr = func.text;
          }
        } else {
          importStr = processQuotedString(false);
        }

        var medias = processMediaQueryList();

        if (importStr == null) {
          _error('missing import string', _peekToken.span);
        }

        return ImportDirective(importStr!.trim(), medias, _makeSpan(start));

      case TokenKind.DIRECTIVE_MEDIA:
        _next();

        var media = processMediaQueryList();

        var rules = <TreeNode>[];
        if (_maybeEat(TokenKind.LBRACE)) {
          while (!_maybeEat(TokenKind.END_OF_FILE)) {
            final rule = processRule();
            if (rule == null) break;
            rules.add(rule);
          }

          if (!_maybeEat(TokenKind.RBRACE)) {
            _error('expected } after ruleset for @media', _peekToken.span);
          }
        } else {
          _error('expected { after media before ruleset', _peekToken.span);
        }
        return MediaDirective(media, rules, _makeSpan(start));

      case TokenKind.DIRECTIVE_HOST:
        _next();

        var rules = <TreeNode>[];
        if (_maybeEat(TokenKind.LBRACE)) {
          while (!_maybeEat(TokenKind.END_OF_FILE)) {
            final rule = processRule();
            if (rule == null) break;
            rules.add(rule);
          }

          if (!_maybeEat(TokenKind.RBRACE)) {
            _error('expected } after ruleset for @host', _peekToken.span);
          }
        } else {
          _error('expected { after host before ruleset', _peekToken.span);
        }
        return HostDirective(rules, _makeSpan(start));

      case TokenKind.DIRECTIVE_PAGE:
        _next();

        Identifier? name;
        if (_peekIdentifier()) {
          name = identifier();
        }

        Identifier? pseudoPage;
        if (_maybeEat(TokenKind.COLON)) {
          if (_peekIdentifier()) {
            pseudoPage = identifier();
            if (isChecked &&
                !(pseudoPage.name == 'left' ||
                    pseudoPage.name == 'right' ||
                    pseudoPage.name == 'first')) {
              _warning(
                  'Pseudo page must be left, top or first', pseudoPage.span);
              return null;
            }
          }
        }

        var pseudoName = pseudoPage is Identifier ? pseudoPage.name : '';
        var ident = name is Identifier ? name.name : '';
        return PageDirective(
            ident, pseudoName, processMarginsDeclarations(), _makeSpan(start));

      case TokenKind.DIRECTIVE_CHARSET:
        _next();

        var charEncoding = processQuotedString(false);
        return CharsetDirective(charEncoding, _makeSpan(start));

      /*
      case TokenKind.DIRECTIVE_MS_KEYFRAMES:
        if (isChecked) {
          _warning('@-ms-keyframes should be @keyframes', _makeSpan(start));
        }
        continue keyframeDirective;

      keyframeDirective:
      */
      case TokenKind.DIRECTIVE_KEYFRAMES:
      case TokenKind.DIRECTIVE_WEB_KIT_KEYFRAMES:
      case TokenKind.DIRECTIVE_MOZ_KEYFRAMES:
      case TokenKind.DIRECTIVE_O_KEYFRAMES:
      case TokenKind.DIRECTIVE_MS_KEYFRAMES:
        if (tokenId == TokenKind.DIRECTIVE_MS_KEYFRAMES && isChecked) {
          _warning('@-ms-keyframes should be @keyframes', _makeSpan(start));
        }

        _next();

        Identifier? name;
        if (_peekIdentifier()) {
          name = identifier();
        }

        _eat(TokenKind.LBRACE);

        var keyframe = KeyFrameDirective(tokenId, name, _makeSpan(start));

        do {
          var selectors = Expressions(_makeSpan(start));

          do {
            var term = processTerm() as Expression;

            selectors.add(term);
          } while (_maybeEat(TokenKind.COMMA));

          keyframe.add(KeyFrameBlock(
              selectors, processDeclarations(), _makeSpan(start)));
        } while (!_maybeEat(TokenKind.RBRACE) && !isPrematureEndOfFile());

        return keyframe;

      case TokenKind.DIRECTIVE_FONTFACE:
        _next();
        return FontFaceDirective(processDeclarations(), _makeSpan(start));

      case TokenKind.DIRECTIVE_STYLET:
        _next();

        dynamic name;
        if (_peekIdentifier()) {
          name = identifier();
        }

        _eat(TokenKind.LBRACE);

        var productions = <TreeNode>[];

        start = _peekToken.span;
        while (!_maybeEat(TokenKind.END_OF_FILE)) {
          final rule = processRule();
          if (rule == null) {
            break;
          }
          productions.add(rule);
        }

        _eat(TokenKind.RBRACE);

        return StyletDirective(name as String, productions, _makeSpan(start));

      case TokenKind.DIRECTIVE_NAMESPACE:
        _next();

        Identifier? prefix;
        if (_peekIdentifier()) {
          prefix = identifier();
        }

        String? namespaceUri;
        if (_peekIdentifier()) {
          var func = processFunction(identifier());
          if (func is UriTerm) {
            namespaceUri = func.text;
          }
        } else {
          if (prefix != null && prefix.name == 'url') {
            var func = processFunction(prefix);
            if (func is UriTerm) {
              namespaceUri = func.text;
              prefix = null;
            }
          } else {
            namespaceUri = processQuotedString(false);
          }
        }

        return NamespaceDirective(
            prefix?.name ?? '', namespaceUri, _makeSpan(start));

      case TokenKind.DIRECTIVE_MIXIN:
        return processMixin();

      case TokenKind.DIRECTIVE_INCLUDE:
        return processInclude(_makeSpan(start));
      case TokenKind.DIRECTIVE_CONTENT:
        _warning('@content not implemented.', _makeSpan(start));
        return null;
      case TokenKind.DIRECTIVE_MOZ_DOCUMENT:
        return processDocumentDirective();
      case TokenKind.DIRECTIVE_SUPPORTS:
        return processSupportsDirective();
      case TokenKind.DIRECTIVE_VIEWPORT:
      case TokenKind.DIRECTIVE_MS_VIEWPORT:
        return processViewportDirective();
    }
    return null;
  }

  MixinDefinition? processMixin() {
    _next();

    var name = identifier();

    var params = <TreeNode>[];
    if (_maybeEat(TokenKind.LPAREN)) {
      var mustHaveParam = false;
      var keepGoing = true;
      while (keepGoing) {
        var varDef = processVariableOrDirective(mixinParameter: true);
        if (varDef is VarDefinitionDirective || varDef is VarDefinition) {
          params.add(varDef as TreeNode);
        } else if (mustHaveParam) {
          _warning('Expecting parameter', _makeSpan(_peekToken.span));
          keepGoing = false;
        }
        if (_maybeEat(TokenKind.COMMA)) {
          mustHaveParam = true;
          continue;
        }
        keepGoing = !_maybeEat(TokenKind.RPAREN);
      }
    }

    _eat(TokenKind.LBRACE);

    var productions = <TreeNode>[];
    MixinDefinition? mixinDirective;

    var start = _peekToken.span;
    while (!_maybeEat(TokenKind.END_OF_FILE)) {
      var directive = processDirective();
      if (directive != null) {
        productions.add(directive);
        continue;
      }

      var declGroup = processDeclarations(checkBrace: false);
      if (declGroup.declarations.any((decl) {
        return decl is Declaration && decl is! IncludeMixinAtDeclaration;
      })) {
        var newDecls = <Declaration>[];
        for (var include in productions) {
          if (include is IncludeDirective) {
            newDecls.add(IncludeMixinAtDeclaration(include, include.span));
          } else {
            _warning('Error mixing of top-level vs declarations mixins',
                _makeSpan(include.span as FileSpan));
          }
        }
        declGroup.declarations.insertAll(0, newDecls);
        productions = [];
      } else {
        for (var decl in declGroup.declarations) {
          productions
              .add(decl is IncludeMixinAtDeclaration ? decl.include : decl);
        }
        declGroup.declarations.clear();
      }

      if (declGroup.declarations.isNotEmpty) {
        if (productions.isEmpty) {
          mixinDirective = MixinDeclarationDirective(
              name.name, params, false, declGroup, _makeSpan(start));
          break;
        } else {
          for (var decl in declGroup.declarations) {
            productions
                .add(decl is IncludeMixinAtDeclaration ? decl.include : decl);
          }
        }
      } else {
        mixinDirective = MixinRulesetDirective(
            name.name, params, false, productions, _makeSpan(start));
        break;
      }
    }

    if (productions.isNotEmpty) {
      mixinDirective = MixinRulesetDirective(
          name.name, params, false, productions, _makeSpan(start));
    }

    _eat(TokenKind.RBRACE);

    return mixinDirective;
  }

  dynamic processVariableOrDirective({bool mixinParameter = false}) {
    var start = _peekToken.span;

    var tokId = _peek();
    if (tokId == TokenKind.AT) {
      _next();
      tokId = _peek();
      if (_peekIdentifier()) {
        var directive = _peekToken.text;
        var directiveLen = directive.length;
        tokId = TokenKind.matchDirectives(directive, 0, directiveLen);
        if (tokId == -1) {
          tokId = TokenKind.matchMarginDirectives(directive, 0, directiveLen);
        }
      }

      if (tokId == -1) {
        if (messages.options.lessSupport) {
          Identifier? name;
          if (_peekIdentifier()) {
            name = identifier();
          }

          Expressions? exprs;
          if (mixinParameter && _maybeEat(TokenKind.COLON)) {
            exprs = processExpr();
          } else if (!mixinParameter) {
            _eat(TokenKind.COLON);
            exprs = processExpr();
          }

          var span = _makeSpan(start);
          return VarDefinitionDirective(VarDefinition(name, exprs, span), span);
        } else if (isChecked) {
          _error('unexpected directive @$_peekToken', _peekToken.span);
        }
      }
    } else if (mixinParameter && _peekToken.kind == TokenKind.VAR_DEFINITION) {
      _next();
      Identifier? definedName;
      if (_peekIdentifier()) definedName = identifier();

      Expressions? exprs;
      if (_maybeEat(TokenKind.COLON)) {
        exprs = processExpr();
      }

      return VarDefinition(definedName, exprs, _makeSpan(start));
    }

    return tokId;
  }

  IncludeDirective processInclude(SourceSpan span, {bool eatSemiColon = true}) {
    _next();

    Identifier? name;
    if (_peekIdentifier()) {
      name = identifier();
    }

    var params = <List<Expression>>[];

    if (_maybeEat(TokenKind.LPAREN)) {
      var terms = <Expression>[];
      dynamic expr;
      var keepGoing = true;
      while (keepGoing && (expr = processTerm()) != null) {
        terms.add((expr is List ? expr[0] : expr) as Expression);
        keepGoing = !_peekKind(TokenKind.RPAREN);
        if (keepGoing) {
          if (_maybeEat(TokenKind.COMMA)) {
            params.add(terms);
            terms = [];
          }
        }
      }
      params.add(terms);
      _maybeEat(TokenKind.RPAREN);
    }

    if (eatSemiColon) {
      _eat(TokenKind.SEMICOLON);
    }

    return IncludeDirective(name!.name, params, span);
  }

  DocumentDirective processDocumentDirective() {
    var start = _peekToken.span;
    _next();
    var functions = <LiteralTerm>[];
    do {
      LiteralTerm function;

      var ident = identifier();
      _eat(TokenKind.LPAREN);

      if (ident.name == 'url-prefix' || ident.name == 'domain') {
        var argumentStart = _peekToken.span;
        var value = processQuotedString(true);
        var argument = value.isNotEmpty ? '"$value"' : '';
        var argumentSpan = _makeSpan(argumentStart);

        _eat(TokenKind.RPAREN);

        var arguments = Expressions(_makeSpan(argumentSpan as FileSpan))
          ..add(LiteralTerm(argument, argument, argumentSpan));
        function = FunctionTerm(ident.name, ident.name, arguments,
            _makeSpan(ident.span as FileSpan));
      } else {
        function = processFunction(ident) as LiteralTerm;
      }

      functions.add(function);
    } while (_maybeEat(TokenKind.COMMA));

    _eat(TokenKind.LBRACE);
    var groupRuleBody = processGroupRuleBody();
    _eat(TokenKind.RBRACE);
    return DocumentDirective(functions, groupRuleBody, _makeSpan(start));
  }

  SupportsDirective processSupportsDirective() {
    var start = _peekToken.span;
    _next();
    var condition = processSupportsCondition();
    _eat(TokenKind.LBRACE);
    var groupRuleBody = processGroupRuleBody();
    _eat(TokenKind.RBRACE);
    return SupportsDirective(condition, groupRuleBody, _makeSpan(start));
  }

  SupportsCondition? processSupportsCondition() {
    if (_peekKind(TokenKind.IDENTIFIER)) {
      return processSupportsNegation();
    }

    var start = _peekToken.span;
    var conditions = <SupportsConditionInParens>[];
    var clauseType = ClauseType.none;

    while (true) {
      conditions.add(processSupportsConditionInParens());

      ClauseType type;
      var text = _peekToken.text.toLowerCase();

      if (text == 'and') {
        type = ClauseType.conjunction;
      } else if (text == 'or') {
        type = ClauseType.disjunction;
      } else {
        break;
      }

      if (clauseType == ClauseType.none) {
        clauseType = type;
      } else if (clauseType != type) {
        _error("Operators can't be mixed without a layer of parentheses",
            _peekToken.span);
        break;
      }

      _next();
    }

    if (clauseType == ClauseType.conjunction) {
      return SupportsConjunction(conditions, _makeSpan(start));
    } else if (clauseType == ClauseType.disjunction) {
      return SupportsDisjunction(conditions, _makeSpan(start));
    } else {
      return conditions.first;
    }
  }

  SupportsNegation? processSupportsNegation() {
    var start = _peekToken.span;
    var text = _peekToken.text.toLowerCase();
    if (text != 'not') return null;
    _next();
    var condition = processSupportsConditionInParens();
    return SupportsNegation(condition, _makeSpan(start));
  }

  SupportsConditionInParens processSupportsConditionInParens() {
    var start = _peekToken.span;
    _eat(TokenKind.LPAREN);
    var condition = processSupportsCondition();
    if (condition != null) {
      _eat(TokenKind.RPAREN);
      return SupportsConditionInParens.nested(condition, _makeSpan(start));
    }
    var declaration = processDeclaration([]);
    _eat(TokenKind.RPAREN);
    return SupportsConditionInParens(declaration, _makeSpan(start));
  }

  ViewportDirective processViewportDirective() {
    var start = _peekToken.span;
    var name = _next().text;
    var declarations = processDeclarations();
    return ViewportDirective(name, declarations, _makeSpan(start));
  }

  TreeNode? processRule([SelectorGroup? selectorGroup]) {
    if (selectorGroup == null) {
      final directive = processDirective();
      if (directive != null) {
        _maybeEat(TokenKind.SEMICOLON);
        return directive;
      }
      selectorGroup = processSelectorGroup();
    }
    if (selectorGroup != null) {
      return RuleSet(selectorGroup, processDeclarations(), selectorGroup.span);
    }
    return null;
  }

  List<TreeNode> processGroupRuleBody() {
    var nodes = <TreeNode>[];
    while (!(_peekKind(TokenKind.RBRACE) || _peekKind(TokenKind.END_OF_FILE))) {
      var rule = processRule();
      if (rule != null) {
        nodes.add(rule);
        continue;
      }
      break;
    }
    return nodes;
  }

  SelectorGroup? _nestedSelector() {
    var oldMessages = messages;
    _createMessages();

    var markedData = _mark;

    var selGroup = processSelectorGroup();

    var nestedSelector = selGroup != null &&
        _peekKind(TokenKind.LBRACE) &&
        messages.messages.isEmpty;

    if (!nestedSelector) {
      _restore(markedData);
      messages = oldMessages;
      return null;
    } else {
      oldMessages.mergeMessages(messages);
      messages = oldMessages;
      return selGroup;
    }
  }

  DeclarationGroup processDeclarations({bool checkBrace = true}) {
    var start = _peekToken.span;

    if (checkBrace) _eat(TokenKind.LBRACE);

    var decls = <TreeNode>[];
    var dartStyles = <DartStyleExpression>[];

    do {
      var selectorGroup = _nestedSelector();
      while (selectorGroup != null) {
        var ruleset = processRule(selectorGroup)!;
        decls.add(ruleset);
        selectorGroup = _nestedSelector();
      }

      var decl = processDeclaration(dartStyles);
      if (decl != null) {
        if (decl.hasDartStyle) {
          var newDartStyle = decl.dartStyle!;

          var replaced = false;
          for (var i = 0; i < dartStyles.length; i++) {
            var dartStyle = dartStyles[i];
            if (dartStyle.isSame(newDartStyle)) {
              dartStyles[i] = newDartStyle;
              replaced = true;
              break;
            }
          }
          if (!replaced) {
            dartStyles.add(newDartStyle);
          }
        }
        decls.add(decl);
      }
    } while (_maybeEat(TokenKind.SEMICOLON));

    if (checkBrace) _eat(TokenKind.RBRACE);

    for (var decl in decls) {
      if (decl is Declaration) {
        if (decl.hasDartStyle && !dartStyles.contains(decl.dartStyle)) {
          decl.dartStyle = null;
        }
      }
    }

    return DeclarationGroup(decls, _makeSpan(start));
  }

  List<DeclarationGroup> processMarginsDeclarations() {
    var groups = <DeclarationGroup>[];

    var start = _peekToken.span;

    _eat(TokenKind.LBRACE);

    var decls = <Declaration>[];
    var dartStyles = <DartStyleExpression>[];

    do {
      switch (_peek()) {
        case TokenKind.MARGIN_DIRECTIVE_TOPLEFTCORNER:
        case TokenKind.MARGIN_DIRECTIVE_TOPLEFT:
        case TokenKind.MARGIN_DIRECTIVE_TOPCENTER:
        case TokenKind.MARGIN_DIRECTIVE_TOPRIGHT:
        case TokenKind.MARGIN_DIRECTIVE_TOPRIGHTCORNER:
        case TokenKind.MARGIN_DIRECTIVE_BOTTOMLEFTCORNER:
        case TokenKind.MARGIN_DIRECTIVE_BOTTOMLEFT:
        case TokenKind.MARGIN_DIRECTIVE_BOTTOMCENTER:
        case TokenKind.MARGIN_DIRECTIVE_BOTTOMRIGHT:
        case TokenKind.MARGIN_DIRECTIVE_BOTTOMRIGHTCORNER:
        case TokenKind.MARGIN_DIRECTIVE_LEFTTOP:
        case TokenKind.MARGIN_DIRECTIVE_LEFTMIDDLE:
        case TokenKind.MARGIN_DIRECTIVE_LEFTBOTTOM:
        case TokenKind.MARGIN_DIRECTIVE_RIGHTTOP:
        case TokenKind.MARGIN_DIRECTIVE_RIGHTMIDDLE:
        case TokenKind.MARGIN_DIRECTIVE_RIGHTBOTTOM:
          var marginSym = _peek();

          _next();

          var declGroup = processDeclarations();
          groups.add(
              MarginGroup(marginSym, declGroup.declarations, _makeSpan(start)));
          break;
        default:
          var decl = processDeclaration(dartStyles);
          if (decl != null) {
            if (decl.hasDartStyle) {
              var newDartStyle = decl.dartStyle!;

              var replaced = false;
              for (var i = 0; i < dartStyles.length; i++) {
                var dartStyle = dartStyles[i];
                if (dartStyle.isSame(newDartStyle)) {
                  dartStyles[i] = newDartStyle;
                  replaced = true;
                  break;
                }
              }
              if (!replaced) {
                dartStyles.add(newDartStyle);
              }
            }
            decls.add(decl);
          }
          _maybeEat(TokenKind.SEMICOLON);
          break;
      }
    } while (!_maybeEat(TokenKind.RBRACE) && !isPrematureEndOfFile());

    for (var decl in decls) {
      if (decl.hasDartStyle && !dartStyles.contains(decl.dartStyle)) {
        decl.dartStyle = null;
      }
    }

    if (decls.isNotEmpty) {
      groups.add(DeclarationGroup(decls, _makeSpan(start)));
    }

    return groups;
  }

  SelectorGroup? processSelectorGroup() {
    var selectors = <Selector>[];
    var start = _peekToken.span;

    tokenizer.inSelector = true;
    do {
      var selector = processSelector();
      if (selector != null) {
        selectors.add(selector);
      }
    } while (_maybeEat(TokenKind.COMMA));
    tokenizer.inSelector = false;

    if (selectors.isNotEmpty) {
      return SelectorGroup(selectors, _makeSpan(start));
    }
    return null;
  }

  Selector? processSelector() {
    var simpleSequences = <SimpleSelectorSequence>[];
    var start = _peekToken.span;
    while (true) {
      var selectorItem = simpleSelectorSequence(simpleSequences.isEmpty);
      if (selectorItem != null) {
        simpleSequences.add(selectorItem);
      } else {
        break;
      }
    }

    if (simpleSequences.isEmpty) return null;

    return Selector(simpleSequences, _makeSpan(start));
  }

  Selector? processCompoundSelector() {
    var selector = processSelector();
    if (selector != null) {
      for (var sequence in selector.simpleSelectorSequences) {
        if (!sequence.isCombinatorNone) {
          _error('compound selector can not contain combinator', sequence.span);
        }
      }
    }
    return selector;
  }

  SimpleSelectorSequence? simpleSelectorSequence(bool forceCombinatorNone) {
    var start = _peekToken.span;
    var combinatorType = TokenKind.COMBINATOR_NONE;
    var thisOperator = false;

    switch (_peek()) {
      case TokenKind.PLUS:
        _eat(TokenKind.PLUS);
        combinatorType = TokenKind.COMBINATOR_PLUS;
        break;
      case TokenKind.GREATER:
        _eat(TokenKind.GREATER);
        combinatorType = TokenKind.COMBINATOR_GREATER;
        break;
      case TokenKind.TILDE:
        _eat(TokenKind.TILDE);
        combinatorType = TokenKind.COMBINATOR_TILDE;
        break;
      case TokenKind.AMPERSAND:
        _eat(TokenKind.AMPERSAND);
        thisOperator = true;
        break;
    }

    if (combinatorType == TokenKind.COMBINATOR_NONE && !forceCombinatorNone) {
      if (_previousToken != null && _previousToken!.end != _peekToken.start) {
        combinatorType = TokenKind.COMBINATOR_DESCENDANT;
      }
    }

    var span = _makeSpan(start);
    var simpleSel = thisOperator
        ? ElementSelector(ThisOperator(span), span)
        : simpleSelector();
    if (simpleSel == null &&
        (combinatorType == TokenKind.COMBINATOR_PLUS ||
            combinatorType == TokenKind.COMBINATOR_GREATER ||
            combinatorType == TokenKind.COMBINATOR_TILDE)) {
      simpleSel = ElementSelector(Identifier('', span), span);
    }
    if (simpleSel != null) {
      return SimpleSelectorSequence(simpleSel, span, combinatorType);
    }
    return null;
  }

  SimpleSelector? simpleSelector() {
    dynamic first;
    var start = _peekToken.span;
    switch (_peek()) {
      case TokenKind.ASTERISK:
        var tok = _next();
        first = Wildcard(_makeSpan(tok.span));
        break;
      case TokenKind.IDENTIFIER:
        first = identifier();
        break;
      default:
        if (TokenKind.isKindIdentifier(_peek())) {
          first = identifier();
        } else if (_peekKind(TokenKind.SEMICOLON)) {
          return null;
        }
        break;
    }

    if (_maybeEat(TokenKind.NAMESPACE)) {
      TreeNode? element;
      switch (_peek()) {
        case TokenKind.ASTERISK:
          var tok = _next();
          element = Wildcard(_makeSpan(tok.span));
          break;
        case TokenKind.IDENTIFIER:
          element = identifier();
          break;
        default:
          _error('expected element name or universal(*), but found $_peekToken',
              _peekToken.span);
          break;
      }

      return NamespaceSelector(
          first, ElementSelector(element, element!.span!), _makeSpan(start));
    } else if (first != null) {
      return ElementSelector(first, _makeSpan(start));
    } else {
      return simpleSelectorTail();
    }
  }

  bool _anyWhiteSpaceBeforePeekToken(int kind) {
    if (_previousToken != null && _previousToken!.kind == kind) {
      return _previousToken!.end != _peekToken.start;
    }

    return false;
  }

  SimpleSelector? simpleSelectorTail() {
    var start = _peekToken.span;
    switch (_peek()) {
      case TokenKind.HASH:
        _eat(TokenKind.HASH);

        if (_anyWhiteSpaceBeforePeekToken(TokenKind.HASH)) {
          _error('Not a valid ID selector expected #id', _makeSpan(start));
          return null;
        }
        return IdSelector(identifier(), _makeSpan(start));
      case TokenKind.DOT:
        _eat(TokenKind.DOT);

        if (_anyWhiteSpaceBeforePeekToken(TokenKind.DOT)) {
          _error('Not a valid class selector expected .className',
              _makeSpan(start));
          return null;
        }
        return ClassSelector(identifier(), _makeSpan(start));
      case TokenKind.COLON:
        return processPseudoSelector(start);
      case TokenKind.LBRACK:
        return processAttribute();
      case TokenKind.DOUBLE:
        _error('name must start with a alpha character, but found a number',
            _peekToken.span);
        _next();
        break;
    }
    return null;
  }

  SimpleSelector? processPseudoSelector(FileSpan start) {
    _eat(TokenKind.COLON);
    var pseudoElement = _maybeEat(TokenKind.COLON);

    Identifier pseudoName;
    if (_peekIdentifier()) {
      pseudoName = identifier();
    } else {
      return null;
    }
    var name = pseudoName.name.toLowerCase();

    if (_peekToken.kind == TokenKind.LPAREN) {
      if (!pseudoElement && name == 'not') {
        _eat(TokenKind.LPAREN);

        var negArg = simpleSelector();

        _eat(TokenKind.RPAREN);
        return NegationSelector(negArg, _makeSpan(start));
      } else if (!pseudoElement &&
          (name == 'host' ||
              name == 'host-context' ||
              name == 'global-context' ||
              name == '-acx-global-context')) {
        _eat(TokenKind.LPAREN);
        var selector = processCompoundSelector();
        if (selector == null) {
          _errorExpected('a selector argument');
          return null;
        }
        _eat(TokenKind.RPAREN);
        var span = _makeSpan(start);
        return PseudoClassFunctionSelector(pseudoName, selector, span);
      } else {
        tokenizer.inSelectorExpression = true;
        _eat(TokenKind.LPAREN);

        var span = _makeSpan(start);
        var expr = processSelectorExpression();

        tokenizer.inSelectorExpression = false;

        if (expr is SelectorExpression) {
          _eat(TokenKind.RPAREN);
          return (pseudoElement)
              ? PseudoElementFunctionSelector(pseudoName, expr, span)
              : PseudoClassFunctionSelector(pseudoName, expr, span);
        } else {
          _errorExpected('CSS expression');
          return null;
        }
      }
    }

    return pseudoElement || _legacyPseudoElements.contains(name)
        ? PseudoElementSelector(pseudoName, _makeSpan(start),
            isLegacy: !pseudoElement)
        : PseudoClassSelector(pseudoName, _makeSpan(start));
  }

  TreeNode /* SelectorExpression | LiteralTerm */ processSelectorExpression() {
    var start = _peekToken.span;

    var expressions = <Expression>[];

    Token? termToken;
    dynamic value;

    var keepParsing = true;
    while (keepParsing) {
      switch (_peek()) {
        case TokenKind.PLUS:
          start = _peekToken.span;
          termToken = _next();
          expressions.add(OperatorPlus(_makeSpan(start)));
          break;
        case TokenKind.MINUS:
          start = _peekToken.span;
          termToken = _next();
          expressions.add(OperatorMinus(_makeSpan(start)));
          break;
        case TokenKind.INTEGER:
          termToken = _next();
          value = int.parse(termToken.text);
          break;
        case TokenKind.DOUBLE:
          termToken = _next();
          value = double.parse(termToken.text);
          break;
        case TokenKind.SINGLE_QUOTE:
          value = processQuotedString(false);
          value = "'${_escapeString(value as String, single: true)}'";
          return LiteralTerm(value, value, _makeSpan(start));
        case TokenKind.DOUBLE_QUOTE:
          value = processQuotedString(false);
          value = '"${_escapeString(value as String)}"';
          return LiteralTerm(value, value, _makeSpan(start));
        case TokenKind.IDENTIFIER:
          value = identifier();
          break;
        default:
          keepParsing = false;
      }

      if (keepParsing && value != null) {
        var unitTerm =
            processDimension(termToken, value as Object, _makeSpan(start));
        expressions.add(unitTerm);

        value = null;
      }
    }

    return SelectorExpression(expressions, _makeSpan(start));
  }

  AttributeSelector? processAttribute() {
    var start = _peekToken.span;

    if (_maybeEat(TokenKind.LBRACK)) {
      var attrName = identifier();

      int op;
      switch (_peek()) {
        case TokenKind.EQUALS:
        case TokenKind.INCLUDES:
        case TokenKind.DASH_MATCH:
        case TokenKind.PREFIX_MATCH:
        case TokenKind.SUFFIX_MATCH:
        case TokenKind.SUBSTRING_MATCH:
          op = _peek();
          _next();
          break;
        default:
          op = TokenKind.NO_MATCH;
      }

      dynamic value;
      if (op != TokenKind.NO_MATCH) {
        if (_peekIdentifier()) {
          value = identifier();
        } else {
          value = processQuotedString(false);
        }

        if (value == null) {
          _error('expected attribute value string or ident', _peekToken.span);
        }
      }

      _eat(TokenKind.RBRACK);

      return AttributeSelector(attrName, op, value, _makeSpan(start));
    }
    return null;
  }

  Declaration? processDeclaration(List<DartStyleExpression> dartStyles) {
    Declaration? decl;

    var start = _peekToken.span;

    var ie7 = _peekKind(TokenKind.ASTERISK);
    if (ie7) {
      _next();
    }

    if (TokenKind.isIdentifier(_peekToken.kind)) {
      var propertyIdent = identifier();

      var ieFilterProperty = propertyIdent.name.toLowerCase() == 'filter';

      _eat(TokenKind.COLON);

      var exprs = processExpr(ieFilterProperty);

      var dartComposite = _styleForDart(propertyIdent, exprs, dartStyles);

      var importantPriority = _maybeEat(TokenKind.IMPORTANT);

      decl = Declaration(propertyIdent, exprs, dartComposite, _makeSpan(start),
          important: importantPriority, ie7: ie7);
    } else if (_peekToken.kind == TokenKind.VAR_DEFINITION) {
      _next();
      Identifier? definedName;
      if (_peekIdentifier()) definedName = identifier();

      _eat(TokenKind.COLON);

      var exprs = processExpr();

      decl = VarDefinition(definedName, exprs, _makeSpan(start));
    } else if (_peekToken.kind == TokenKind.DIRECTIVE_INCLUDE) {
      var span = _makeSpan(start);
      var include = processInclude(span, eatSemiColon: false);
      decl = IncludeMixinAtDeclaration(include, span);
    } else if (_peekToken.kind == TokenKind.DIRECTIVE_EXTEND) {
      var simpleSequences = <TreeNode>[];

      _next();
      var span = _makeSpan(start);
      var selector = simpleSelector();
      if (selector == null) {
        _warning('@extends expecting simple selector name', span);
      } else {
        simpleSequences.add(selector);
      }
      if (_peekKind(TokenKind.COLON)) {
        var pseudoSelector = processPseudoSelector(_peekToken.span);
        if (pseudoSelector is PseudoElementSelector ||
            pseudoSelector is PseudoClassSelector) {
          simpleSequences.add(pseudoSelector!);
        } else {
          _warning('not a valid selector', span);
        }
      }
      decl = ExtendDeclaration(simpleSequences, span);
    }

    return decl;
  }

  static const int _fontPartFont = 0;
  static const int _fontPartVariant = 1;
  static const int _fontPartWeight = 2;
  static const int _fontPartSize = 3;
  static const int _fontPartFamily = 4;
  static const int _fontPartStyle = 5;
  static const int _marginPartMargin = 6;
  static const int _marginPartLeft = 7;
  static const int _marginPartTop = 8;
  static const int _marginPartRight = 9;
  static const int _marginPartBottom = 10;
  static const int _lineHeightPart = 11;
  static const int _borderPartBorder = 12;
  static const int _borderPartLeft = 13;
  static const int _borderPartTop = 14;
  static const int _borderPartRight = 15;
  static const int _borderPartBottom = 16;
  static const int _borderPartWidth = 17;
  static const int _borderPartLeftWidth = 18;
  static const int _borderPartTopWidth = 19;
  static const int _borderPartRightWidth = 20;
  static const int _borderPartBottomWidth = 21;
  static const int _heightPart = 22;
  static const int _widthPart = 23;
  static const int _paddingPartPadding = 24;
  static const int _paddingPartLeft = 25;
  static const int _paddingPartTop = 26;
  static const int _paddingPartRight = 27;
  static const int _paddingPartBottom = 28;

  static const Map<String, int> _stylesToDart = {
    'font': _fontPartFont,
    'font-family': _fontPartFamily,
    'font-size': _fontPartSize,
    'font-style': _fontPartStyle,
    'font-variant': _fontPartVariant,
    'font-weight': _fontPartWeight,
    'line-height': _lineHeightPart,
    'margin': _marginPartMargin,
    'margin-left': _marginPartLeft,
    'margin-right': _marginPartRight,
    'margin-top': _marginPartTop,
    'margin-bottom': _marginPartBottom,
    'border': _borderPartBorder,
    'border-left': _borderPartLeft,
    'border-right': _borderPartRight,
    'border-top': _borderPartTop,
    'border-bottom': _borderPartBottom,
    'border-width': _borderPartWidth,
    'border-left-width': _borderPartLeftWidth,
    'border-top-width': _borderPartTopWidth,
    'border-right-width': _borderPartRightWidth,
    'border-bottom-width': _borderPartBottomWidth,
    'height': _heightPart,
    'width': _widthPart,
    'padding': _paddingPartPadding,
    'padding-left': _paddingPartLeft,
    'padding-top': _paddingPartTop,
    'padding-right': _paddingPartRight,
    'padding-bottom': _paddingPartBottom
  };

  static const Map<String, int> _nameToFontWeight = {
    'bold': FontWeight.bold,
    'normal': FontWeight.normal
  };

  static int? _findStyle(String styleName) => _stylesToDart[styleName];

  DartStyleExpression? _styleForDart(Identifier property, Expressions exprs,
      List<DartStyleExpression> dartStyles) {
    var styleType = _findStyle(property.name.toLowerCase());
    if (styleType != null) {
      return buildDartStyleNode(styleType, exprs, dartStyles);
    }
    return null;
  }

  FontExpression _mergeFontStyles(
      FontExpression fontExpr, List<DartStyleExpression> dartStyles) {
    for (var dartStyle in dartStyles) {
      if (dartStyle.isFont) {
        fontExpr = FontExpression.merge(dartStyle as FontExpression, fontExpr);
      }
    }

    return fontExpr;
  }

  DartStyleExpression? buildDartStyleNode(
      int styleType, Expressions exprs, List<DartStyleExpression> dartStyles) {
    switch (styleType) {
      case _fontPartFont:
        var processor = ExpressionsProcessor(exprs);
        return _mergeFontStyles(processor.processFont(), dartStyles);
      case _fontPartFamily:
        var processor = ExpressionsProcessor(exprs);

        try {
          return _mergeFontStyles(processor.processFontFamily(), dartStyles);
        } catch (fontException) {
          _error('$fontException', _peekToken.span);
        }
        break;
      case _fontPartSize:
        var processor = ExpressionsProcessor(exprs);
        return _mergeFontStyles(processor.processFontSize(), dartStyles);
      case _fontPartStyle:
        break;
      case _fontPartVariant:
        break;
      case _fontPartWeight:
        var expr = exprs.expressions[0];
        if (expr is NumberTerm) {
          var fontExpr = FontExpression(expr.span, weight: expr.value as int?);
          return _mergeFontStyles(fontExpr, dartStyles);
        } else if (expr is LiteralTerm) {
          var weight = _nameToFontWeight[expr.value.toString()];
          if (weight != null) {
            var fontExpr = FontExpression(expr.span, weight: weight);
            return _mergeFontStyles(fontExpr, dartStyles);
          }
        }
        break;
      case _lineHeightPart:
        if (exprs.expressions.length == 1) {
          var expr = exprs.expressions[0];
          if (expr is UnitTerm) {
            var unitTerm = expr;
            if (unitTerm.unit == TokenKind.UNIT_LENGTH_PX ||
                unitTerm.unit == TokenKind.UNIT_LENGTH_PT) {
              var fontExpr = FontExpression(expr.span,
                  lineHeight: LineHeight(expr.value as num, inPixels: true));
              return _mergeFontStyles(fontExpr, dartStyles);
            } else if (isChecked) {
              _warning('Unexpected unit for line-height', expr.span);
            }
          } else if (expr is NumberTerm) {
            var fontExpr = FontExpression(expr.span,
                lineHeight: LineHeight(expr.value as num, inPixels: false));
            return _mergeFontStyles(fontExpr, dartStyles);
          } else if (isChecked) {
            _warning('Unexpected value for line-height', expr.span);
          }
        }
        break;
      case _marginPartMargin:
        return MarginExpression.boxEdge(exprs.span, processFourNums(exprs));
      case _borderPartBorder:
        for (var expr in exprs.expressions) {
          var v = marginValue(expr);
          if (v != null) {
            final box = BoxEdge.uniform(v);
            return BorderExpression.boxEdge(exprs.span, box);
          }
        }
        break;
      case _borderPartWidth:
        var v = marginValue(exprs.expressions[0]);
        if (v != null) {
          final box = BoxEdge.uniform(v);
          return BorderExpression.boxEdge(exprs.span, box);
        }
        break;
      case _paddingPartPadding:
        return PaddingExpression.boxEdge(exprs.span, processFourNums(exprs));
      case _marginPartLeft:
      case _marginPartTop:
      case _marginPartRight:
      case _marginPartBottom:
      case _borderPartLeft:
      case _borderPartTop:
      case _borderPartRight:
      case _borderPartBottom:
      case _borderPartLeftWidth:
      case _borderPartTopWidth:
      case _borderPartRightWidth:
      case _borderPartBottomWidth:
      case _heightPart:
      case _widthPart:
      case _paddingPartLeft:
      case _paddingPartTop:
      case _paddingPartRight:
      case _paddingPartBottom:
        if (exprs.expressions.isNotEmpty) {
          return processOneNumber(exprs, styleType);
        }
        break;
    }
    return null;
  }

  DartStyleExpression? processOneNumber(Expressions exprs, int part) {
    var value = marginValue(exprs.expressions[0]);
    if (value != null) {
      switch (part) {
        case _marginPartLeft:
          return MarginExpression(exprs.span, left: value);
        case _marginPartTop:
          return MarginExpression(exprs.span, top: value);
        case _marginPartRight:
          return MarginExpression(exprs.span, right: value);
        case _marginPartBottom:
          return MarginExpression(exprs.span, bottom: value);
        case _borderPartLeft:
        case _borderPartLeftWidth:
          return BorderExpression(exprs.span, left: value);
        case _borderPartTop:
        case _borderPartTopWidth:
          return BorderExpression(exprs.span, top: value);
        case _borderPartRight:
        case _borderPartRightWidth:
          return BorderExpression(exprs.span, right: value);
        case _borderPartBottom:
        case _borderPartBottomWidth:
          return BorderExpression(exprs.span, bottom: value);
        case _heightPart:
          return HeightExpression(exprs.span, value);
        case _widthPart:
          return WidthExpression(exprs.span, value);
        case _paddingPartLeft:
          return PaddingExpression(exprs.span, left: value);
        case _paddingPartTop:
          return PaddingExpression(exprs.span, top: value);
        case _paddingPartRight:
          return PaddingExpression(exprs.span, right: value);
        case _paddingPartBottom:
          return PaddingExpression(exprs.span, bottom: value);
      }
    }
    return null;
  }

  BoxEdge? processFourNums(Expressions exprs) {
    num? top;
    num? right;
    num? bottom;
    num? left;

    var totalExprs = exprs.expressions.length;
    switch (totalExprs) {
      case 1:
        top = marginValue(exprs.expressions[0]);
        right = top;
        bottom = top;
        left = top;
        break;
      case 2:
        top = marginValue(exprs.expressions[0]);
        bottom = top;
        right = marginValue(exprs.expressions[1]);
        left = right;
        break;
      case 3:
        top = marginValue(exprs.expressions[0]);
        right = marginValue(exprs.expressions[1]);
        left = right;
        bottom = marginValue(exprs.expressions[2]);
        break;
      case 4:
        top = marginValue(exprs.expressions[0]);
        right = marginValue(exprs.expressions[1]);
        bottom = marginValue(exprs.expressions[2]);
        left = marginValue(exprs.expressions[3]);
        break;
      default:
        return null;
    }

    return BoxEdge.clockwiseFromTop(top, right, bottom, left);
  }

  num? marginValue(Expression exprTerm) {
    if (exprTerm is UnitTerm) {
      return exprTerm.value as num;
    } else if (exprTerm is NumberTerm) {
      return exprTerm.value as num;
    }
    return null;
  }

  Expressions processExpr([bool ieFilter = false]) {
    var start = _peekToken.span;
    var expressions = Expressions(_makeSpan(start));

    var keepGoing = true;
    dynamic expr;
    while (keepGoing && (expr = processTerm(ieFilter)) != null) {
      Expression? op;

      var opStart = _peekToken.span;

      switch (_peek()) {
        case TokenKind.SLASH:
          op = OperatorSlash(_makeSpan(opStart));
          break;
        case TokenKind.COMMA:
          op = OperatorComma(_makeSpan(opStart));
          break;
        case TokenKind.BACKSLASH:
          var ie8Start = _peekToken.span;

          _next();
          if (_peekKind(TokenKind.INTEGER)) {
            var numToken = _next();
            var value = int.parse(numToken.text);
            if (value == 9) {
              op = IE8Term(_makeSpan(ie8Start));
            } else if (isChecked) {
              _warning(
                  '\$value is not valid in an expression', _makeSpan(start));
            }
          }
          break;
      }

      if (expr != null) {
        if (expr is List<Expression>) {
          for (var exprItem in expr) {
            expressions.add(exprItem);
          }
        } else {
          expressions.add(expr as Expression);
        }
      } else {
        keepGoing = false;
      }

      if (op != null) {
        expressions.add(op);
        if (op is IE8Term) {
          keepGoing = false;
        } else {
          _next();
        }
      }
    }

    return expressions;
  }

  static const int maxUnicode = 0x10FFFF;

  dynamic /* Expression | List<Expression> | ... */ processTerm(
      [bool ieFilter = false]) {
    var start = _peekToken.span;
    Token? t;
    dynamic value;

    var unary = '';
    switch (_peek()) {
      case TokenKind.HASH:
        _eat(TokenKind.HASH);
        if (!_anyWhiteSpaceBeforePeekToken(TokenKind.HASH)) {
          String? hexText;
          if (_peekKind(TokenKind.INTEGER)) {
            var hexText1 = _peekToken.text;
            _next();
            if (_peekIdentifier() && _previousToken!.end == _peekToken.start) {
              hexText = '$hexText1${identifier().name}';
            } else {
              hexText = hexText1;
            }
          } else if (_peekIdentifier()) {
            hexText = identifier().name;
          }
          if (hexText != null) {
            return _parseHex(hexText, _makeSpan(start));
          }
        }

        if (isChecked) {
          _warning('Expected hex number', _makeSpan(start));
        }
        return _parseHex(
            ' ${(processTerm() as LiteralTerm).text}', _makeSpan(start));
      case TokenKind.INTEGER:
        t = _next();
        value = int.parse('$unary${t.text}');
        break;
      case TokenKind.DOUBLE:
        t = _next();
        value = double.parse('$unary${t.text}');
        break;
      case TokenKind.SINGLE_QUOTE:
        value = processQuotedString(false);
        value = "'${_escapeString(value as String, single: true)}'";
        return LiteralTerm(value, value, _makeSpan(start));
      case TokenKind.DOUBLE_QUOTE:
        value = processQuotedString(false);
        value = '"${_escapeString(value as String)}"';
        return LiteralTerm(value, value, _makeSpan(start));
      case TokenKind.LPAREN:
        _next();

        var group = GroupTerm(_makeSpan(start));

        dynamic /* Expression | List<Expression> | ... */ term;
        do {
          term = processTerm();
          if (term != null && term is LiteralTerm) {
            group.add(term);
          }
        } while (term != null &&
            !_maybeEat(TokenKind.RPAREN) &&
            !isPrematureEndOfFile());

        return group;
      case TokenKind.LBRACK:
        _next();

        var term = processTerm() as LiteralTerm;
        if (term is! NumberTerm) {
          _error('Expecting a positive number', _makeSpan(start));
        }

        _eat(TokenKind.RBRACK);

        return ItemTerm(term.value, term.text, _makeSpan(start));
      case TokenKind.IDENTIFIER:
        var nameValue = identifier();

        if (!ieFilter && _maybeEat(TokenKind.LPAREN)) {
          var calc = processCalc(nameValue);
          if (calc != null) return calc;
          return processFunction(nameValue);
        }
        if (ieFilter) {
          if (_maybeEat(TokenKind.COLON) &&
              nameValue.name.toLowerCase() == 'progid') {
            return processIEFilter(start);
          } else {
            return processIEFilter(start);
          }
        }

        if (nameValue.name == 'from') {
          return LiteralTerm(nameValue, nameValue.name, _makeSpan(start));
        }

        var colorEntry = TokenKind.matchColorName(nameValue.name);
        if (colorEntry == null) {
          if (isChecked) {
            var propName = nameValue.name;
            var errMsg = TokenKind.isPredefinedName(propName)
                ? 'Improper use of property value $propName'
                : 'Unknown property value $propName';
            _warning(errMsg, _makeSpan(start));
          }
          return LiteralTerm(nameValue, nameValue.name, _makeSpan(start));
        }

        var rgbColor =
            TokenKind.decimalToHex(TokenKind.colorValue(colorEntry), 6);
        return _parseHex(rgbColor, _makeSpan(start));
      case TokenKind.UNICODE_RANGE:
        String? first;
        String? second;
        int firstNumber;
        int secondNumber;
        _eat(TokenKind.UNICODE_RANGE, unicodeRange: true);
        if (_maybeEat(TokenKind.HEX_INTEGER, unicodeRange: true)) {
          first = _previousToken!.text;
          firstNumber = int.parse('0x$first');
          if (firstNumber > maxUnicode) {
            _error('unicode range must be less than 10FFFF', _makeSpan(start));
          }
          if (_maybeEat(TokenKind.MINUS, unicodeRange: true)) {
            if (_maybeEat(TokenKind.HEX_INTEGER, unicodeRange: true)) {
              second = _previousToken!.text;
              secondNumber = int.parse('0x$second');
              if (secondNumber > maxUnicode) {
                _error(
                    'unicode range must be less than 10FFFF', _makeSpan(start));
              }
              if (firstNumber > secondNumber) {
                _error('unicode first range can not be greater than last',
                    _makeSpan(start));
              }
            }
          }
        } else if (_maybeEat(TokenKind.HEX_RANGE, unicodeRange: true)) {
          first = _previousToken!.text;
        }

        return UnicodeRangeTerm(first, second, _makeSpan(start));
      case TokenKind.AT:
        if (messages.options.lessSupport) {
          _next();

          var expr = processExpr();
          if (isChecked && expr.expressions.length > 1) {
            _error('only @name for Less syntax', _peekToken.span);
          }

          var param = expr.expressions[0];
          var varUsage =
              VarUsage((param as LiteralTerm).text, [], _makeSpan(start));
          expr.expressions[0] = varUsage;
          return expr.expressions;
        }
        break;
    }

    return t != null
        ? processDimension(t, value as Object, _makeSpan(start))
        : null;
  }

  LiteralTerm processDimension(Token? t, Object value, SourceSpan span) {
    LiteralTerm term;
    var unitType = _peek();

    switch (unitType) {
      case TokenKind.UNIT_EM:
        term = EmTerm(value, t!.text, span);
        _next();
        break;
      case TokenKind.UNIT_EX:
        term = ExTerm(value, t!.text, span);
        _next();
        break;
      case TokenKind.UNIT_LENGTH_PX:
      case TokenKind.UNIT_LENGTH_CM:
      case TokenKind.UNIT_LENGTH_MM:
      case TokenKind.UNIT_LENGTH_IN:
      case TokenKind.UNIT_LENGTH_PT:
      case TokenKind.UNIT_LENGTH_PC:
        term = LengthTerm(value, t!.text, span, unitType);
        _next();
        break;
      case TokenKind.UNIT_ANGLE_DEG:
      case TokenKind.UNIT_ANGLE_RAD:
      case TokenKind.UNIT_ANGLE_GRAD:
      case TokenKind.UNIT_ANGLE_TURN:
        term = AngleTerm(value, t!.text, span, unitType);
        _next();
        break;
      case TokenKind.UNIT_TIME_MS:
      case TokenKind.UNIT_TIME_S:
        term = TimeTerm(value, t!.text, span, unitType);
        _next();
        break;
      case TokenKind.UNIT_FREQ_HZ:
      case TokenKind.UNIT_FREQ_KHZ:
        term = FreqTerm(value, t!.text, span, unitType);
        _next();
        break;
      case TokenKind.PERCENT:
        term = PercentageTerm(value, t!.text, span);
        _next();
        break;
      case TokenKind.UNIT_FRACTION:
        term = FractionTerm(value, t!.text, span);
        _next();
        break;
      case TokenKind.UNIT_RESOLUTION_DPI:
      case TokenKind.UNIT_RESOLUTION_DPCM:
      case TokenKind.UNIT_RESOLUTION_DPPX:
        term = ResolutionTerm(value, t!.text, span, unitType);
        _next();
        break;
      case TokenKind.UNIT_CH:
        term = ChTerm(value, t!.text, span, unitType);
        _next();
        break;
      case TokenKind.UNIT_REM:
        term = RemTerm(value, t!.text, span, unitType);
        _next();
        break;
      case TokenKind.UNIT_VIEWPORT_VW:
      case TokenKind.UNIT_VIEWPORT_VH:
      case TokenKind.UNIT_VIEWPORT_VMIN:
      case TokenKind.UNIT_VIEWPORT_VMAX:
        term = ViewportTerm(value, t!.text, span, unitType);
        _next();
        break;
      default:
        if (value is Identifier) {
          term = LiteralTerm(value, value.name, span);
        } else {
          term = NumberTerm(value, t!.text, span);
        }
    }

    return term;
  }

  String processQuotedString([bool urlString = false]) {
    var start = _peekToken.span;

    var stopToken = urlString ? TokenKind.RPAREN : -1;

    var inString = tokenizer.inString;
    tokenizer.inString = false;

    switch (_peek()) {
      case TokenKind.SINGLE_QUOTE:
        stopToken = TokenKind.SINGLE_QUOTE;
        _next();
        start = _peekToken.span;
        break;
      case TokenKind.DOUBLE_QUOTE:
        stopToken = TokenKind.DOUBLE_QUOTE;
        _next();
        start = _peekToken.span;
        break;
      default:
        if (urlString) {
          if (_peek() == TokenKind.LPAREN) {
            _next();
            start = _peekToken.span;
          }
          stopToken = TokenKind.RPAREN;
        } else {
          _error('unexpected string', _makeSpan(start));
        }
        break;
    }

    var stringValue = StringBuffer();
    while (_peek() != stopToken && _peek() != TokenKind.END_OF_FILE) {
      stringValue.write(_next().text);
    }

    tokenizer.inString = inString;

    if (stopToken != TokenKind.RPAREN) {
      _next();
    }

    return stringValue.toString();
  }

  dynamic processIEFilter(FileSpan startAfterProgidColon) {
    var kind = _peek();
    if (kind == TokenKind.SEMICOLON || kind == TokenKind.RBRACE) {
      var tok = tokenizer.makeIEFilter(
          startAfterProgidColon.start.offset, _peekToken.start);
      return LiteralTerm(tok.text, tok.text, tok.span);
    }

    var parens = 0;
    while (_peek() != TokenKind.END_OF_FILE) {
      switch (_peek()) {
        case TokenKind.LPAREN:
          _eat(TokenKind.LPAREN);
          parens++;
          break;
        case TokenKind.RPAREN:
          _eat(TokenKind.RPAREN);
          if (--parens == 0) {
            var tok = tokenizer.makeIEFilter(
                startAfterProgidColon.start.offset, _peekToken.start);
            return LiteralTerm(tok.text, tok.text, tok.span);
          }
          break;
        default:
          _eat(_peek());
      }
    }
  }

  String processCalcExpression() {
    var inString = tokenizer.inString;
    tokenizer.inString = false;

    var stringValue = StringBuffer();
    var left = 1;
    var matchingParens = false;
    while (_peek() != TokenKind.END_OF_FILE && !matchingParens) {
      var token = _peek();
      if (token == TokenKind.LPAREN) {
        left++;
      } else if (token == TokenKind.RPAREN) {
        left--;
      }

      matchingParens = left == 0;
      if (!matchingParens) stringValue.write(_next().text);
    }

    if (!matchingParens) {
      _error('problem parsing function expected ), ', _peekToken.span);
    }

    tokenizer.inString = inString;

    return stringValue.toString();
  }

  CalcTerm? processCalc(Identifier func) {
    var start = _peekToken.span;

    var name = func.name;
    if (const {'calc', '-webkit-calc', '-moz-calc', 'min', 'max', 'clamp'}
        .contains(name)) {
      var expression = processCalcExpression();
      var calcExpr = LiteralTerm(expression, expression, _makeSpan(start));

      if (!_maybeEat(TokenKind.RPAREN)) {
        _error('problem parsing function expected ), ', _peekToken.span);
      }

      return CalcTerm(name, name, calcExpr, _makeSpan(start));
    }

    return null;
  }

  TreeNode /* LiteralTerm | Expression */ processFunction(Identifier func) {
    var start = _peekToken.span;
    var name = func.name;

    switch (name) {
      case 'url':
        var urlParam = processQuotedString(true);

        if (_peek() == TokenKind.END_OF_FILE) {
          _error('problem parsing URI', _peekToken.span);
        }

        if (_peek() == TokenKind.RPAREN) {
          _next();
        }

        return UriTerm(urlParam, _makeSpan(start));
      case 'var':
        var expr = processExpr();
        if (!_maybeEat(TokenKind.RPAREN)) {
          _error('problem parsing var expected ), ', _peekToken.span);
        }
        if (isChecked &&
            expr.expressions.whereType<OperatorComma>().length > 1) {
          _error('too many parameters to var()', _peekToken.span);
        }

        var paramName = (expr.expressions[0] as LiteralTerm).text;

        var defaultValues = expr.expressions.length >= 3
            ? expr.expressions.sublist(2)
            : <Expression>[];
        return VarUsage(paramName, defaultValues, _makeSpan(start));
      default:
        var expr = processExpr();
        if (!_maybeEat(TokenKind.RPAREN)) {
          _error('problem parsing function expected ), ', _peekToken.span);
        }

        return FunctionTerm(name, name, expr, _makeSpan(start));
    }
  }

  Identifier identifier() {
    var tok = _next();

    if (!TokenKind.isIdentifier(tok.kind) &&
        !TokenKind.isKindIdentifier(tok.kind)) {
      if (isChecked) {
        _warning('expected identifier, but found $tok', tok.span);
      }
      return Identifier('', _makeSpan(tok.span));
    }

    return Identifier(tok.text, _makeSpan(tok.span));
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

  HexColorTerm _parseHex(String hexText, SourceSpan span) {
    var hexValue = 0;

    for (var i = 0; i < hexText.length; i++) {
      var digit = _hexDigit(hexText.codeUnitAt(i));
      if (digit < 0) {
        _warning('Bad hex number', span);
        return HexColorTerm(BadHexValue(), hexText, span);
      }
      hexValue = (hexValue << 4) + digit;
    }

    if (hexText.length == 6 &&
        hexText[0] == hexText[1] &&
        hexText[2] == hexText[3] &&
        hexText[4] == hexText[5]) {
      hexText = '${hexText[0]}${hexText[2]}${hexText[4]}';
    } else if (hexText.length == 4 &&
        hexText[0] == hexText[1] &&
        hexText[2] == hexText[3]) {
      hexText = '${hexText[0]}${hexText[2]}';
    } else if (hexText.length == 2 && hexText[0] == hexText[1]) {
      hexText = hexText[0];
    }
    return HexColorTerm(hexValue, hexText, span);
  }
}

class ExpressionsProcessor {
  final Expressions _exprs;
  int _index = 0;

  ExpressionsProcessor(this._exprs);

  FontExpression processFontSize() {
    LengthTerm? size;
    LineHeight? lineHt;
    var nextIsLineHeight = false;
    for (; _index < _exprs.expressions.length; _index++) {
      var expr = _exprs.expressions[_index];
      if (size == null && expr is LengthTerm) {
        size = expr;
      } else if (size != null) {
        if (expr is OperatorSlash) {
          nextIsLineHeight = true;
        } else if (nextIsLineHeight && expr is LengthTerm) {
          assert(expr.unit == TokenKind.UNIT_LENGTH_PX);
          lineHt = LineHeight(expr.value as num, inPixels: true);
          nextIsLineHeight = false;
          _index++;
          break;
        } else {
          break;
        }
      } else {
        break;
      }
    }

    return FontExpression(_exprs.span, size: size, lineHeight: lineHt);
  }

  FontExpression processFontFamily() {
    var family = <String>[];

    var moreFamilies = false;

    for (; _index < _exprs.expressions.length; _index++) {
      var expr = _exprs.expressions[_index];
      if (expr is LiteralTerm) {
        if (family.isEmpty || moreFamilies) {
          family.add(expr.toString());
          moreFamilies = false;
        } else if (isChecked) {
          messages.warning('Only font-family can be a list', _exprs.span);
        }
      } else if (expr is OperatorComma && family.isNotEmpty) {
        moreFamilies = true;
      } else {
        break;
      }
    }

    return FontExpression(_exprs.span, family: family);
  }

  FontExpression processFont() {
    FontExpression? fontSize;
    FontExpression? fontFamily;
    for (; _index < _exprs.expressions.length; _index++) {
      fontSize ??= processFontSize();
      fontFamily ??= processFontFamily();
    }

    return FontExpression(_exprs.span,
        size: fontSize!.font.size,
        lineHeight: fontSize.font.lineHeight,
        family: fontFamily!.font.family);
  }
}

String _escapeString(String text, {bool single = false}) {
  StringBuffer? result;

  for (var i = 0; i < text.length; i++) {
    var code = text.codeUnitAt(i);
    String? replace;
    switch (code) {
      case 34 /*'"'*/ :
        if (!single) replace = r'\"';
        break;
      case 39 /*"'"*/ :
        if (single) replace = r"\'";
        break;
    }

    if (replace != null && result == null) {
      result = StringBuffer(text.substring(0, i));
    }

    if (result != null) result.write(replace ?? text[i]);
  }

  return result == null ? text : result.toString();
}
