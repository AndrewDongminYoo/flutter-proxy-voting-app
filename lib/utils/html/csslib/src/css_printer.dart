part of '../visitor.dart';

class CssPrinter extends Visitor {
  StringBuffer _buff = StringBuffer();
  bool prettyPrint = true;
  bool _isInKeyframes = false;

  @override
  void visitTree(StyleSheet tree, {bool pretty = false}) {
    prettyPrint = pretty;
    _buff = StringBuffer();
    visitStyleSheet(tree);
  }

  void emit(String str) {
    _buff.write(str);
  }

  @override
  String toString() => _buff.toString().trim();

  String get _newLine => prettyPrint ? '\n' : '';
  String get _sp => prettyPrint ? ' ' : '';

  bool get _isTesting => !prettyPrint;

  @override
  void visitCalcTerm(CalcTerm node) {
    emit('${node.text}(');
    node.expr.visit(this);
    emit(')');
  }

  @override
  void visitCssComment(CssComment node) {
    emit('/* ${node.comment} */');
  }

  @override
  void visitCommentDefinition(CommentDefinition node) {
    emit('<!-- ${node.comment} -->');
  }

  @override
  void visitMediaExpression(MediaExpression node) {
    emit(node.andOperator ? ' AND ' : ' ');
    emit('(${node.mediaFeature}');
    if (node.exprs.expressions.isNotEmpty) {
      emit(':');
      visitExpressions(node.exprs);
    }
    emit(')');
  }

  @override
  void visitMediaQuery(MediaQuery node) {
    String unary = node.hasUnary ? ' ${node.unary}' : '';
    String mediaType = node.hasMediaType ? ' ${node.mediaType}' : '';
    emit('$unary$mediaType');
    for (MediaExpression expression in node.expressions) {
      visitMediaExpression(expression);
    }
  }

  void emitMediaQueries(List<MediaQuery> queries) {
    int queriesLen = queries.length;
    for (int i = 0; i < queriesLen; i++) {
      var query = queries[i];
      if (i > 0) emit(',');
      visitMediaQuery(query);
    }
  }

  @override
  void visitDocumentDirective(DocumentDirective node) {
    emit('$_newLine@-moz-document ');
    node.functions.first.visit(this);
    for (LiteralTerm function in node.functions.skip(1)) {
      emit(',$_sp');
      function.visit(this);
    }
    emit('$_sp{');
    for (TreeNode ruleSet in node.groupRuleBody) {
      ruleSet.visit(this);
    }
    emit('$_newLine}');
  }

  @override
  void visitSupportsDirective(SupportsDirective node) {
    emit('$_newLine@supports ');
    node.condition!.visit(this);
    emit('$_sp{');
    for (TreeNode rule in node.groupRuleBody) {
      rule.visit(this);
    }
    emit('$_newLine}');
  }

  @override
  void visitSupportsConditionInParens(SupportsConditionInParens node) {
    emit('(');
    node.condition!.visit(this);
    emit(')');
  }

  @override
  void visitSupportsNegation(SupportsNegation node) {
    emit('not$_sp');
    node.condition.visit(this);
  }

  @override
  void visitSupportsConjunction(SupportsConjunction node) {
    node.conditions.first.visit(this);
    for (SupportsConditionInParens condition in node.conditions.skip(1)) {
      emit('${_sp}and$_sp');
      condition.visit(this);
    }
  }

  @override
  void visitSupportsDisjunction(SupportsDisjunction node) {
    node.conditions.first.visit(this);
    for (SupportsConditionInParens condition in node.conditions.skip(1)) {
      emit('${_sp}or$_sp');
      condition.visit(this);
    }
  }

  @override
  void visitViewportDirective(ViewportDirective node) {
    emit('@${node.name}$_sp{$_newLine');
    node.declarations.visit(this);
    emit('}');
  }

  @override
  void visitMediaDirective(MediaDirective node) {
    emit('$_newLine@media');
    emitMediaQueries(node.mediaQueries.cast<MediaQuery>());
    emit('$_sp{');
    for (TreeNode ruleset in node.rules) {
      ruleset.visit(this);
    }
    emit('$_newLine}');
  }

