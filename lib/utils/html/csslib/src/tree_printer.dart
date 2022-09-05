part of '../visitor.dart';

String treeToDebugString(CssStyleSheet styleSheet, [bool useSpan = false]) {
  TreeOutput to = TreeOutput();
  _TreePrinter(to, useSpan).visitTree(styleSheet);
  return to.toString();
}

class _TreePrinter extends Visitor {
  final TreeOutput output;
  final bool useSpan;
  _TreePrinter(this.output, this.useSpan) {
    output.printer = this;
  }

  @override
  void visitTree(CssStyleSheet tree) => visitStylesheet(tree);

  void heading(String heading, CssTreeNode node) {
    if (useSpan) {
      output.heading(heading, node.span);
    } else {
      output.heading(heading);
    }
  }

  void visitStylesheet(CssStyleSheet node) {
    heading('Stylesheet', node);
    output.depth++;
    super.visitStyleSheet(node);
    output.depth--;
  }

  @override
  void visitTopLevelProduction(CssTopLevelProduction node) {
    heading('TopLevelProduction', node);
  }

  @override
  void visitDirective(Directive node) {
    heading('Directive', node);
  }

  @override
  void visitCalcTerm(CssCalcTerm node) {
    heading('CalcTerm', node);
    output.depth++;
    super.visitCalcTerm(node);
    output.depth--;
  }

  @override
  void visitCssComment(CssComment node) {
    heading('Comment', node);
    output.depth++;
    output.writeValue('comment value', node.comment);
    output.depth--;
  }

  @override
  void visitCommentDefinition(CssCommentDefinition node) {
    heading('CommentDefinition (CDO/CDC)', node);
    output.depth++;
    output.writeValue('comment value', node.comment);
    output.depth--;
  }

  @override
  void visitMediaExpression(CssMediaExpression node) {
    heading('MediaExpression', node);
    output.writeValue('feature', node.mediaFeature);
    if (node.andOperator) output.writeValue('AND operator', '');
    visitExpressions(node.exprs);
  }

  void visitMediaQueries(MediaQuery query) {
    output.heading('MediaQueries');
    output.writeValue('unary', query.unary);
    output.writeValue('media type', query.mediaType);
    output.writeNodeList('media expressions', query.expressions);
  }

  @override
  void visitMediaDirective(CssMediaDirective node) {
    heading('MediaDirective', node);
    output.depth++;
    output.writeNodeList('media queries', node.mediaQueries);
    output.writeNodeList('rule sets', node.rules);
    super.visitMediaDirective(node);
    output.depth--;
  }

  @override
  void visitDocumentDirective(CssDocumentDirective node) {
    heading('DocumentDirective', node);
    output.depth++;
    output.writeNodeList('functions', node.functions);
    output.writeNodeList('group rule body', node.groupRuleBody);
    output.depth--;
  }

  @override
  void visitSupportsDirective(CssSupportsDirective node) {
    heading('SupportsDirective', node);
    output.depth++;
    output.writeNode('condition', node.condition);
    output.writeNodeList('group rule body', node.groupRuleBody);
    output.depth--;
  }

  @override
  void visitSupportsConditionInParens(CssSupportsConditionInParens node) {
    heading('SupportsConditionInParens', node);
    output.depth++;
    output.writeNode('condition', node.condition);
    output.depth--;
  }

  @override
  void visitSupportsNegation(SupportsNegation node) {
    heading('SupportsNegation', node);
    output.depth++;
    output.writeNode('condition', node.condition);
    output.depth--;
  }

  @override
  void visitSupportsConjunction(SupportsConjunction node) {
    heading('SupportsConjunction', node);
    output.depth++;
    output.writeNodeList('conditions', node.conditions);
    output.depth--;
  }

  @override
  void visitSupportsDisjunction(CssSupportsDisjunction node) {
    heading('SupportsDisjunction', node);
    output.depth++;
    output.writeNodeList('conditions', node.conditions);
    output.depth--;
  }

  @override
  void visitViewportDirective(CssViewportDirective node) {
    heading('ViewportDirective', node);
    output.depth++;
    super.visitViewportDirective(node);
    output.depth--;
  }

  @override
  void visitPageDirective(CssPageDirective node) {
    heading('PageDirective', node);
    output.depth++;
    output.writeValue('pseudo page', node._pseudoPage);
    super.visitPageDirective(node);
    output.depth;
  }

  @override
  void visitCharsetDirective(CssCharsetDirective node) {
    heading('Charset Directive', node);
    output.writeValue('charset encoding', node.charEncoding);
  }

