part of '../visitor.dart';

class CssPrinter extends Visitor {
  StringBuffer _buff = StringBuffer();
  bool prettyPrint = true;
  bool _isInKeyframes = false;

  @override
  void visitTree(CssStyleSheet tree, {bool pretty = false}) {
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
  void visitCalcTerm(CssCalcTerm node) {
    emit('${node.text}(');
    node.expr.visit(this);
    emit(')');
  }

  @override
  void visitCssComment(CssComment node) {
    emit('/* ${node.comment} */');
  }

  @override
  void visitCommentDefinition(CssCommentDefinition node) {
    emit('<!-- ${node.comment} -->');
  }

  @override
  void visitMediaExpression(CssMediaExpression node) {
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
    for (CssMediaExpression expression in node.expressions) {
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
  void visitDocumentDirective(CssDocumentDirective node) {
    emit('$_newLine@-moz-document ');
    node.functions.first.visit(this);
    for (CssLiteralTerm function in node.functions.skip(1)) {
      emit(',$_sp');
      function.visit(this);
    }
    emit('$_sp{');
    for (CssTreeNode ruleSet in node.groupRuleBody) {
      ruleSet.visit(this);
    }
    emit('$_newLine}');
  }

  @override
  void visitSupportsDirective(CssSupportsDirective node) {
    emit('$_newLine@supports ');
    node.condition!.visit(this);
    emit('$_sp{');
    for (CssTreeNode rule in node.groupRuleBody) {
      rule.visit(this);
    }
    emit('$_newLine}');
  }

  @override
  void visitSupportsConditionInParens(CssSupportsConditionInParens node) {
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
    for (CssSupportsConditionInParens condition in node.conditions.skip(1)) {
      emit('${_sp}and$_sp');
      condition.visit(this);
    }
  }

  @override
  void visitSupportsDisjunction(CssSupportsDisjunction node) {
    node.conditions.first.visit(this);
    for (CssSupportsConditionInParens condition in node.conditions.skip(1)) {
      emit('${_sp}or$_sp');
      condition.visit(this);
    }
  }

  @override
  void visitViewportDirective(CssViewportDirective node) {
    emit('@${node.name}$_sp{$_newLine');
    node.declarations.visit(this);
    emit('}');
  }

  @override
  void visitMediaDirective(CssMediaDirective node) {
    emit('$_newLine@media');
    emitMediaQueries(node.mediaQueries.cast<MediaQuery>());
    emit('$_sp{');
    for (CssTreeNode ruleset in node.rules) {
      ruleset.visit(this);
    }
    emit('$_newLine}');
  }

  @override
  void visitHostDirective(CssHostDirective node) {
    emit('$_newLine@host$_sp{');
    for (CssTreeNode ruleset in node.rules) {
      ruleset.visit(this);
    }
    emit('$_newLine}');
  }

  @override
  void visitPageDirective(CssPageDirective node) {
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
  void visitCharsetDirective(CssCharsetDirective node) {
    emit('$_newLine@charset "${node.charEncoding}";');
  }

  @override
  void visitImportDirective(CssImportDirective node) {
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
  void visitKeyFrameDirective(CssKeyFrameDirective node) {
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
  void visitKeyFrameBlock(CssKeyFrameBlock node) {
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
  void visitNamespaceDirective(CssNamespaceDirective node) {
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
  void visitVarDefinitionDirective(CssVarDefinitionDirective node) {
    visitVarDefinition(node.def);
    emit(';$_newLine');
  }

  @override
  void visitMixinRulesetDirective(CssMixinRulesetDirective node) {
    emit('@mixin ${node.name} {');
    for (CssTreeNode ruleset in node.rulesets) {
      ruleset.visit(this);
    }
    emit('}');
  }

  @override
  void visitMixinDeclarationDirective(CssMixinDeclarationDirective node) {
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
  void visitContentDirective(CssContentDirective node) {}

  @override
  void visitRuleSet(CssRuleSet node) {
    emit(_newLine);
    node.selectorGroup!.visit(this);
    emit('$_sp{$_newLine');
    node.declarationGroup.visit(this);
    emit('}');
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    List<CssTreeNode> declarations = node.declarations;
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
  void visitMarginGroup(CssMarginGroup node) {
    String? marginSymName =
        CssTokenKind.idToValue(CssTokenKind.MARGIN_DIRECTIVES, node.marginSym);

    emit('@$marginSymName$_sp{$_newLine');

    visitDeclarationGroup(node);

    emit('}$_newLine');
  }

  @override
  void visitDeclaration(CssDeclaration node) {
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
  void visitIncludeMixinAtDeclaration(CssIncludeMixinAtDeclaration node) {
    visitIncludeDirective(node.include, false);
  }

  @override
  void visitExtendDeclaration(CssExtendDeclaration node) {
    emit('@extend ');
    for (CssTreeNode selector in node.selectors) {
      selector.visit(this);
    }
  }

  @override
  void visitSelectorGroup(CssSelectorGroup node) {
    List<CssSelector> selectors = node.selectors;
    int selectorsLength = selectors.length;
    for (int i = 0; i < selectorsLength; i++) {
      if (i > 0) emit(',$_sp');
      selectors[i].visit(this);
    }
  }

  @override
  void visitSimpleSelectorSequence(CssSimpleSelectorSequence node) {
    emit(node._combinatorToString);
    node.simpleSelector.visit(this);
  }

  @override
  void visitSimpleSelector(CssSimpleSelector node) {
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
  void visitAttributeSelector(CssAttributeSelector node) {
    emit(node.toString());
  }

  @override
  void visitIdSelector(CssIdSelector node) {
    emit(node.toString());
  }

  @override
  void visitClassSelector(CssClassSelector node) {
    emit(node.toString());
  }

  @override
  void visitPseudoClassSelector(CssPseudoClassSelector node) {
    emit(node.toString());
  }

  @override
  void visitPseudoElementSelector(CssPseudoElementSelector node) {
    emit(node.toString());
  }

  @override
  void visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node) {
    emit(':${node.name}(');
    node.argument.visit(this);
    emit(')');
  }

  @override
  void visitPseudoElementFunctionSelector(
      CssPseudoElementFunctionSelector node) {
    emit('::${node.name}(');
    node.expression.visit(this);
    emit(')');
  }

  @override
  void visitNegationSelector(CssNegationSelector node) {
    emit(':not(');
    node.negationArg!.visit(this);
    emit(')');
  }

  @override
  void visitSelectorExpression(CssSelectorExpression node) {
    List<CssExpression> expressions = node.expressions;
    int expressionsLength = expressions.length;
    for (int i = 0; i < expressionsLength; i++) {
      CssExpression expression = expressions[i];
      expression.visit(this);
    }
  }

  @override
  void visitUnicodeRangeTerm(CssUnicodeRangeTerm node) {
    if (node.hasSecond) {
      emit('U+${node.first}-${node.second}');
    } else {
      emit('U+${node.first}');
    }
  }

  @override
  void visitLiteralTerm(CssLiteralTerm node) {
    emit(node.text);
  }

  @override
  void visitHexColorTerm(CssHexColorTerm node) {
    String? mappedName;
    if (_isTesting && (node.value is! BadHexValue)) {
      mappedName = CssTokenKind.hexToColorName(node.value);
    }
    mappedName ??= '#${node.text}';

    emit(mappedName);
  }

  @override
  void visitNumberTerm(CssNumberTerm node) {
    visitLiteralTerm(node);
  }

  @override
  void visitUnitTerm(CssUnitTerm node) {
    emit(node.toString());
  }

  @override
  void visitLengthTerm(CssLengthTerm node) {
    emit(node.toString());
  }

  @override
  void visitPercentageTerm(CssPercentageTerm node) {
    emit('${node.text}%');
  }

  @override
  void visitEmTerm(CssEmTerm node) {
    emit('${node.text}em');
  }

  @override
  void visitExTerm(CssExTerm node) {
    emit('${node.text}ex');
  }

  @override
  void visitAngleTerm(CssAngleTerm node) {
    emit(node.toString());
  }

  @override
  void visitTimeTerm(CssTimeTerm node) {
    emit(node.toString());
  }

  @override
  void visitFreqTerm(CssFreqTerm node) {
    emit(node.toString());
  }

  @override
  void visitFractionTerm(CssFractionTerm node) {
    emit('${node.text}fr');
  }

  @override
  void visitUriTerm(CssUriTerm node) {
    emit('url("${node.text}")');
  }

  @override
  void visitResolutionTerm(CssResolutionTerm node) {
    emit(node.toString());
  }

  @override
  void visitViewportTerm(CssViewportTerm node) {
    emit(node.toString());
  }

  @override
  void visitFunctionTerm(CssFunctionTerm node) {
    emit('${node.text}(');
    node._params.visit(this);
    emit(')');
  }

  @override
  void visitGroupTerm(CssGroupTerm node) {
    emit('(');
    List<CssLiteralTerm> terms = node._terms;
    int termsLength = terms.length;
    for (int i = 0; i < termsLength; i++) {
      if (i > 0) emit(_sp);
      terms[i].visit(this);
    }
    emit(')');
  }

  @override
  void visitItemTerm(CssItemTerm node) {
    emit('[${node.text}]');
  }

  @override
  void visitIE8Term(CssIE8Term node) {
    visitLiteralTerm(node);
  }

  @override
  void visitOperatorSlash(CssOperatorSlash node) {
    emit('/');
  }

  @override
  void visitOperatorComma(CssOperatorComma node) {
    emit(',');
  }

  @override
  void visitOperatorPlus(CssOperatorPlus node) {
    emit('+');
  }

  @override
  void visitOperatorMinus(CssOperatorMinus node) {
    emit('-');
  }

  @override
  void visitVarUsage(CssVarUsage node) {
    emit('var(${node.name}');
    if (node.defaultValues.isNotEmpty) {
      emit(',');
      for (CssExpression defaultValue in node.defaultValues) {
        emit(' ');
        defaultValue.visit(this);
      }
    }
    emit(')');
  }

  @override
  void visitExpressions(CssExpressions node) {
    List<CssExpression> expressions = node.expressions;
    int expressionsLength = expressions.length;
    for (int i = 0; i < expressionsLength; i++) {
      CssExpression expression = expressions[i];
      if (i > 0 &&
          !(expression is CssOperatorComma || expression is CssOperatorSlash)) {
        CssExpression previous = expressions[i - 1];
        if (previous is CssOperatorComma || previous is CssOperatorSlash) {
          emit(_sp);
        } else if (previous is CssPercentageTerm &&
            expression is CssPercentageTerm &&
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
  void visitBinaryExpression(CssBinaryExpression node) {
    throw UnimplementedError;
  }

  @override
  void visitUnaryExpression(UnaryExpression node) {
    throw UnimplementedError;
  }

  @override
  void visitIdentifier(CssIdentifier node) {
    emit(node.name);
  }

  @override
  void visitWildcard(CssWildcard node) {
    emit('*');
  }

  @override
  void visitDartStyleExpression(CssDartStyleExpression node) {
    throw UnimplementedError;
  }
}
