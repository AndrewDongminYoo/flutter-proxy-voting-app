// 🎯 Dart imports:
import 'dart:math' as math;

// 🌎 Project imports:
import 'src/src.dart';
import 'visitor.dart';

// 📦 Package imports:
import 'package:source_span/source_span.dart'
    show FileSpan, SourceFile, SourceSpan;

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

class ParserState extends CssTokenizerState {
  final CssToken peekToken;
  final CssToken? previousToken;

  ParserState(this.peekToken, this.previousToken, Tokenizer tokenizer)
      : super(tokenizer);
}

void _createMessages(
    {List<CssMessage>? errors, CssPreprocessorOptions? options}) {
  errors ??= [];

  options ??=
      const CssPreprocessorOptions(useColors: false, inputFile: 'memory');

  messages = CssMessages(options: options, printHandler: errors.add);
}

bool get isChecked => messages.options.checked;

CssStyleSheet compile(input,
    {List<CssMessage>? errors,
    CssPreprocessorOptions? options,
    bool nested = true,
    bool polyfill = false,
    List<CssStyleSheet>? includes}) {
  includes ??= [];

  String source = _inputAsString(input);

  _createMessages(errors: errors, options: options);

  SourceFile file = SourceFile.fromString(source);

  CssStyleSheet tree = _Parser(file, source).parse();

  analyze([tree], errors: errors, options: options);

  if (polyfill) {
    CssPolyFill processCss = CssPolyFill(messages);
    processCss.process(tree, includes: includes);
  }

  return tree;
}

void analyze(List<CssStyleSheet> styleSheets,
    {List<CssMessage>? errors, CssPreprocessorOptions? options}) {
  _createMessages(errors: errors, options: options);
  Analyzer(styleSheets, messages).run();
}

CssStyleSheet parse(input,
    {List<CssMessage>? errors, CssPreprocessorOptions? options}) {
  String source = _inputAsString(input);

  _createMessages(errors: errors, options: options);

  SourceFile file = SourceFile.fromString(source);
  return _Parser(file, source).parse();
}

CssStyleSheet selector(input, {List<CssMessage>? errors}) {
  String source = _inputAsString(input);

  _createMessages(errors: errors);

  SourceFile file = SourceFile.fromString(source);
  return (_Parser(file, source)..tokenizer.inSelector = true).parseSelector();
}