  @override
  void visitImportDirective(CssImportDirective node) {
    heading('ImportDirective', node);
    output.depth++;
    output.writeValue('import', node.import);
    super.visitImportDirective(node);
    output.writeNodeList('media', node.mediaQueries);
    output.depth--;
  }

  @override
  void visitContentDirective(CssContentDirective node) {
    if (kDebugMode) {
      print('ContentDirective not implemented');
    }
  }

  @override
  void visitKeyFrameDirective(CssKeyFrameDirective node) {
    heading('KeyFrameDirective', node);
    output.depth++;
    output.writeValue('keyframe', node.keyFrameName);
    output.writeValue('name', node.name);
    output.writeNodeList('blocks', node._blocks);
    output.depth--;
  }

  @override
  void visitKeyFrameBlock(CssKeyFrameBlock node) {
    heading('KeyFrameBlock', node);
    output.depth++;
    super.visitKeyFrameBlock(node);
    output.depth--;
  }

  @override
  void visitFontFaceDirective(FontFaceDirective node) {}

  @override
  void visitStyletDirective(StyletDirective node) {
    heading('StyletDirective', node);
    output.writeValue('dartClassName', node.dartClassName);
    output.depth++;
    output.writeNodeList('rulesets', node.rules);
    output.depth--;
  }

  @override
  void visitNamespaceDirective(CssNamespaceDirective node) {
    heading('NamespaceDirective', node);
    output.depth++;
    output.writeValue('prefix', node._prefix);
    output.writeValue('uri', node._uri);
    output.depth--;
  }

  @override
  void visitVarDefinitionDirective(CssVarDefinitionDirective node) {
    heading('Less variable definition', node);
    output.depth++;
    visitVarDefinition(node.def);
    output.depth--;
  }

  @override
  void visitMixinRulesetDirective(CssMixinRulesetDirective node) {
    heading('Mixin top-level ${node.name}', node);
    output.writeNodeList('parameters', node.definedArgs);
    output.depth++;
    _visitNodeList(node.rulesets);
    output.depth--;
  }

  @override
  void visitMixinDeclarationDirective(CssMixinDeclarationDirective node) {
    heading('Mixin declaration ${node.name}', node);
    output.writeNodeList('parameters', node.definedArgs);
    output.depth++;
    visitDeclarationGroup(node.declarations);
    output.depth--;
  }

  @override
  void visitIncludeDirective(IncludeDirective node) {
    heading('IncludeDirective ${node.name}', node);
    List<CssExpression> flattened = node.args.expand((e) => e).toList();
    output.writeNodeList('parameters', flattened);
  }

  @override
  void visitIncludeMixinAtDeclaration(CssIncludeMixinAtDeclaration node) {
    heading('IncludeMixinAtDeclaration ${node.include.name}', node);
    output.depth++;
    visitIncludeDirective(node.include);
    output.depth--;
  }

  @override
  void visitExtendDeclaration(CssExtendDeclaration node) {
    heading('ExtendDeclaration', node);
    output.depth++;
    _visitNodeList(node.selectors);
    output.depth--;
  }

  @override
  void visitRuleSet(CssRuleSet node) {
    heading('Ruleset', node);
    output.depth++;
    super.visitRuleSet(node);
    output.depth--;
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    heading('DeclarationGroup', node);
    output.depth++;
    output.writeNodeList('declarations', node.declarations);
    output.depth--;
  }

  @override
  void visitMarginGroup(CssMarginGroup node) {
    heading('MarginGroup', node);
    output.depth++;
    output.writeValue('@directive', node.marginSym);
    output.writeNodeList('declarations', node.declarations);
    output.depth--;
  }

  @override
  void visitDeclaration(CssDeclaration node) {
    heading('Declaration', node);
    output.depth++;
    if (node.isIE7) output.write('IE7 property');
    output.write('property');
    super.visitDeclaration(node);
    output.writeNode('expression', node.expression);
    if (node.important) {
      output.writeValue('!important', 'true');
    }
    output.depth--;
  }

  @override
  void visitVarDefinition(VarDefinition node) {
    heading('Var', node);
    output.depth++;
    output.write('defintion');
    super.visitVarDefinition(node);
    output.writeNode('expression', node.expression);
    output.depth--;
  }

  @override
  void visitSelectorGroup(CssSelectorGroup node) {
    heading('Selector Group', node);
    output.depth++;
    output.writeNodeList('selectors', node.selectors);
    output.depth--;
  }

  @override
  void visitSelector(CssSelector node) {
    heading('Selector', node);
    output.depth++;
    output.writeNodeList(
        'simpleSelectorsSequences', node.simpleSelectorSequences);
    output.depth--;
  }