  @override
  void visitHostDirective(HostDirective node) {
    emit('$_newLine@host$_sp{');
    for (TreeNode ruleset in node.rules) {
      ruleset.visit(this);
    }
    emit('$_newLine}');
  }

  @override
  void visitPageDirective(PageDirective node) {
    emit('$_newLine@page');
    if (node.hasIdent || node.hasPseudoPage) {
      if (node.hasIdent) emit(' ');
      emit(node._ident!);
      emit(node.hasPseudoPage ? ':${node._pseudoPage}' : '');
    }

    List<DeclarationGroup> declsMargin = node._declsMargin;
    int declsMarginLength = declsMargin.length;
    emit('$_sp{$_newLine');
    for (int i = 0; i < declsMarginLength; i++) {
      declsMargin[i].visit(this);
    }
    emit('}');
  }

  @override
  void visitCharsetDirective(CharsetDirective node) {
    emit('$_newLine@charset "${node.charEncoding}";');
  }

  @override
  void visitImportDirective(ImportDirective node) {
    bool isStartingQuote(String ch) => ('\'"'.contains(ch[0]));

    if (_isTesting) {
      emit(' @import url(${node.import})');
    } else if (isStartingQuote(node.import)) {
      emit(' @import ${node.import}');
    } else {
      emit(' @import "${node.import}"');
    }
    emitMediaQueries(node.mediaQueries);
    emit(';');
  }

  @override
  void visitKeyFrameDirective(KeyFrameDirective node) {
    emit('$_newLine${node.keyFrameName} ');
    node.name!.visit(this);
    emit('$_sp{$_newLine');
    _isInKeyframes = true;
    for (final block in node._blocks) {
      block.visit(this);
    }
    _isInKeyframes = false;
    emit('}');
  }

  @override
  void visitFontFaceDirective(FontFaceDirective node) {
    emit('$_newLine@font-face ');
    emit('$_sp{$_newLine');
    node._declarations.visit(this);
    emit('}');
  }

  @override
  void visitKeyFrameBlock(KeyFrameBlock node) {
    emit('$_sp$_sp');
    node._blockSelectors.visit(this);
    emit('$_sp{$_newLine');
    node._declarations.visit(this);
    emit('$_sp$_sp}$_newLine');
  }

  @override
  void visitStyletDirective(StyletDirective node) {
    emit('/* @stylet export as ${node.dartClassName} */\n');
  }

  @override
  void visitNamespaceDirective(NamespaceDirective node) {
    bool isStartingQuote(String ch) => ('\'"'.contains(ch));

    if (isStartingQuote(node._uri!)) {
      emit(' @namespace ${node.prefix}"${node._uri}"');
    } else {
      if (_isTesting) {
        emit(' @namespace ${node.prefix}url(${node._uri})');
      } else {
        emit(' @namespace ${node.prefix}${node._uri}');
      }
    }
    emit(';');
  }

  @override
  void visitVarDefinitionDirective(VarDefinitionDirective node) {
    visitVarDefinition(node.def);
    emit(';$_newLine');
  }

  @override
  void visitMixinRulesetDirective(MixinRulesetDirective node) {
    emit('@mixin ${node.name} {');
    for (TreeNode ruleset in node.rulesets) {
      ruleset.visit(this);
    }
    emit('}');
  }

  @override
  void visitMixinDeclarationDirective(MixinDeclarationDirective node) {
    emit('@mixin ${node.name} {\n');
    visitDeclarationGroup(node.declarations);
    emit('}');
  }

  @override
  void visitIncludeDirective(IncludeDirective node, [bool topLevel = true]) {
    if (topLevel) emit(_newLine);
    emit('@include ${node.name}');
    emit(';');
  }

  @override
  void visitContentDirective(ContentDirective node) {}