CssSelectorGroup? parseSelectorGroup(input, {List<CssMessage>? errors}) {
  String source = _inputAsString(input);

  _createMessages(errors: errors);

  SourceFile file = SourceFile.fromString(source);
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

  CssStyleSheet parse() => _parser.parse();
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

  CssToken? _previousToken;
  late CssToken _peekToken;

  _Parser(this.file, String text, {int start = 0})
      : tokenizer = Tokenizer(file, text, true, start) {
    _peekToken = tokenizer.next();
  }

  CssStyleSheet parse() {
    List<CssTreeNode> productions = <CssTreeNode>[];

    FileSpan start = _peekToken.span;
    while (!_maybeEat(CssTokenKind.END_OF_FILE) &&
        !_peekKind(CssTokenKind.RBRACE)) {
      final rule = processRule();
      if (rule != null) {
        productions.add(rule);
      } else {
        break;
      }
    }

    checkEndOfFile();

    return CssStyleSheet(productions, _makeSpan(start));
  }

  CssStyleSheet parseSelector() {
    List<CssTreeNode> productions = <CssTreeNode>[];

    FileSpan start = _peekToken.span;
    while (!_maybeEat(CssTokenKind.END_OF_FILE) &&
        !_peekKind(CssTokenKind.RBRACE)) {
      CssSelector? selector = processSelector();
      if (selector != null) {
        productions.add(selector);
      } else {
        break;
      }
    }

    checkEndOfFile();

    return CssStyleSheet.selector(productions, _makeSpan(start));
  }

  void checkEndOfFile() {
    if (!(_peekKind(CssTokenKind.END_OF_FILE) ||
        _peekKind(CssTokenKind.INCOMPLETE_COMMENT))) {
      _error('premature end of file unknown CSS', _peekToken.span);
    }
  }

  bool isPrematureEndOfFile() {
    if (_maybeEat(CssTokenKind.END_OF_FILE)) {
      _error('unexpected end of file', _peekToken.span);
      return true;
    } else {
      return false;
    }
  }

  int _peek() {
    return _peekToken.kind;
  }

  CssToken _next({bool unicodeRange = false}) {
    final next = _previousToken = _peekToken;
    _peekToken = tokenizer.next(unicodeRange: unicodeRange);
    return next;
  }

  bool _peekKind(int kind) {
    return _peekToken.kind == kind;
  }

  bool _peekIdentifier() {
    return CssTokenKind.isIdentifier(_peekToken.kind);
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
      _errorExpected(CssTokenKind.kindToString(kind));
    }
  }

  void _errorExpected(String expected) {
    CssToken tok = _next();
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
    List<MediaQuery> mediaQueries = <MediaQuery>[];

    do {
      MediaQuery? mediaQuery = processMediaQuery();
      if (mediaQuery != null) {
        mediaQueries.add(mediaQuery);
      } else {
        break;
      }
    } while (_maybeEat(CssTokenKind.COMMA));

    return mediaQueries;
  }

  MediaQuery? processMediaQuery() {
    FileSpan start = _peekToken.span;

    String op = _peekToken.text;
    int opLen = op.length;
    int unaryOp = CssTokenKind.matchMediaOperator(op, 0, opLen);
    if (unaryOp != -1) {
      if (isChecked) {
        if (unaryOp != CssTokenKind.MEDIA_OP_NOT ||
            unaryOp != CssTokenKind.MEDIA_OP_ONLY) {
          _warning('Only the unary operators NOT and ONLY allowed',
              _makeSpan(start));
        }
      }
      _next();
      start = _peekToken.span;
    }

    CssIdentifier? type;
    if (_peekIdentifier()) type = identifier();

    List<CssMediaExpression> exprs = <CssMediaExpression>[];

    while (true) {
      bool andOp = exprs.isNotEmpty || type != null;
      if (andOp) {
        op = _peekToken.text;
        opLen = op.length;
        if (CssTokenKind.matchMediaOperator(op, 0, opLen) !=
            CssTokenKind.MEDIA_OP_AND) {
          break;
        }
        _next();
      }

      CssMediaExpression? expr = processMediaExpression(andOp);
      if (expr == null) break;

      exprs.add(expr);
    }

    if (unaryOp != -1 || type != null || exprs.isNotEmpty) {
      return MediaQuery(unaryOp, type, exprs, _makeSpan(start));
    }
    return null;
  }

  CssMediaExpression? processMediaExpression([bool andOperator = false]) {
    FileSpan start = _peekToken.span;

    if (_maybeEat(CssTokenKind.LPAREN)) {
      if (_peekIdentifier()) {
        CssIdentifier feature = identifier();
        CssExpressions exprs = _maybeEat(CssTokenKind.COLON)
            ? processExpr()
            : CssExpressions(_makeSpan(_peekToken.span));
        if (_maybeEat(CssTokenKind.RPAREN)) {
          return CssMediaExpression(
              andOperator, feature, exprs, _makeSpan(start));
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
    FileSpan start = _peekToken.span;

    dynamic tokId = processVariableOrDirective();
    if (tokId is CssVarDefinitionDirective) return tokId;
    final tokenId = tokId as int;
    switch (tokenId) {
      case CssTokenKind.DIRECTIVE_IMPORT:
        _next();

        String? importStr;
        if (_peekIdentifier()) {
          CssTreeNode func = processFunction(identifier());
          if (func is CssUriTerm) {
            importStr = func.text;
          }
        } else {
          importStr = processQuotedString(false);
        }

        List<MediaQuery> medias = processMediaQueryList();

        if (importStr == null) {
          _error('missing import string', _peekToken.span);
        }

        return CssImportDirective(importStr!.trim(), medias, _makeSpan(start));

      case CssTokenKind.DIRECTIVE_MEDIA:
        _next();

        List<MediaQuery> media = processMediaQueryList();

        List<CssTreeNode> rules = <CssTreeNode>[];
        if (_maybeEat(CssTokenKind.LBRACE)) {
          while (!_maybeEat(CssTokenKind.END_OF_FILE)) {
            final rule = processRule();
            if (rule == null) break;
            rules.add(rule);
          }

          if (!_maybeEat(CssTokenKind.RBRACE)) {
            _error('expected } after ruleset for @media', _peekToken.span);
          }
        } else {
          _error('expected { after media before ruleset', _peekToken.span);
        }
        return CssMediaDirective(media, rules, _makeSpan(start));

      case CssTokenKind.DIRECTIVE_HOST:
        _next();

        List<CssTreeNode> rules = <CssTreeNode>[];
        if (_maybeEat(CssTokenKind.LBRACE)) {
          while (!_maybeEat(CssTokenKind.END_OF_FILE)) {
            final rule = processRule();
            if (rule == null) break;
            rules.add(rule);
          }

          if (!_maybeEat(CssTokenKind.RBRACE)) {
            _error('expected } after ruleset for @host', _peekToken.span);
          }
        } else {
          _error('expected { after host before ruleset', _peekToken.span);
        }
        return CssHostDirective(rules, _makeSpan(start));

      case CssTokenKind.DIRECTIVE_PAGE:
        _next();

        CssIdentifier? name;
        if (_peekIdentifier()) {
          name = identifier();
        }

        CssIdentifier? pseudoPage;
        if (_maybeEat(CssTokenKind.COLON)) {
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

        String pseudoName = pseudoPage is CssIdentifier ? pseudoPage.name : '';
        String ident = name is CssIdentifier ? name.name : '';
        return CssPageDirective(
            ident, pseudoName, processMarginsDeclarations(), _makeSpan(start));

      case CssTokenKind.DIRECTIVE_CHARSET:
        _next();

        String charEncoding = processQuotedString(false);
        return CssCharsetDirective(charEncoding, _makeSpan(start));

      /*
      case TokenKind.DIRECTIVE_MS_KEYFRAMES:
        if (isChecked) {
          _warning('@-ms-keyframes should be @keyframes', _makeSpan(start));
        }
        continue keyframeDirective;

      keyframeDirective:
      */
      case CssTokenKind.DIRECTIVE_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_WEB_KIT_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_MOZ_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_O_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_MS_KEYFRAMES:
        if (tokenId == CssTokenKind.DIRECTIVE_MS_KEYFRAMES && isChecked) {
          _warning('@-ms-keyframes should be @keyframes', _makeSpan(start));
        }

        _next();

        CssIdentifier? name;
        if (_peekIdentifier()) {
          name = identifier();
        }

        _eat(CssTokenKind.LBRACE);

        CssKeyFrameDirective keyframe =
            CssKeyFrameDirective(tokenId, name, _makeSpan(start));

        do {
          CssExpressions selectors = CssExpressions(_makeSpan(start));

          do {
            CssExpression term = processTerm() as CssExpression;

            selectors.add(term);
          } while (_maybeEat(CssTokenKind.COMMA));

          keyframe.add(CssKeyFrameBlock(
              selectors, processDeclarations(), _makeSpan(start)));
        } while (!_maybeEat(CssTokenKind.RBRACE) && !isPrematureEndOfFile());

        return keyframe;

      case CssTokenKind.DIRECTIVE_FONTFACE:
        _next();
        return FontFaceDirective(processDeclarations(), _makeSpan(start));

      case CssTokenKind.DIRECTIVE_STYLET:
        _next();

        dynamic name;
        if (_peekIdentifier()) {
          name = identifier();
        }

        _eat(CssTokenKind.LBRACE);

        List<CssTreeNode> productions = <CssTreeNode>[];

        start = _peekToken.span;
        while (!_maybeEat(CssTokenKind.END_OF_FILE)) {
          final rule = processRule();
          if (rule == null) {
            break;
          }
          productions.add(rule);
        }

        _eat(CssTokenKind.RBRACE);

        return StyletDirective(name as String, productions, _makeSpan(start));

      case CssTokenKind.DIRECTIVE_NAMESPACE:
        _next();

        CssIdentifier? prefix;
        if (_peekIdentifier()) {
          prefix = identifier();
        }

        String? namespaceUri;
        if (_peekIdentifier()) {
          CssTreeNode func = processFunction(identifier());
          if (func is CssUriTerm) {
            namespaceUri = func.text;
          }
        } else {
          if (prefix != null && prefix.name == 'url') {
            CssTreeNode func = processFunction(prefix);
            if (func is CssUriTerm) {
              namespaceUri = func.text;
              prefix = null;
            }
          } else {
            namespaceUri = processQuotedString(false);
          }
        }

        return CssNamespaceDirective(
            prefix?.name ?? '', namespaceUri, _makeSpan(start));

      case CssTokenKind.DIRECTIVE_MIXIN:
        return processMixin();

      case CssTokenKind.DIRECTIVE_INCLUDE:
        return processInclude(_makeSpan(start));
      case CssTokenKind.DIRECTIVE_CONTENT:
        _warning('@content not implemented.', _makeSpan(start));
        return null;
      case CssTokenKind.DIRECTIVE_MOZ_DOCUMENT:
        return processDocumentDirective();
      case CssTokenKind.DIRECTIVE_SUPPORTS:
        return processSupportsDirective();
      case CssTokenKind.DIRECTIVE_VIEWPORT:
      case CssTokenKind.DIRECTIVE_MS_VIEWPORT:
        return processViewportDirective();
    }
    return null;
  }

  CssMixinDefinition? processMixin() {
    _next();

    CssIdentifier name = identifier();

    List<CssTreeNode> params = <CssTreeNode>[];
    if (_maybeEat(CssTokenKind.LPAREN)) {
      bool mustHaveParam = false;
      bool keepGoing = true;
      while (keepGoing) {
        dynamic varDef = processVariableOrDirective(mixinParameter: true);
        if (varDef is CssVarDefinitionDirective || varDef is VarDefinition) {
          params.add(varDef as CssTreeNode);
        } else if (mustHaveParam) {
          _warning('Expecting parameter', _makeSpan(_peekToken.span));
          keepGoing = false;
        }
        if (_maybeEat(CssTokenKind.COMMA)) {
          mustHaveParam = true;
          continue;
        }
        keepGoing = !_maybeEat(CssTokenKind.RPAREN);
      }
    }

    _eat(CssTokenKind.LBRACE);

    List<CssTreeNode> productions = <CssTreeNode>[];
    CssMixinDefinition? mixinDirective;

    FileSpan start = _peekToken.span;
    while (!_maybeEat(CssTokenKind.END_OF_FILE)) {
      Directive? directive = processDirective();
      if (directive != null) {
        productions.add(directive);
        continue;
      }

      DeclarationGroup declGroup = processDeclarations(checkBrace: false);
      if (declGroup.declarations.any((decl) {
        return decl is CssDeclaration && decl is! CssIncludeMixinAtDeclaration;
      })) {
        List<CssDeclaration> newDecls = <CssDeclaration>[];
        for (CssTreeNode include in productions) {
          if (include is IncludeDirective) {
            newDecls.add(CssIncludeMixinAtDeclaration(include, include.span));
          } else {
            _warning('Error mixing of top-level vs declarations mixins',
                _makeSpan(include.span as FileSpan));
          }
        }
        declGroup.declarations.insertAll(0, newDecls);
        productions = [];
      } else {
        for (CssTreeNode decl in declGroup.declarations) {
          productions
              .add(decl is CssIncludeMixinAtDeclaration ? decl.include : decl);
        }
        declGroup.declarations.clear();
      }

      if (declGroup.declarations.isNotEmpty) {
        if (productions.isEmpty) {
          mixinDirective = CssMixinDeclarationDirective(
              name.name, params, false, declGroup, _makeSpan(start));
          break;
        } else {
          for (CssTreeNode decl in declGroup.declarations) {
            productions.add(
                decl is CssIncludeMixinAtDeclaration ? decl.include : decl);
          }
        }
      } else {
        mixinDirective = CssMixinRulesetDirective(
            name.name, params, false, productions, _makeSpan(start));
        break;
      }
    }

    if (productions.isNotEmpty) {
      mixinDirective = CssMixinRulesetDirective(
          name.name, params, false, productions, _makeSpan(start));
    }

    _eat(CssTokenKind.RBRACE);

    return mixinDirective;
  }

  dynamic processVariableOrDirective({bool mixinParameter = false}) {
    FileSpan start = _peekToken.span;

    int tokId = _peek();
    if (tokId == CssTokenKind.AT) {
      _next();
      tokId = _peek();
      if (_peekIdentifier()) {
        String directive = _peekToken.text;
        int directiveLen = directive.length;
        tokId = CssTokenKind.matchDirectives(directive, 0, directiveLen);
        if (tokId == -1) {
          tokId =
              CssTokenKind.matchMarginDirectives(directive, 0, directiveLen);
        }
      }

      if (tokId == -1) {
        if (messages.options.lessSupport) {
          CssIdentifier? name;
          if (_peekIdentifier()) {
            name = identifier();
          }

          CssExpressions? exprs;
          if (mixinParameter && _maybeEat(CssTokenKind.COLON)) {
            exprs = processExpr();
          } else if (!mixinParameter) {
            _eat(CssTokenKind.COLON);
            exprs = processExpr();
          }

          SourceSpan span = _makeSpan(start);
          return CssVarDefinitionDirective(
              VarDefinition(name, exprs, span), span);
        } else if (isChecked) {
          _error('unexpected directive @$_peekToken', _peekToken.span);
        }
      }
    } else if (mixinParameter &&
        _peekToken.kind == CssTokenKind.VAR_DEFINITION) {
      _next();
      CssIdentifier? definedName;
      if (_peekIdentifier()) definedName = identifier();

      CssExpressions? exprs;
      if (_maybeEat(CssTokenKind.COLON)) {
        exprs = processExpr();
      }

      return VarDefinition(definedName, exprs, _makeSpan(start));
    }

    return tokId;
  }

  IncludeDirective processInclude(SourceSpan span, {bool eatSemiColon = true}) {
    _next();

    CssIdentifier? name;
    if (_peekIdentifier()) {
      name = identifier();
    }

    List<List<CssExpression>> params = <List<CssExpression>>[];

    if (_maybeEat(CssTokenKind.LPAREN)) {
      List<CssExpression> terms = <CssExpression>[];
      dynamic expr;
      bool keepGoing = true;
      while (keepGoing && (expr = processTerm()) != null) {
        terms.add((expr is List ? expr[0] : expr) as CssExpression);
        keepGoing = !_peekKind(CssTokenKind.RPAREN);
        if (keepGoing) {
          if (_maybeEat(CssTokenKind.COMMA)) {
            params.add(terms);
            terms = [];
          }
        }
      }
      params.add(terms);
      _maybeEat(CssTokenKind.RPAREN);
    }

    if (eatSemiColon) {
      _eat(CssTokenKind.SEMICOLON);
    }

    return IncludeDirective(name!.name, params, span);
  }

  CssDocumentDirective processDocumentDirective() {
    FileSpan start = _peekToken.span;
    _next();
    List<CssLiteralTerm> functions = <CssLiteralTerm>[];
    do {
      CssLiteralTerm function;

      CssIdentifier ident = identifier();
      _eat(CssTokenKind.LPAREN);

      if (ident.name == 'url-prefix' || ident.name == 'domain') {
        FileSpan argumentStart = _peekToken.span;
        String value = processQuotedString(true);
        String argument = value.isNotEmpty ? '"$value"' : '';
        SourceSpan argumentSpan = _makeSpan(argumentStart);

        _eat(CssTokenKind.RPAREN);

        CssExpressions arguments =
            CssExpressions(_makeSpan(argumentSpan as FileSpan))
              ..add(CssLiteralTerm(argument, argument, argumentSpan));
        function = CssFunctionTerm(ident.name, ident.name, arguments,
            _makeSpan(ident.span as FileSpan));
      } else {
        function = processFunction(ident) as CssLiteralTerm;
      }

      functions.add(function);
    } while (_maybeEat(CssTokenKind.COMMA));

    _eat(CssTokenKind.LBRACE);
    List<CssTreeNode> groupRuleBody = processGroupRuleBody();
    _eat(CssTokenKind.RBRACE);
    return CssDocumentDirective(functions, groupRuleBody, _makeSpan(start));
  }

  CssSupportsDirective processSupportsDirective() {
    FileSpan start = _peekToken.span;
    _next();
    SupportsCondition? condition = processSupportsCondition();
    _eat(CssTokenKind.LBRACE);
    List<CssTreeNode> groupRuleBody = processGroupRuleBody();
    _eat(CssTokenKind.RBRACE);
    return CssSupportsDirective(condition, groupRuleBody, _makeSpan(start));
  }

  SupportsCondition? processSupportsCondition() {
    if (_peekKind(CssTokenKind.IDENTIFIER)) {
      return processSupportsNegation();
    }

    FileSpan start = _peekToken.span;
    List<CssSupportsConditionInParens> conditions =
        <CssSupportsConditionInParens>[];
    ClauseType clauseType = ClauseType.none;

    while (true) {
      conditions.add(processSupportsConditionInParens());

      ClauseType type;
      String text = _peekToken.text.toLowerCase();

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
      return CssSupportsDisjunction(conditions, _makeSpan(start));
    } else {
      return conditions.first;
    }
  }

  SupportsNegation? processSupportsNegation() {
    FileSpan start = _peekToken.span;
    String text = _peekToken.text.toLowerCase();
    if (text != 'not') return null;
    _next();
    CssSupportsConditionInParens condition = processSupportsConditionInParens();
    return SupportsNegation(condition, _makeSpan(start));
  }

  CssSupportsConditionInParens processSupportsConditionInParens() {
    FileSpan start = _peekToken.span;
    _eat(CssTokenKind.LPAREN);
    SupportsCondition? condition = processSupportsCondition();
    if (condition != null) {
      _eat(CssTokenKind.RPAREN);
      return CssSupportsConditionInParens.nested(condition, _makeSpan(start));
    }
    CssDeclaration? declaration = processDeclaration([]);
    _eat(CssTokenKind.RPAREN);
    return CssSupportsConditionInParens(declaration, _makeSpan(start));
  }

  CssViewportDirective processViewportDirective() {
    FileSpan start = _peekToken.span;
    String name = _next().text;
    DeclarationGroup declarations = processDeclarations();
    return CssViewportDirective(name, declarations, _makeSpan(start));
  }

  CssTreeNode? processRule([CssSelectorGroup? selectorGroup]) {
    if (selectorGroup == null) {
      final directive = processDirective();
      if (directive != null) {
        _maybeEat(CssTokenKind.SEMICOLON);
        return directive;
      }
      selectorGroup = processSelectorGroup();
    }
    if (selectorGroup != null) {
      return CssRuleSet(
          selectorGroup, processDeclarations(), selectorGroup.span);
    }
    return null;
  }

  List<CssTreeNode> processGroupRuleBody() {
    List<CssTreeNode> nodes = <CssTreeNode>[];
    while (!(_peekKind(CssTokenKind.RBRACE) ||
        _peekKind(CssTokenKind.END_OF_FILE))) {
      CssTreeNode? rule = processRule();
      if (rule != null) {
        nodes.add(rule);
        continue;
      }
      break;
    }
    return nodes;
  }

  CssSelectorGroup? _nestedSelector() {
    CssMessages oldMessages = messages;
    _createMessages();

    ParserState markedData = _mark;

    CssSelectorGroup? selGroup = processSelectorGroup();

    bool nestedSelector = selGroup != null &&
        _peekKind(CssTokenKind.LBRACE) &&
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
    FileSpan start = _peekToken.span;

    if (checkBrace) _eat(CssTokenKind.LBRACE);

    List<CssTreeNode> decls = <CssTreeNode>[];
    List<CssDartStyleExpression> dartStyles = <CssDartStyleExpression>[];

    do {
      CssSelectorGroup? selectorGroup = _nestedSelector();
      while (selectorGroup != null) {
        CssTreeNode? ruleset = processRule(selectorGroup)!;
        decls.add(ruleset);
        selectorGroup = _nestedSelector();
      }

      CssDeclaration? decl = processDeclaration(dartStyles);
      if (decl != null) {
        if (decl.hasDartStyle) {
          CssDartStyleExpression newDartStyle = decl.dartStyle!;

          bool replaced = false;
          for (int i = 0; i < dartStyles.length; i++) {
            CssDartStyleExpression dartStyle = dartStyles[i];
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
    } while (_maybeEat(CssTokenKind.SEMICOLON));

    if (checkBrace) _eat(CssTokenKind.RBRACE);

    for (CssTreeNode decl in decls) {
      if (decl is CssDeclaration) {
        if (decl.hasDartStyle && !dartStyles.contains(decl.dartStyle)) {
          decl.dartStyle = null;
        }
      }
    }

    return DeclarationGroup(decls, _makeSpan(start));
  }

  List<DeclarationGroup> processMarginsDeclarations() {
    List<DeclarationGroup> groups = <DeclarationGroup>[];

    FileSpan start = _peekToken.span;

    _eat(CssTokenKind.LBRACE);

    List<CssDeclaration> decls = <CssDeclaration>[];
    List<CssDartStyleExpression> dartStyles = <CssDartStyleExpression>[];

    do {
      switch (_peek()) {
        case CssTokenKind.MARGIN_DIRECTIVE_TOPLEFTCORNER:
        case CssTokenKind.MARGIN_DIRECTIVE_TOPLEFT:
        case CssTokenKind.MARGIN_DIRECTIVE_TOPCENTER:
        case CssTokenKind.MARGIN_DIRECTIVE_TOPRIGHT:
        case CssTokenKind.MARGIN_DIRECTIVE_TOPRIGHTCORNER:
        case CssTokenKind.MARGIN_DIRECTIVE_BOTTOMLEFTCORNER:
        case CssTokenKind.MARGIN_DIRECTIVE_BOTTOMLEFT:
        case CssTokenKind.MARGIN_DIRECTIVE_BOTTOMCENTER:
        case CssTokenKind.MARGIN_DIRECTIVE_BOTTOMRIGHT:
        case CssTokenKind.MARGIN_DIRECTIVE_BOTTOMRIGHTCORNER:
        case CssTokenKind.MARGIN_DIRECTIVE_LEFTTOP:
        case CssTokenKind.MARGIN_DIRECTIVE_LEFTMIDDLE:
        case CssTokenKind.MARGIN_DIRECTIVE_LEFTBOTTOM:
        case CssTokenKind.MARGIN_DIRECTIVE_RIGHTTOP:
        case CssTokenKind.MARGIN_DIRECTIVE_RIGHTMIDDLE:
        case CssTokenKind.MARGIN_DIRECTIVE_RIGHTBOTTOM:
          int marginSym = _peek();

          _next();

          DeclarationGroup declGroup = processDeclarations();
          groups.add(CssMarginGroup(
              marginSym, declGroup.declarations, _makeSpan(start)));
          break;
        default:
          CssDeclaration? decl = processDeclaration(dartStyles);
          if (decl != null) {
            if (decl.hasDartStyle) {
              CssDartStyleExpression newDartStyle = decl.dartStyle!;

              bool replaced = false;
              for (int i = 0; i < dartStyles.length; i++) {
                CssDartStyleExpression dartStyle = dartStyles[i];
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
          _maybeEat(CssTokenKind.SEMICOLON);
          break;
      }
    } while (!_maybeEat(CssTokenKind.RBRACE) && !isPrematureEndOfFile());

    for (CssDeclaration decl in decls) {
      if (decl.hasDartStyle && !dartStyles.contains(decl.dartStyle)) {
        decl.dartStyle = null;
      }
    }

    if (decls.isNotEmpty) {
      groups.add(DeclarationGroup(decls, _makeSpan(start)));
    }

    return groups;
  }

  CssSelectorGroup? processSelectorGroup() {
    List<CssSelector> selectors = <CssSelector>[];
    FileSpan start = _peekToken.span;

    tokenizer.inSelector = true;
    do {
      CssSelector? selector = processSelector();
      if (selector != null) {
        selectors.add(selector);
      }
    } while (_maybeEat(CssTokenKind.COMMA));
    tokenizer.inSelector = false;

    if (selectors.isNotEmpty) {
      return CssSelectorGroup(selectors, _makeSpan(start));
    }
    return null;
  }

  CssSelector? processSelector() {
    List<CssSimpleSelectorSequence> simpleSequences =
        <CssSimpleSelectorSequence>[];
    FileSpan start = _peekToken.span;
    while (true) {
      CssSimpleSelectorSequence? selectorItem =
          simpleSelectorSequence(simpleSequences.isEmpty);
      if (selectorItem != null) {
        simpleSequences.add(selectorItem);
      } else {
        break;
      }
    }

    if (simpleSequences.isEmpty) return null;

    return CssSelector(simpleSequences, _makeSpan(start));
  }

  CssSelector? processCompoundSelector() {
    CssSelector? selector = processSelector();
    if (selector != null) {
      for (CssSimpleSelectorSequence sequence
          in selector.simpleSelectorSequences) {
        if (!sequence.isCombinatorNone) {
          _error('compound selector can not contain combinator', sequence.span);
        }
      }
    }
    return selector;
  }

  CssSimpleSelectorSequence? simpleSelectorSequence(bool forceCombinatorNone) {
    FileSpan start = _peekToken.span;
    int combinatorType = CssTokenKind.COMBINATOR_NONE;
    bool thisOperator = false;

    switch (_peek()) {
      case CssTokenKind.PLUS:
        _eat(CssTokenKind.PLUS);
        combinatorType = CssTokenKind.COMBINATOR_PLUS;
        break;
      case CssTokenKind.GREATER:
        _eat(CssTokenKind.GREATER);
        combinatorType = CssTokenKind.COMBINATOR_GREATER;
        break;
      case CssTokenKind.TILDE:
        _eat(CssTokenKind.TILDE);
        combinatorType = CssTokenKind.COMBINATOR_TILDE;
        break;
      case CssTokenKind.AMPERSAND:
        _eat(CssTokenKind.AMPERSAND);
        thisOperator = true;
        break;
    }

    if (combinatorType == CssTokenKind.COMBINATOR_NONE &&
        !forceCombinatorNone) {
      if (_previousToken != null && _previousToken!.end != _peekToken.start) {
        combinatorType = CssTokenKind.COMBINATOR_DESCENDANT;
      }
    }

    SourceSpan span = _makeSpan(start);
    CssSimpleSelector? simpleSel = thisOperator
        ? ElementSelector(CssThisOperator(span), span)
        : simpleSelector();
    if (simpleSel == null &&
        (combinatorType == CssTokenKind.COMBINATOR_PLUS ||
            combinatorType == CssTokenKind.COMBINATOR_GREATER ||
            combinatorType == CssTokenKind.COMBINATOR_TILDE)) {
      simpleSel = ElementSelector(CssIdentifier('', span), span);
    }
    if (simpleSel != null) {
      return CssSimpleSelectorSequence(simpleSel, span, combinatorType);
    }
    return null;
  }

  CssSimpleSelector? simpleSelector() {
    dynamic first;
    FileSpan start = _peekToken.span;
    switch (_peek()) {
      case CssTokenKind.ASTERISK:
        CssToken tok = _next();
        first = CssWildcard(_makeSpan(tok.span));
        break;
      case CssTokenKind.IDENTIFIER:
        first = identifier();
        break;
      default:
        if (CssTokenKind.isKindIdentifier(_peek())) {
          first = identifier();
        } else if (_peekKind(CssTokenKind.SEMICOLON)) {
          return null;
        }
        break;
    }

    if (_maybeEat(CssTokenKind.NAMESPACE)) {
      CssTreeNode? element;
      switch (_peek()) {
        case CssTokenKind.ASTERISK:
          CssToken tok = _next();
          element = CssWildcard(_makeSpan(tok.span));
          break;
        case CssTokenKind.IDENTIFIER:
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

  CssSimpleSelector? simpleSelectorTail() {
    FileSpan start = _peekToken.span;
    switch (_peek()) {
      case CssTokenKind.HASH:
        _eat(CssTokenKind.HASH);

        if (_anyWhiteSpaceBeforePeekToken(CssTokenKind.HASH)) {
          _error('Not a valid ID selector expected #id', _makeSpan(start));
          return null;
        }
        return CssIdSelector(identifier(), _makeSpan(start));
      case CssTokenKind.DOT:
        _eat(CssTokenKind.DOT);

        if (_anyWhiteSpaceBeforePeekToken(CssTokenKind.DOT)) {
          _error('Not a valid class selector expected .className',
              _makeSpan(start));
          return null;
        }
        return CssClassSelector(identifier(), _makeSpan(start));
      case CssTokenKind.COLON:
        return processPseudoSelector(start);
      case CssTokenKind.LBRACK:
        return processAttribute();
      case CssTokenKind.DOUBLE:
        _error('name must start with a alpha character, but found a number',
            _peekToken.span);
        _next();
        break;
    }
    return null;
  }

  CssSimpleSelector? processPseudoSelector(FileSpan start) {
    _eat(CssTokenKind.COLON);
    bool pseudoElement = _maybeEat(CssTokenKind.COLON);

    CssIdentifier pseudoName;
    if (_peekIdentifier()) {
      pseudoName = identifier();
    } else {
      return null;
    }
    String name = pseudoName.name.toLowerCase();

    if (_peekToken.kind == CssTokenKind.LPAREN) {
      if (!pseudoElement && name == 'not') {
        _eat(CssTokenKind.LPAREN);

        CssSimpleSelector? negArg = simpleSelector();

        _eat(CssTokenKind.RPAREN);
        return CssNegationSelector(negArg, _makeSpan(start));
      } else if (!pseudoElement &&
          (name == 'host' ||
              name == 'host-context' ||
              name == 'global-context' ||
              name == '-acx-global-context')) {
        _eat(CssTokenKind.LPAREN);
        CssSelector? selector = processCompoundSelector();
        if (selector == null) {
          _errorExpected('a selector argument');
          return null;
        }
        _eat(CssTokenKind.RPAREN);
        SourceSpan span = _makeSpan(start);
        return PseudoClassFunctionSelector(pseudoName, selector, span);
      } else {
        tokenizer.inSelectorExpression = true;
        _eat(CssTokenKind.LPAREN);

        SourceSpan span = _makeSpan(start);
        CssTreeNode expr = processSelectorExpression();

        tokenizer.inSelectorExpression = false;

        if (expr is CssSelectorExpression) {
          _eat(CssTokenKind.RPAREN);
          return (pseudoElement)
              ? CssPseudoElementFunctionSelector(pseudoName, expr, span)
              : PseudoClassFunctionSelector(pseudoName, expr, span);
        } else {
          _errorExpected('CSS expression');
          return null;
        }
      }
    }

    return pseudoElement || _legacyPseudoElements.contains(name)
        ? CssPseudoElementSelector(pseudoName, _makeSpan(start),
            isLegacy: !pseudoElement)
        : CssPseudoClassSelector(pseudoName, _makeSpan(start));
  }

  CssTreeNode /* SelectorExpression | LiteralTerm */
      processSelectorExpression() {
    FileSpan start = _peekToken.span;

    List<CssExpression> expressions = <CssExpression>[];

    CssToken? termToken;
    dynamic value;

    bool keepParsing = true;
    while (keepParsing) {
      switch (_peek()) {
        case CssTokenKind.PLUS:
          start = _peekToken.span;
          termToken = _next();
          expressions.add(CssOperatorPlus(_makeSpan(start)));
          break;
        case CssTokenKind.MINUS:
          start = _peekToken.span;
          termToken = _next();
          expressions.add(CssOperatorMinus(_makeSpan(start)));
          break;
        case CssTokenKind.INTEGER:
          termToken = _next();
          value = int.parse(termToken.text);
          break;
        case CssTokenKind.DOUBLE:
          termToken = _next();
          value = double.parse(termToken.text);
          break;
        case CssTokenKind.SINGLE_QUOTE:
          value = processQuotedString(false);
          value = "'${_escapeString(value as String, single: true)}'";
          return CssLiteralTerm(value, value, _makeSpan(start));
        case CssTokenKind.DOUBLE_QUOTE:
          value = processQuotedString(false);
          value = '"${_escapeString(value as String)}"';
          return CssLiteralTerm(value, value, _makeSpan(start));
        case CssTokenKind.IDENTIFIER:
          value = identifier();
          break;
        default:
          keepParsing = false;
      }

      if (keepParsing && value != null) {
        CssLiteralTerm unitTerm =
            processDimension(termToken, value as Object, _makeSpan(start));
        expressions.add(unitTerm);

        value = null;
      }
    }

    return CssSelectorExpression(expressions, _makeSpan(start));
  }

  CssAttributeSelector? processAttribute() {
    FileSpan start = _peekToken.span;

    if (_maybeEat(CssTokenKind.LBRACK)) {
      CssIdentifier attrName = identifier();

      int op;
      switch (_peek()) {
        case CssTokenKind.EQUALS:
        case CssTokenKind.INCLUDES:
        case CssTokenKind.DASH_MATCH:
        case CssTokenKind.PREFIX_MATCH:
        case CssTokenKind.SUFFIX_MATCH:
        case CssTokenKind.SUBSTRING_MATCH:
          op = _peek();
          _next();
          break;
        default:
          op = CssTokenKind.NO_MATCH;
      }

      dynamic value;
      if (op != CssTokenKind.NO_MATCH) {
        if (_peekIdentifier()) {
          value = identifier();
        } else {
          value = processQuotedString(false);
        }

        if (value == null) {
          _error('expected attribute value string or ident', _peekToken.span);
        }
      }

      _eat(CssTokenKind.RBRACK);

      return CssAttributeSelector(attrName, op, value, _makeSpan(start));
    }
    return null;
  }

  CssDeclaration? processDeclaration(List<CssDartStyleExpression> dartStyles) {
    CssDeclaration? decl;

    FileSpan start = _peekToken.span;

    bool ie7 = _peekKind(CssTokenKind.ASTERISK);
    if (ie7) {
      _next();
    }

    if (CssTokenKind.isIdentifier(_peekToken.kind)) {
      CssIdentifier propertyIdent = identifier();

      bool ieFilterProperty = propertyIdent.name.toLowerCase() == 'filter';

      _eat(CssTokenKind.COLON);

      CssExpressions exprs = processExpr(ieFilterProperty);

      CssDartStyleExpression? dartComposite =
          _styleForDart(propertyIdent, exprs, dartStyles);

      bool importantPriority = _maybeEat(CssTokenKind.IMPORTANT);

      decl = CssDeclaration(
          propertyIdent, exprs, dartComposite, _makeSpan(start),
          important: importantPriority, ie7: ie7);
    } else if (_peekToken.kind == CssTokenKind.VAR_DEFINITION) {
      _next();
      CssIdentifier? definedName;
      if (_peekIdentifier()) definedName = identifier();

      _eat(CssTokenKind.COLON);

      CssExpressions exprs = processExpr();

      decl = VarDefinition(definedName, exprs, _makeSpan(start));
    } else if (_peekToken.kind == CssTokenKind.DIRECTIVE_INCLUDE) {
      SourceSpan span = _makeSpan(start);
      IncludeDirective include = processInclude(span, eatSemiColon: false);
      decl = CssIncludeMixinAtDeclaration(include, span);
    } else if (_peekToken.kind == CssTokenKind.DIRECTIVE_EXTEND) {
      List<CssTreeNode> simpleSequences = <CssTreeNode>[];

      _next();
      SourceSpan span = _makeSpan(start);
      CssSimpleSelector? selector = simpleSelector();
      if (selector == null) {
        _warning('@extends expecting simple selector name', span);
      } else {
        simpleSequences.add(selector);
      }
      if (_peekKind(CssTokenKind.COLON)) {
        CssSimpleSelector? pseudoSelector =
            processPseudoSelector(_peekToken.span);
        if (pseudoSelector is CssPseudoElementSelector ||
            pseudoSelector is CssPseudoClassSelector) {
          simpleSequences.add(pseudoSelector!);
        } else {
          _warning('not a valid selector', span);
        }
      }
      decl = CssExtendDeclaration(simpleSequences, span);
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
    'bold': CssFontWeight.bold,
    'normal': CssFontWeight.normal
  };

  static int? _findStyle(String styleName) => _stylesToDart[styleName];

  CssDartStyleExpression? _styleForDart(CssIdentifier property,
      CssExpressions exprs, List<CssDartStyleExpression> dartStyles) {
    int? styleType = _findStyle(property.name.toLowerCase());
    if (styleType != null) {
      return buildDartStyleNode(styleType, exprs, dartStyles);
    }
    return null;
  }

  CssFontExpression _mergeFontStyles(
      CssFontExpression fontExpr, List<CssDartStyleExpression> dartStyles) {
    for (CssDartStyleExpression dartStyle in dartStyles) {
      if (dartStyle.isFont) {
        fontExpr =
            CssFontExpression.merge(dartStyle as CssFontExpression, fontExpr);
      }
    }

    return fontExpr;
  }

  CssDartStyleExpression? buildDartStyleNode(int styleType,
      CssExpressions exprs, List<CssDartStyleExpression> dartStyles) {
    switch (styleType) {
      case _fontPartFont:
        ExpressionsProcessor processor = ExpressionsProcessor(exprs);
        return _mergeFontStyles(processor.processFont(), dartStyles);
      case _fontPartFamily:
        ExpressionsProcessor processor = ExpressionsProcessor(exprs);

        try {
          return _mergeFontStyles(processor.processFontFamily(), dartStyles);
        } catch (fontException) {
          _error('$fontException', _peekToken.span);
        }
        break;
      case _fontPartSize:
        ExpressionsProcessor processor = ExpressionsProcessor(exprs);
        return _mergeFontStyles(processor.processFontSize(), dartStyles);
      case _fontPartStyle:
        break;
      case _fontPartVariant:
        break;
      case _fontPartWeight:
        CssExpression expr = exprs.expressions[0];
        if (expr is CssNumberTerm) {
          CssFontExpression fontExpr =
              CssFontExpression(expr.span, weight: expr.value as int?);
          return _mergeFontStyles(fontExpr, dartStyles);
        } else if (expr is CssLiteralTerm) {
          int? weight = _nameToFontWeight[expr.value.toString()];
          if (weight != null) {
            CssFontExpression fontExpr =
                CssFontExpression(expr.span, weight: weight);
            return _mergeFontStyles(fontExpr, dartStyles);
          }
        }
        break;
      case _lineHeightPart:
        if (exprs.expressions.length == 1) {
          CssExpression expr = exprs.expressions[0];
          if (expr is CssUnitTerm) {
            CssUnitTerm unitTerm = expr;
            if (unitTerm.unit == CssTokenKind.UNIT_LENGTH_PX ||
                unitTerm.unit == CssTokenKind.UNIT_LENGTH_PT) {
              CssFontExpression fontExpr = CssFontExpression(expr.span,
                  lineHeight: LineHeight(expr.value as num, inPixels: true));
              return _mergeFontStyles(fontExpr, dartStyles);
            } else if (isChecked) {
              _warning('Unexpected unit for line-height', expr.span);
            }
          } else if (expr is CssNumberTerm) {
            CssFontExpression fontExpr = CssFontExpression(expr.span,
                lineHeight: LineHeight(expr.value as num, inPixels: false));
            return _mergeFontStyles(fontExpr, dartStyles);
          } else if (isChecked) {
            _warning('Unexpected value for line-height', expr.span);
          }
        }
        break;
      case _marginPartMargin:
        return CssMarginExpression.boxEdge(exprs.span, processFourNums(exprs));
      case _borderPartBorder:
        for (CssExpression expr in exprs.expressions) {
          num? v = marginValue(expr);
          if (v != null) {
            final box = CssBoxEdge.uniform(v);
            return CssBorderExpression.boxEdge(exprs.span, box);
          }
        }
        break;
      case _borderPartWidth:
        num? v = marginValue(exprs.expressions[0]);
        if (v != null) {
          final box = CssBoxEdge.uniform(v);
          return CssBorderExpression.boxEdge(exprs.span, box);
        }
        break;
      case _paddingPartPadding:
        return CssPaddingExpression.boxEdge(exprs.span, processFourNums(exprs));
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

  CssDartStyleExpression? processOneNumber(CssExpressions exprs, int part) {
    num? value = marginValue(exprs.expressions[0]);
    if (value != null) {
      switch (part) {
        case _marginPartLeft:
          return CssMarginExpression(exprs.span, left: value);
        case _marginPartTop:
          return CssMarginExpression(exprs.span, top: value);
        case _marginPartRight:
          return CssMarginExpression(exprs.span, right: value);
        case _marginPartBottom:
          return CssMarginExpression(exprs.span, bottom: value);
        case _borderPartLeft:
        case _borderPartLeftWidth:
          return CssBorderExpression(exprs.span, left: value);
        case _borderPartTop:
        case _borderPartTopWidth:
          return CssBorderExpression(exprs.span, top: value);
        case _borderPartRight:
        case _borderPartRightWidth:
          return CssBorderExpression(exprs.span, right: value);
        case _borderPartBottom:
        case _borderPartBottomWidth:
          return CssBorderExpression(exprs.span, bottom: value);
        case _heightPart:
          return CssHeightExpression(exprs.span, value);
        case _widthPart:
          return CssWidthExpression(exprs.span, value);
        case _paddingPartLeft:
          return CssPaddingExpression(exprs.span, left: value);
        case _paddingPartTop:
          return CssPaddingExpression(exprs.span, top: value);
        case _paddingPartRight:
          return CssPaddingExpression(exprs.span, right: value);
        case _paddingPartBottom:
          return CssPaddingExpression(exprs.span, bottom: value);
      }
    }
    return null;
  }

  CssBoxEdge? processFourNums(CssExpressions exprs) {
    num? top;
    num? right;
    num? bottom;
    num? left;

    int totalExprs = exprs.expressions.length;
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

    return CssBoxEdge.clockwiseFromTop(top, right, bottom, left);
  }

  num? marginValue(CssExpression exprTerm) {
    if (exprTerm is CssUnitTerm) {
      return exprTerm.value as num;
    } else if (exprTerm is CssNumberTerm) {
      return exprTerm.value as num;
    }
    return null;
  }

  CssExpressions processExpr([bool ieFilter = false]) {
    FileSpan start = _peekToken.span;
    CssExpressions expressions = CssExpressions(_makeSpan(start));

    bool keepGoing = true;
    dynamic expr;
    while (keepGoing && (expr = processTerm(ieFilter)) != null) {
      CssExpression? op;

      FileSpan opStart = _peekToken.span;

      switch (_peek()) {
        case CssTokenKind.SLASH:
          op = CssOperatorSlash(_makeSpan(opStart));
          break;
        case CssTokenKind.COMMA:
          op = CssOperatorComma(_makeSpan(opStart));
          break;
        case CssTokenKind.BACKSLASH:
          FileSpan ie8Start = _peekToken.span;

          _next();
          if (_peekKind(CssTokenKind.INTEGER)) {
            CssToken numToken = _next();
            int value = int.parse(numToken.text);
            if (value == 9) {
              op = CssIE8Term(_makeSpan(ie8Start));
            } else if (isChecked) {
              _warning(
                  '\$value is not valid in an expression', _makeSpan(start));
            }
          }
          break;
      }

      if (expr != null) {
        if (expr is List<CssExpression>) {
          for (CssExpression exprItem in expr) {
            expressions.add(exprItem);
          }
        } else {
          expressions.add(expr as CssExpression);
        }
      } else {
        keepGoing = false;
      }

      if (op != null) {
        expressions.add(op);
        if (op is CssIE8Term) {
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
    FileSpan start = _peekToken.span;
    CssToken? t;
    dynamic value;

    String unary = '';
    switch (_peek()) {
      case CssTokenKind.HASH:
        _eat(CssTokenKind.HASH);
        if (!_anyWhiteSpaceBeforePeekToken(CssTokenKind.HASH)) {
          String? hexText;
          if (_peekKind(CssTokenKind.INTEGER)) {
            String hexText1 = _peekToken.text;
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
            ' ${(processTerm() as CssLiteralTerm).text}', _makeSpan(start));
      case CssTokenKind.INTEGER:
        t = _next();
        value = int.parse('$unary${t.text}');
        break;
      case CssTokenKind.DOUBLE:
        t = _next();
        value = double.parse('$unary${t.text}');
        break;
      case CssTokenKind.SINGLE_QUOTE:
        value = processQuotedString(false);
        value = "'${_escapeString(value as String, single: true)}'";
        return CssLiteralTerm(value, value, _makeSpan(start));
      case CssTokenKind.DOUBLE_QUOTE:
        value = processQuotedString(false);
        value = '"${_escapeString(value as String)}"';
        return CssLiteralTerm(value, value, _makeSpan(start));
      case CssTokenKind.LPAREN:
        _next();

        CssGroupTerm group = CssGroupTerm(_makeSpan(start));

        dynamic /* Expression | List<Expression> | ... */ term;
        do {
          term = processTerm();
          if (term != null && term is CssLiteralTerm) {
            group.add(term);
          }
        } while (term != null &&
            !_maybeEat(CssTokenKind.RPAREN) &&
            !isPrematureEndOfFile());

        return group;
      case CssTokenKind.LBRACK:
        _next();

        CssLiteralTerm term = processTerm() as CssLiteralTerm;
        if (term is! CssNumberTerm) {
          _error('Expecting a positive number', _makeSpan(start));
        }

        _eat(CssTokenKind.RBRACK);

        return CssItemTerm(term.value, term.text, _makeSpan(start));
      case CssTokenKind.IDENTIFIER:
        CssIdentifier nameValue = identifier();

        if (!ieFilter && _maybeEat(CssTokenKind.LPAREN)) {
          CssCalcTerm? calc = processCalc(nameValue);
          if (calc != null) return calc;
          return processFunction(nameValue);
        }
        if (ieFilter) {
          if (_maybeEat(CssTokenKind.COLON) &&
              nameValue.name.toLowerCase() == 'progid') {
            return processIEFilter(start);
          } else {
            return processIEFilter(start);
          }
        }

        if (nameValue.name == 'from') {
          return CssLiteralTerm(nameValue, nameValue.name, _makeSpan(start));
        }

        Map? colorEntry = CssTokenKind.matchColorName(nameValue.name);
        if (colorEntry == null) {
          if (isChecked) {
            String propName = nameValue.name;
            String errMsg = CssTokenKind.isPredefinedName(propName)
                ? 'Improper use of property value $propName'
                : 'Unknown property value $propName';
            _warning(errMsg, _makeSpan(start));
          }
          return CssLiteralTerm(nameValue, nameValue.name, _makeSpan(start));
        }

        String rgbColor =
            CssTokenKind.decimalToHex(CssTokenKind.colorValue(colorEntry), 6);
        return _parseHex(rgbColor, _makeSpan(start));
      case CssTokenKind.UNICODE_RANGE:
        String? first;
        String? second;
        int firstNumber;
        int secondNumber;
        _eat(CssTokenKind.UNICODE_RANGE, unicodeRange: true);
        if (_maybeEat(CssTokenKind.HEX_INTEGER, unicodeRange: true)) {
          first = _previousToken!.text;
          firstNumber = int.parse('0x$first');
          if (firstNumber > maxUnicode) {
            _error('unicode range must be less than 10FFFF', _makeSpan(start));
          }
          if (_maybeEat(CssTokenKind.MINUS, unicodeRange: true)) {
            if (_maybeEat(CssTokenKind.HEX_INTEGER, unicodeRange: true)) {
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
        } else if (_maybeEat(CssTokenKind.HEX_RANGE, unicodeRange: true)) {
          first = _previousToken!.text;
        }

        return CssUnicodeRangeTerm(first, second, _makeSpan(start));
      case CssTokenKind.AT:
        if (messages.options.lessSupport) {
          _next();

          CssExpressions expr = processExpr();
          if (isChecked && expr.expressions.length > 1) {
            _error('only @name for Less syntax', _peekToken.span);
          }

          CssExpression param = expr.expressions[0];
          CssVarUsage varUsage =
              CssVarUsage((param as CssLiteralTerm).text, [], _makeSpan(start));
          expr.expressions[0] = varUsage;
          return expr.expressions;
        }
        break;
    }

    return t != null
        ? processDimension(t, value as Object, _makeSpan(start))
        : null;
  }

  CssLiteralTerm processDimension(CssToken? t, Object value, SourceSpan span) {
    CssLiteralTerm term;
    int unitType = _peek();

    switch (unitType) {
      case CssTokenKind.UNIT_EM:
        term = CssEmTerm(value, t!.text, span);
        _next();
        break;
      case CssTokenKind.UNIT_EX:
        term = CssExTerm(value, t!.text, span);
        _next();
        break;
      case CssTokenKind.UNIT_LENGTH_PX:
      case CssTokenKind.UNIT_LENGTH_CM:
      case CssTokenKind.UNIT_LENGTH_MM:
      case CssTokenKind.UNIT_LENGTH_IN:
      case CssTokenKind.UNIT_LENGTH_PT:
      case CssTokenKind.UNIT_LENGTH_PC:
        term = CssLengthTerm(value, t!.text, span, unitType);
        _next();
        break;
      case CssTokenKind.UNIT_ANGLE_DEG:
      case CssTokenKind.UNIT_ANGLE_RAD:
      case CssTokenKind.UNIT_ANGLE_GRAD:
      case CssTokenKind.UNIT_ANGLE_TURN:
        term = CssAngleTerm(value, t!.text, span, unitType);
        _next();
        break;
      case CssTokenKind.UNIT_TIME_MS:
      case CssTokenKind.UNIT_TIME_S:
        term = CssTimeTerm(value, t!.text, span, unitType);
        _next();
        break;
      case CssTokenKind.UNIT_FREQ_HZ:
      case CssTokenKind.UNIT_FREQ_KHZ:
        term = CssFreqTerm(value, t!.text, span, unitType);
        _next();
        break;
      case CssTokenKind.PERCENT:
        term = CssPercentageTerm(value, t!.text, span);
        _next();
        break;
      case CssTokenKind.UNIT_FRACTION:
        term = CssFractionTerm(value, t!.text, span);
        _next();
        break;
      case CssTokenKind.UNIT_RESOLUTION_DPI:
      case CssTokenKind.UNIT_RESOLUTION_DPCM:
      case CssTokenKind.UNIT_RESOLUTION_DPPX:
        term = CssResolutionTerm(value, t!.text, span, unitType);
        _next();
        break;
      case CssTokenKind.UNIT_CH:
        term = CssChTerm(value, t!.text, span, unitType);
        _next();
        break;
      case CssTokenKind.UNIT_REM:
        term = CssRemTerm(value, t!.text, span, unitType);
        _next();
        break;
      case CssTokenKind.UNIT_VIEWPORT_VW:
      case CssTokenKind.UNIT_VIEWPORT_VH:
      case CssTokenKind.UNIT_VIEWPORT_VMIN:
      case CssTokenKind.UNIT_VIEWPORT_VMAX:
        term = CssViewportTerm(value, t!.text, span, unitType);
        _next();
        break;
      default:
        if (value is CssIdentifier) {
          term = CssLiteralTerm(value, value.name, span);
        } else {
          term = CssNumberTerm(value, t!.text, span);
        }
    }

    return term;
  }

  String processQuotedString([bool urlString = false]) {
    FileSpan start = _peekToken.span;

    int stopToken = urlString ? CssTokenKind.RPAREN : -1;

    bool inString = tokenizer.inString;
    tokenizer.inString = false;

    switch (_peek()) {
      case CssTokenKind.SINGLE_QUOTE:
        stopToken = CssTokenKind.SINGLE_QUOTE;
        _next();
        start = _peekToken.span;
        break;
      case CssTokenKind.DOUBLE_QUOTE:
        stopToken = CssTokenKind.DOUBLE_QUOTE;
        _next();
        start = _peekToken.span;
        break;
      default:
        if (urlString) {
          if (_peek() == CssTokenKind.LPAREN) {
            _next();
            start = _peekToken.span;
          }
          stopToken = CssTokenKind.RPAREN;
        } else {
          _error('unexpected string', _makeSpan(start));
        }
        break;
    }

    StringBuffer stringValue = StringBuffer();
    while (_peek() != stopToken && _peek() != CssTokenKind.END_OF_FILE) {
      stringValue.write(_next().text);
    }

    tokenizer.inString = inString;

    if (stopToken != CssTokenKind.RPAREN) {
      _next();
    }

    return stringValue.toString();
  }

  dynamic processIEFilter(FileSpan startAfterProgidColon) {
    int kind = _peek();
    if (kind == CssTokenKind.SEMICOLON || kind == CssTokenKind.RBRACE) {
      CssToken tok = tokenizer.makeIEFilter(
          startAfterProgidColon.start.offset, _peekToken.start);
      return CssLiteralTerm(tok.text, tok.text, tok.span);
    }

    int parens = 0;
    while (_peek() != CssTokenKind.END_OF_FILE) {
      switch (_peek()) {
        case CssTokenKind.LPAREN:
          _eat(CssTokenKind.LPAREN);
          parens++;
          break;
        case CssTokenKind.RPAREN:
          _eat(CssTokenKind.RPAREN);
          if (--parens == 0) {
            CssToken tok = tokenizer.makeIEFilter(
                startAfterProgidColon.start.offset, _peekToken.start);
            return CssLiteralTerm(tok.text, tok.text, tok.span);
          }
          break;
        default:
          _eat(_peek());
      }
    }
  }

  String processCalcExpression() {
    bool inString = tokenizer.inString;
    tokenizer.inString = false;

    StringBuffer stringValue = StringBuffer();
    int left = 1;
    bool matchingParens = false;
    while (_peek() != CssTokenKind.END_OF_FILE && !matchingParens) {
      int token = _peek();
      if (token == CssTokenKind.LPAREN) {
        left++;
      } else if (token == CssTokenKind.RPAREN) {
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

  CssCalcTerm? processCalc(CssIdentifier func) {
    FileSpan start = _peekToken.span;

    String name = func.name;
    if (const {'calc', '-webkit-calc', '-moz-calc', 'min', 'max', 'clamp'}
        .contains(name)) {
      String expression = processCalcExpression();
      CssLiteralTerm calcExpr =
          CssLiteralTerm(expression, expression, _makeSpan(start));

      if (!_maybeEat(CssTokenKind.RPAREN)) {
        _error('problem parsing function expected ), ', _peekToken.span);
      }

      return CssCalcTerm(name, name, calcExpr, _makeSpan(start));
    }

    return null;
  }

  CssTreeNode /* LiteralTerm | Expression */ processFunction(
      CssIdentifier func) {
    FileSpan start = _peekToken.span;
    String name = func.name;

    switch (name) {
      case 'url':
        String urlParam = processQuotedString(true);

        if (_peek() == CssTokenKind.END_OF_FILE) {
          _error('problem parsing URI', _peekToken.span);
        }

        if (_peek() == CssTokenKind.RPAREN) {
          _next();
        }

        return CssUriTerm(urlParam, _makeSpan(start));
      case 'var':
        CssExpressions expr = processExpr();
        if (!_maybeEat(CssTokenKind.RPAREN)) {
          _error('problem parsing var expected ), ', _peekToken.span);
        }
        if (isChecked &&
            expr.expressions.whereType<CssOperatorComma>().length > 1) {
          _error('too many parameters to var()', _peekToken.span);
        }

        String paramName = (expr.expressions[0] as CssLiteralTerm).text;

        List<CssExpression> defaultValues = expr.expressions.length >= 3
            ? expr.expressions.sublist(2)
            : <CssExpression>[];
        return CssVarUsage(paramName, defaultValues, _makeSpan(start));
      default:
        CssExpressions expr = processExpr();
        if (!_maybeEat(CssTokenKind.RPAREN)) {
          _error('problem parsing function expected ), ', _peekToken.span);
        }

        return CssFunctionTerm(name, name, expr, _makeSpan(start));
    }
  }

  CssIdentifier identifier() {
    CssToken tok = _next();

    if (!CssTokenKind.isIdentifier(tok.kind) &&
        !CssTokenKind.isKindIdentifier(tok.kind)) {
      if (isChecked) {
        _warning('expected identifier, but found $tok', tok.span);
      }
      return CssIdentifier('', _makeSpan(tok.span));
    }

    return CssIdentifier(tok.text, _makeSpan(tok.span));
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

  CssHexColorTerm _parseHex(String hexText, SourceSpan span) {
    int hexValue = 0;

    for (int i = 0; i < hexText.length; i++) {
      int digit = _hexDigit(hexText.codeUnitAt(i));
      if (digit < 0) {
        _warning('Bad hex number', span);
        return CssHexColorTerm(BadHexValue(), hexText, span);
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
    return CssHexColorTerm(hexValue, hexText, span);
  }
}

class ExpressionsProcessor {
  final CssExpressions _exprs;
  int _index = 0;

  ExpressionsProcessor(this._exprs);

  CssFontExpression processFontSize() {
    CssLengthTerm? size;
    LineHeight? lineHt;
    bool nextIsLineHeight = false;
    for (; _index < _exprs.expressions.length; _index++) {
      CssExpression expr = _exprs.expressions[_index];
      if (size == null && expr is CssLengthTerm) {
        size = expr;
      } else if (size != null) {
        if (expr is CssOperatorSlash) {
          nextIsLineHeight = true;
        } else if (nextIsLineHeight && expr is CssLengthTerm) {
          assert(expr.unit == CssTokenKind.UNIT_LENGTH_PX);
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

    return CssFontExpression(_exprs.span, size: size, lineHeight: lineHt);
  }

  CssFontExpression processFontFamily() {
    List<String> family = <String>[];

    bool moreFamilies = false;

    for (; _index < _exprs.expressions.length; _index++) {
      CssExpression expr = _exprs.expressions[_index];
      if (expr is CssLiteralTerm) {
        if (family.isEmpty || moreFamilies) {
          family.add(expr.toString());
          moreFamilies = false;
        } else if (isChecked) {
          messages.warning('Only font-family can be a list', _exprs.span);
        }
      } else if (expr is CssOperatorComma && family.isNotEmpty) {
        moreFamilies = true;
      } else {
        break;
      }
    }

    return CssFontExpression(_exprs.span, family: family);
  }

  CssFontExpression processFont() {
    CssFontExpression? fontSize;
    CssFontExpression? fontFamily;
    for (; _index < _exprs.expressions.length; _index++) {
      fontSize ??= processFontSize();
      fontFamily ??= processFontFamily();
    }

    return CssFontExpression(_exprs.span,
        size: fontSize!.font.size,
        lineHeight: fontSize.font.lineHeight,
        family: fontFamily!.font.family);
  }
}

String _escapeString(String text, {bool single = false}) {
  StringBuffer? result;

  for (int i = 0; i < text.length; i++) {
    int code = text.codeUnitAt(i);
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