  @override
  void visitSimpleSelectorSequence(CssSimpleSelectorSequence node) {
    heading('SimpleSelectorSequence', node);
    output.depth++;
    if (node.isCombinatorNone) {
      output.writeValue('combinator', 'NONE');
    } else if (node.isCombinatorDescendant) {
      output.writeValue('combinator', 'descendant');
    } else if (node.isCombinatorPlus) {
      output.writeValue('combinator', '+');
    } else if (node.isCombinatorGreater) {
      output.writeValue('combinator', '>');
    } else if (node.isCombinatorTilde) {
      output.writeValue('combinator', '~');
    } else {
      output.writeValue('combinator', 'ERROR UNKNOWN');
    }

    super.visitSimpleSelectorSequence(node);

    output.depth--;
  }

  @override
  void visitNamespaceSelector(NamespaceSelector node) {
    heading('Namespace Selector', node);
    output.depth++;

    super.visitNamespaceSelector(node);

    visitSimpleSelector(node.nameAsSimpleSelector!);
    output.depth--;
  }

  @override
  void visitElementSelector(ElementSelector node) {
    heading('Element Selector', node);
    output.depth++;
    super.visitElementSelector(node);
    output.depth--;
  }

  @override
  void visitAttributeSelector(CssAttributeSelector node) {
    heading('AttributeSelector', node);
    output.depth++;
    super.visitAttributeSelector(node);
    String? tokenStr = node.matchOperatorAsTokenString();
    output.writeValue('operator', '${node.matchOperator()} ($tokenStr)');
    output.writeValue('value', node.valueToString());
    output.depth--;
  }

  @override
  void visitIdSelector(CssIdSelector node) {
    heading('Id Selector', node);
    output.depth++;
    super.visitIdSelector(node);
    output.depth--;
  }

  @override
  void visitClassSelector(CssClassSelector node) {
    heading('Class Selector', node);
    output.depth++;
    super.visitClassSelector(node);
    output.depth--;
  }

  @override
  void visitPseudoClassSelector(CssPseudoClassSelector node) {
    heading('Pseudo Class Selector', node);
    output.depth++;
    super.visitPseudoClassSelector(node);
    output.depth--;
  }

  @override
  void visitPseudoElementSelector(CssPseudoElementSelector node) {
    heading('Pseudo Element Selector', node);
    output.depth++;
    super.visitPseudoElementSelector(node);
    output.depth--;
  }