  @override
  void visitRuleSet(RuleSet node) {
    emit(_newLine);
    node.selectorGroup!.visit(this);
    emit('$_sp{$_newLine');
    node.declarationGroup.visit(this);
    emit('}');
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    List<TreeNode> declarations = node.declarations;
    int declarationsLength = declarations.length;
    for (int i = 0; i < declarationsLength; i++) {
      if (i > 0) emit(_newLine);
      emit('$_sp$_sp');
      declarations[i].visit(this);
      if (prettyPrint || i < declarationsLength - 1) {
        emit(';');
      }
    }
    if (declarationsLength > 0) emit(_newLine);
  }

  @override
  void visitMarginGroup(MarginGroup node) {
    String? marginSymName =
        TokenKind.idToValue(TokenKind.MARGIN_DIRECTIVES, node.marginSym);

    emit('@$marginSymName$_sp{$_newLine');

    visitDeclarationGroup(node);

    emit('}$_newLine');
  }

  @override
  void visitDeclaration(Declaration node) {
    emit('${node.property}:$_sp');
    node.expression!.visit(this);
    if (node.important) {
      emit('$_sp!important');
    }
  }

  @override
  void visitVarDefinition(VarDefinition node) {
    emit('var-${node.definedName}: ');
    node.expression!.visit(this);
  }

  @override
  void visitIncludeMixinAtDeclaration(IncludeMixinAtDeclaration node) {
    visitIncludeDirective(node.include, false);
  }

  @override
  void visitExtendDeclaration(ExtendDeclaration node) {
    emit('@extend ');
    for (TreeNode selector in node.selectors) {
      selector.visit(this);
    }
  }

  @override
  void visitSelectorGroup(SelectorGroup node) {
    List<Selector> selectors = node.selectors;
    int selectorsLength = selectors.length;
    for (int i = 0; i < selectorsLength; i++) {
      if (i > 0) emit(',$_sp');
      selectors[i].visit(this);
    }
  }

  @override
  void visitSimpleSelectorSequence(SimpleSelectorSequence node) {
    emit(node._combinatorToString);
    node.simpleSelector.visit(this);
  }

  @override
  void visitSimpleSelector(SimpleSelector node) {
    emit(node.name);
  }

  @override
  void visitNamespaceSelector(NamespaceSelector node) {
    emit(node.toString());
  }

  @override
  void visitElementSelector(ElementSelector node) {
    emit(node.toString());
  }

  @override
  void visitAttributeSelector(AttributeSelector node) {
    emit(node.toString());
  }

  @override
  void visitIdSelector(IdSelector node) {
    emit(node.toString());
  }

  @override
  void visitClassSelector(ClassSelector node) {
    emit(node.toString());
  }

  @override
  void visitPseudoClassSelector(PseudoClassSelector node) {
    emit(node.toString());
  }

  @override
  void visitPseudoElementSelector(PseudoElementSelector node) {
    emit(node.toString());
  }

  @override
  void visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node) {
    emit(':${node.name}(');
    node.argument.visit(this);
    emit(')');
  }

  @override
  void visitPseudoElementFunctionSelector(PseudoElementFunctionSelector node) {
    emit('::${node.name}(');
    node.expression.visit(this);
    emit(')');
  }

  @override
  void visitNegationSelector(NegationSelector node) {
    emit(':not(');
    node.negationArg!.visit(this);
    emit(')');
  }

  @override
  void visitSelectorExpression(SelectorExpression node) {
    List<Expression> expressions = node.expressions;
    int expressionsLength = expressions.length;
    for (int i = 0; i < expressionsLength; i++) {
      Expression expression = expressions[i];
      expression.visit(this);
    }
  }

  @override
  void visitUnicodeRangeTerm(UnicodeRangeTerm node) {
    if (node.hasSecond) {
      emit('U+${node.first}-${node.second}');
    } else {
      emit('U+${node.first}');
    }
  }

  @override
  void visitLiteralTerm(LiteralTerm node) {
    emit(node.text);
  }

  @override
  void visitHexColorTerm(HexColorTerm node) {
    String? mappedName;
    if (_isTesting && (node.value is! BadHexValue)) {
      mappedName = TokenKind.hexToColorName(node.value);
    }
    mappedName ??= '#${node.text}';

    emit(mappedName);
  }

  @override
  void visitNumberTerm(NumberTerm node) {
    visitLiteralTerm(node);
  }

  @override
  void visitUnitTerm(UnitTerm node) {
    emit(node.toString());
  }

  @override
  void visitLengthTerm(LengthTerm node) {
    emit(node.toString());
  }

  @override
  void visitPercentageTerm(PercentageTerm node) {
    emit('${node.text}%');
  }

  @override
  void visitEmTerm(EmTerm node) {
    emit('${node.text}em');
  }

  @override
  void visitExTerm(ExTerm node) {
    emit('${node.text}ex');
  }

  @override
  void visitAngleTerm(AngleTerm node) {
    emit(node.toString());
  }

  @override
  void visitTimeTerm(TimeTerm node) {
    emit(node.toString());
  }

  @override
  void visitFreqTerm(FreqTerm node) {
    emit(node.toString());
  }

  @override
  void visitFractionTerm(FractionTerm node) {
    emit('${node.text}fr');
  }

  @override
  void visitUriTerm(UriTerm node) {
    emit('url("${node.text}")');
  }

  @override
  void visitResolutionTerm(ResolutionTerm node) {
    emit(node.toString());
  }

  @override
  void visitViewportTerm(ViewportTerm node) {
    emit(node.toString());
  }

  @override
  void visitFunctionTerm(FunctionTerm node) {
    emit('${node.text}(');
    node._params.visit(this);
    emit(')');
  }

  @override
  void visitGroupTerm(GroupTerm node) {
    emit('(');
    List<LiteralTerm> terms = node._terms;
    int termsLength = terms.length;
    for (int i = 0; i < termsLength; i++) {
      if (i > 0) emit(_sp);
      terms[i].visit(this);
    }
    emit(')');
  }

  @override
  void visitItemTerm(ItemTerm node) {
    emit('[${node.text}]');
  }

  @override
  void visitIE8Term(IE8Term node) {
    visitLiteralTerm(node);
  }

  @override
  void visitOperatorSlash(OperatorSlash node) {
    emit('/');
  }

  @override
  void visitOperatorComma(OperatorComma node) {
    emit(',');
  }

  @override
  void visitOperatorPlus(OperatorPlus node) {
    emit('+');
  }

  @override
  void visitOperatorMinus(OperatorMinus node) {
    emit('-');
  }

  @override
  void visitVarUsage(VarUsage node) {
    emit('var(${node.name}');
    if (node.defaultValues.isNotEmpty) {
      emit(',');
      for (Expression defaultValue in node.defaultValues) {
        emit(' ');
        defaultValue.visit(this);
      }
    }
    emit(')');
  }

  @override
  void visitExpressions(Expressions node) {
    List<Expression> expressions = node.expressions;
    int expressionsLength = expressions.length;
    for (int i = 0; i < expressionsLength; i++) {
      Expression expression = expressions[i];
      if (i > 0 &&
          !(expression is OperatorComma || expression is OperatorSlash)) {
        Expression previous = expressions[i - 1];
        if (previous is OperatorComma || previous is OperatorSlash) {
          emit(_sp);
        } else if (previous is PercentageTerm &&
            expression is PercentageTerm &&
            _isInKeyframes) {
          emit(',');
          emit(_sp);
        } else {
          emit(' ');
        }
      }
      expression.visit(this);
    }
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    throw UnimplementedError;
  }

  @override
  void visitUnaryExpression(UnaryExpression node) {
    throw UnimplementedError;
  }

  @override
  void visitIdentifier(Identifier node) {
    emit(node.name);
  }

  @override
  void visitWildcard(Wildcard node) {
    emit('*');
  }

  @override
  void visitDartStyleExpression(DartStyleExpression node) {
    throw UnimplementedError;
  }
}