  @override
  void visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node) {
    heading('Pseudo Class Function Selector', node);
    output.depth++;
    node.argument.visit(this);
    super.visitPseudoClassFunctionSelector(node);
    output.depth--;
  }

  @override
  void visitPseudoElementFunctionSelector(
      CssPseudoElementFunctionSelector node) {
    heading('Pseudo Element Function Selector', node);
    output.depth++;
    visitSelectorExpression(node.expression);
    super.visitPseudoElementFunctionSelector(node);
    output.depth--;
  }

  @override
  void visitSelectorExpression(CssSelectorExpression node) {
    heading('Selector Expression', node);
    output.depth++;
    output.writeNodeList('expressions', node.expressions);
    output.depth--;
  }

  @override
  void visitNegationSelector(CssNegationSelector node) {
    super.visitNegationSelector(node);
    output.depth++;
    heading('Negation Selector', node);
    output.writeNode('Negation arg', node.negationArg);
    output.depth--;
  }

  @override
  void visitUnicodeRangeTerm(CssUnicodeRangeTerm node) {
    heading('UnicodeRangeTerm', node);
    output.depth++;
    output.writeValue('1st value', node.first);
    output.writeValue('2nd value', node.second);
    output.depth--;
  }

  @override
  void visitLiteralTerm(CssLiteralTerm node) {
    heading('LiteralTerm', node);
    output.depth++;
    output.writeValue('value', node.text);
    output.depth--;
  }

  @override
  void visitHexColorTerm(CssHexColorTerm node) {
    heading('HexColorTerm', node);
    output.depth++;
    output.writeValue('hex value', node.text);
    output.writeValue('decimal value', node.value);
    output.depth--;
  }

  @override
  void visitNumberTerm(CssNumberTerm node) {
    heading('NumberTerm', node);
    output.depth++;
    output.writeValue('value', node.text);
    output.depth--;
  }

  @override
  void visitUnitTerm(CssUnitTerm node) {
    output.depth++;
    output.writeValue('value', node.text);
    output.writeValue('unit', node.unitToString());
    output.depth--;
  }

  @override
  void visitLengthTerm(CssLengthTerm node) {
    heading('LengthTerm', node);
    super.visitLengthTerm(node);
  }

  @override
  void visitPercentageTerm(CssPercentageTerm node) {
    heading('PercentageTerm', node);
    output.depth++;
    super.visitPercentageTerm(node);
    output.depth--;
  }

  @override
  void visitEmTerm(CssEmTerm node) {
    heading('EmTerm', node);
    output.depth++;
    super.visitEmTerm(node);
    output.depth--;
  }

  @override
  void visitExTerm(CssExTerm node) {
    heading('ExTerm', node);
    output.depth++;
    super.visitExTerm(node);
    output.depth--;
  }

  @override
  void visitAngleTerm(CssAngleTerm node) {
    heading('AngleTerm', node);
    super.visitAngleTerm(node);
  }

  @override
  void visitTimeTerm(CssTimeTerm node) {
    heading('TimeTerm', node);
    super.visitTimeTerm(node);
  }

  @override
  void visitFreqTerm(CssFreqTerm node) {
    heading('FreqTerm', node);
    super.visitFreqTerm(node);
  }

  @override
  void visitFractionTerm(CssFractionTerm node) {
    heading('FractionTerm', node);
    output.depth++;
    super.visitFractionTerm(node);
    output.depth--;
  }

  @override
  void visitUriTerm(CssUriTerm node) {
    heading('UriTerm', node);
    output.depth++;
    super.visitUriTerm(node);
    output.depth--;
  }

  @override
  void visitFunctionTerm(CssFunctionTerm node) {
    heading('FunctionTerm', node);
    output.depth++;
    super.visitFunctionTerm(node);
    output.depth--;
  }

  @override
  void visitGroupTerm(CssGroupTerm node) {
    heading('GroupTerm', node);
    output.depth++;
    output.writeNodeList('grouped terms', node._terms);
    output.depth--;
  }

  @override
  void visitItemTerm(CssItemTerm node) {
    heading('ItemTerm', node);
    super.visitItemTerm(node);
  }

  @override
  void visitIE8Term(CssIE8Term node) {
    heading('IE8Term', node);
    visitLiteralTerm(node);
  }

  @override
  void visitOperatorSlash(CssOperatorSlash node) {
    heading('OperatorSlash', node);
  }

  @override
  void visitOperatorComma(CssOperatorComma node) {
    heading('OperatorComma', node);
  }

  @override
  void visitOperatorPlus(CssOperatorPlus node) {
    heading('OperatorPlus', node);
  }

  @override
  void visitOperatorMinus(CssOperatorMinus node) {
    heading('OperatorMinus', node);
  }

  @override
  void visitVarUsage(CssVarUsage node) {
    heading('Var', node);
    output.depth++;
    output.write('usage ${node.name}');
    output.writeNodeList('default values', node.defaultValues);
    output.depth--;
  }

  @override
  void visitExpressions(CssExpressions node) {
    heading('Expressions', node);
    output.depth++;
    output.writeNodeList('expressions', node.expressions);
    output.depth--;
  }

  @override
  void visitBinaryExpression(CssBinaryExpression node) {
    heading('BinaryExpression', node);
  }

  @override
  void visitUnaryExpression(UnaryExpression node) {
    heading('UnaryExpression', node);
  }

  @override
  void visitIdentifier(CssIdentifier node) {
    heading('Identifier(${output.toValue(node.name)})', node);
  }

  @override
  void visitWildcard(CssWildcard node) {
    heading('Wildcard(*)', node);
  }

  @override
  void visitDartStyleExpression(CssDartStyleExpression node) {
    heading('DartStyleExpression', node);
  }

  @override
  void visitFontExpression(CssFontExpression node) {
    heading('Dart Style FontExpression', node);
  }

  @override
  void visitBoxExpression(CssBoxExpression node) {
    heading('Dart Style BoxExpression', node);
  }

  @override
  void visitMarginExpression(CssMarginExpression node) {
    heading('Dart Style MarginExpression', node);
  }

  @override
  void visitBorderExpression(CssBorderExpression node) {
    heading('Dart Style BorderExpression', node);
  }

  @override
  void visitHeightExpression(CssHeightExpression node) {
    heading('Dart Style HeightExpression', node);
  }

  @override
  void visitPaddingExpression(CssPaddingExpression node) {
    heading('Dart Style PaddingExpression', node);
  }

  @override
  void visitWidthExpression(CssWidthExpression node) {
    heading('Dart Style WidthExpression', node);
  }
}
