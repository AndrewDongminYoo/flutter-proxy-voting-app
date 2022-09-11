// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:source_span/source_span.dart' show SourceSpan;

// 🌎 Project imports:
import 'parser.dart';

part 'src/css_printer.dart';
part 'src/tree.dart';
part 'src/tree_base.dart';
part 'src/tree_printer.dart';

abstract class VisitorBase {
  dynamic visitCalcTerm(CssCalcTerm node);
  dynamic visitCssComment(CssComment node);
  dynamic visitCommentDefinition(CssCommentDefinition node);
  dynamic visitStyleSheet(CssStyleSheet node);
  dynamic visitNoOp(CssNoOp node);
  dynamic visitTopLevelProduction(CssTopLevelProduction node);
  dynamic visitDirective(Directive node);
  dynamic visitDocumentDirective(CssDocumentDirective node);
  dynamic visitSupportsDirective(CssSupportsDirective node);
  dynamic visitSupportsConditionInParens(CssSupportsConditionInParens node);
  dynamic visitSupportsNegation(SupportsNegation node);
  dynamic visitSupportsConjunction(SupportsConjunction node);
  dynamic visitSupportsDisjunction(CssSupportsDisjunction node);
  dynamic visitViewportDirective(CssViewportDirective node);
  dynamic visitMediaExpression(CssMediaExpression node);
  dynamic visitMediaQuery(MediaQuery node);
  dynamic visitMediaDirective(CssMediaDirective node);
  dynamic visitHostDirective(CssHostDirective node);
  dynamic visitPageDirective(CssPageDirective node);
  dynamic visitCharsetDirective(CssCharsetDirective node);
  dynamic visitImportDirective(CssImportDirective node);
  dynamic visitKeyFrameDirective(CssKeyFrameDirective node);
  dynamic visitKeyFrameBlock(CssKeyFrameBlock node);
  dynamic visitFontFaceDirective(FontFaceDirective node);
  dynamic visitStyletDirective(StyletDirective node);
  dynamic visitNamespaceDirective(CssNamespaceDirective node);
  dynamic visitVarDefinitionDirective(CssVarDefinitionDirective node);
  dynamic visitMixinDefinition(CssMixinDefinition node);
  dynamic visitMixinRulesetDirective(CssMixinRulesetDirective node);
  dynamic visitMixinDeclarationDirective(CssMixinDeclarationDirective node);
  dynamic visitIncludeDirective(IncludeDirective node);
  dynamic visitContentDirective(CssContentDirective node);

  dynamic visitRuleSet(CssRuleSet node);
  dynamic visitDeclarationGroup(DeclarationGroup node);
  dynamic visitMarginGroup(CssMarginGroup node);
  dynamic visitDeclaration(CssDeclaration node);
  dynamic visitVarDefinition(VarDefinition node);
  dynamic visitIncludeMixinAtDeclaration(CssIncludeMixinAtDeclaration node);
  dynamic visitExtendDeclaration(CssExtendDeclaration node);
  dynamic visitSelectorGroup(CssSelectorGroup node);
  dynamic visitSelector(CssSelector node);
  dynamic visitSimpleSelectorSequence(CssSimpleSelectorSequence node);
  dynamic visitSimpleSelector(CssSimpleSelector node);
  dynamic visitElementSelector(ElementSelector node);
  dynamic visitNamespaceSelector(NamespaceSelector node);
  dynamic visitAttributeSelector(CssAttributeSelector node);
  dynamic visitIdSelector(CssIdSelector node);
  dynamic visitClassSelector(CssClassSelector node);
  dynamic visitPseudoClassSelector(CssPseudoClassSelector node);
  dynamic visitPseudoElementSelector(CssPseudoElementSelector node);
  dynamic visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node);
  dynamic visitPseudoElementFunctionSelector(
      CssPseudoElementFunctionSelector node);
  dynamic visitNegationSelector(CssNegationSelector node);
  dynamic visitSelectorExpression(CssSelectorExpression node);

  dynamic visitUnicodeRangeTerm(CssUnicodeRangeTerm node);
  dynamic visitLiteralTerm(CssLiteralTerm node);
  dynamic visitHexColorTerm(CssHexColorTerm node);
  dynamic visitNumberTerm(CssNumberTerm node);
  dynamic visitUnitTerm(CssUnitTerm node);
  dynamic visitLengthTerm(CssLengthTerm node);
  dynamic visitPercentageTerm(CssPercentageTerm node);
  dynamic visitEmTerm(CssEmTerm node);
  dynamic visitExTerm(CssExTerm node);
  dynamic visitAngleTerm(CssAngleTerm node);
  dynamic visitTimeTerm(CssTimeTerm node);
  dynamic visitFreqTerm(CssFreqTerm node);
  dynamic visitFractionTerm(CssFractionTerm node);
  dynamic visitUriTerm(CssUriTerm node);
  dynamic visitResolutionTerm(CssResolutionTerm node);
  dynamic visitChTerm(CssChTerm node);
  dynamic visitRemTerm(CssRemTerm node);
  dynamic visitViewportTerm(CssViewportTerm node);
  dynamic visitFunctionTerm(CssFunctionTerm node);
  dynamic visitGroupTerm(CssGroupTerm node);
  dynamic visitItemTerm(CssItemTerm node);
  dynamic visitIE8Term(CssIE8Term node);
  dynamic visitOperatorSlash(CssOperatorSlash node);
  dynamic visitOperatorComma(CssOperatorComma node);
  dynamic visitOperatorPlus(CssOperatorPlus node);
  dynamic visitOperatorMinus(CssOperatorMinus node);
  dynamic visitVarUsage(CssVarUsage node);

  dynamic visitExpressions(CssExpressions node);
  dynamic visitBinaryExpression(CssBinaryExpression node);
  dynamic visitUnaryExpression(UnaryExpression node);

  dynamic visitIdentifier(CssIdentifier node);
  dynamic visitWildcard(CssWildcard node);
  dynamic visitThisOperator(CssThisOperator node);
  dynamic visitNegation(CssNegation node);

  dynamic visitDartStyleExpression(CssDartStyleExpression node);
  dynamic visitFontExpression(CssFontExpression node);
  dynamic visitBoxExpression(CssBoxExpression node);
  dynamic visitMarginExpression(CssMarginExpression node);
  dynamic visitBorderExpression(CssBorderExpression node);
  dynamic visitHeightExpression(CssHeightExpression node);
  dynamic visitPaddingExpression(CssPaddingExpression node);
  dynamic visitWidthExpression(CssWidthExpression node);
}

class Visitor implements VisitorBase {
  void _visitNodeList(List<CssTreeNode> list) {
    for (int index = 0; index < list.length; index++) {
      list[index].visit(this);
    }
  }

  dynamic visitTree(CssStyleSheet tree) => visitStyleSheet(tree);

  @override
  dynamic visitStyleSheet(CssStyleSheet ss) {
    _visitNodeList(ss.topLevels);
  }

  @override
  dynamic visitNoOp(CssNoOp node) {}

  @override
  dynamic visitTopLevelProduction(CssTopLevelProduction node) {}

  @override
  dynamic visitDirective(Directive node) {}

  @override
  dynamic visitCalcTerm(CssCalcTerm node) {
    visitLiteralTerm(node);
    visitLiteralTerm(node.expr);
  }

  @override
  dynamic visitCssComment(CssComment node) {}

  @override
  dynamic visitCommentDefinition(CssCommentDefinition node) {}

  @override
  dynamic visitMediaExpression(CssMediaExpression node) {
    visitExpressions(node.exprs);
  }

  @override
  dynamic visitMediaQuery(MediaQuery node) {
    for (CssMediaExpression mediaExpr in node.expressions) {
      visitMediaExpression(mediaExpr);
    }
  }

  @override
  dynamic visitDocumentDirective(CssDocumentDirective node) {
    _visitNodeList(node.functions);
    _visitNodeList(node.groupRuleBody);
  }

  @override
  dynamic visitSupportsDirective(CssSupportsDirective node) {
    node.condition!.visit(this);
    _visitNodeList(node.groupRuleBody);
  }

  @override
  dynamic visitSupportsConditionInParens(CssSupportsConditionInParens node) {
    node.condition!.visit(this);
  }

  @override
  dynamic visitSupportsNegation(SupportsNegation node) {
    node.condition.visit(this);
  }

  @override
  dynamic visitSupportsConjunction(SupportsConjunction node) {
    _visitNodeList(node.conditions);
  }

  @override
  dynamic visitSupportsDisjunction(CssSupportsDisjunction node) {
    _visitNodeList(node.conditions);
  }

  @override
  dynamic visitViewportDirective(CssViewportDirective node) {
    node.declarations.visit(this);
  }

  @override
  dynamic visitMediaDirective(CssMediaDirective node) {
    _visitNodeList(node.mediaQueries);
    _visitNodeList(node.rules);
  }

  @override
  dynamic visitHostDirective(CssHostDirective node) {
    _visitNodeList(node.rules);
  }

  @override
  dynamic visitPageDirective(CssPageDirective node) {
    for (DeclarationGroup declGroup in node._declsMargin) {
      if (declGroup is CssMarginGroup) {
        visitMarginGroup(declGroup);
      } else {
        visitDeclarationGroup(declGroup);
      }
    }
  }

  @override
  dynamic visitCharsetDirective(CssCharsetDirective node) {}

  @override
  dynamic visitImportDirective(CssImportDirective node) {
    for (MediaQuery mediaQuery in node.mediaQueries) {
      visitMediaQuery(mediaQuery);
    }
  }

  @override
  dynamic visitKeyFrameDirective(CssKeyFrameDirective node) {
    visitIdentifier(node.name!);
    _visitNodeList(node._blocks);
  }

  @override
  dynamic visitKeyFrameBlock(CssKeyFrameBlock node) {
    visitExpressions(node._blockSelectors);
    visitDeclarationGroup(node._declarations);
  }

  @override
  dynamic visitFontFaceDirective(FontFaceDirective node) {
    visitDeclarationGroup(node._declarations);
  }

  @override
  dynamic visitStyletDirective(StyletDirective node) {
    _visitNodeList(node.rules);
  }

  @override
  dynamic visitNamespaceDirective(CssNamespaceDirective node) {}

  @override
  dynamic visitVarDefinitionDirective(CssVarDefinitionDirective node) {
    visitVarDefinition(node.def);
  }

  @override
  dynamic visitMixinRulesetDirective(CssMixinRulesetDirective node) {
    _visitNodeList(node.rulesets);
  }

  @override
  dynamic visitMixinDefinition(CssMixinDefinition node) {}

  @override
  dynamic visitMixinDeclarationDirective(CssMixinDeclarationDirective node) {
    visitDeclarationGroup(node.declarations);
  }

  @override
  dynamic visitIncludeDirective(IncludeDirective node) {
    for (int index = 0; index < node.args.length; index++) {
      List<CssExpression> param = node.args[index];
      _visitNodeList(param);
    }
  }

  @override
  dynamic visitContentDirective(CssContentDirective node) {}

  @override
  dynamic visitRuleSet(CssRuleSet node) {
    visitSelectorGroup(node.selectorGroup!);
    visitDeclarationGroup(node.declarationGroup);
  }

  @override
  dynamic visitDeclarationGroup(DeclarationGroup node) {
    _visitNodeList(node.declarations);
  }

  @override
  dynamic visitMarginGroup(CssMarginGroup node) => visitDeclarationGroup(node);

  @override
  dynamic visitDeclaration(CssDeclaration node) {
    visitIdentifier(node._property!);
    if (node.expression != null) node.expression!.visit(this);
  }

  @override
  dynamic visitVarDefinition(VarDefinition node) {
    visitIdentifier(node._property!);
    if (node.expression != null) node.expression!.visit(this);
  }

  @override
  dynamic visitIncludeMixinAtDeclaration(CssIncludeMixinAtDeclaration node) {
    visitIncludeDirective(node.include);
  }

  @override
  dynamic visitExtendDeclaration(CssExtendDeclaration node) {
    _visitNodeList(node.selectors);
  }

  @override
  dynamic visitSelectorGroup(CssSelectorGroup node) {
    _visitNodeList(node.selectors);
  }

  @override
  dynamic visitSelector(CssSelector node) {
    _visitNodeList(node.simpleSelectorSequences);
  }

  @override
  dynamic visitSimpleSelectorSequence(CssSimpleSelectorSequence node) {
    node.simpleSelector.visit(this);
  }

  @override
  dynamic visitSimpleSelector(CssSimpleSelector node) =>
      (node._name as CssTreeNode).visit(this);

  @override
  dynamic visitNamespaceSelector(NamespaceSelector node) {
    if (node._namespace != null) (node._namespace as CssTreeNode).visit(this);
    if (node.nameAsSimpleSelector != null) {
      node.nameAsSimpleSelector!.visit(this);
    }
  }

  @override
  dynamic visitElementSelector(ElementSelector node) =>
      visitSimpleSelector(node);

  @override
  dynamic visitAttributeSelector(CssAttributeSelector node) {
    visitSimpleSelector(node);
  }

  @override
  dynamic visitIdSelector(CssIdSelector node) => visitSimpleSelector(node);

  @override
  dynamic visitClassSelector(CssClassSelector node) =>
      visitSimpleSelector(node);

  @override
  dynamic visitPseudoClassSelector(CssPseudoClassSelector node) =>
      visitSimpleSelector(node);

  @override
  dynamic visitPseudoElementSelector(CssPseudoElementSelector node) =>
      visitSimpleSelector(node);

  @override
  dynamic visitPseudoClassFunctionSelector(PseudoClassFunctionSelector node) =>
      visitSimpleSelector(node);

  @override
  dynamic visitPseudoElementFunctionSelector(
          CssPseudoElementFunctionSelector node) =>
      visitSimpleSelector(node);

  @override
  dynamic visitNegationSelector(CssNegationSelector node) =>
      visitSimpleSelector(node);

  @override
  dynamic visitSelectorExpression(CssSelectorExpression node) {
    _visitNodeList(node.expressions);
  }

  @override
  dynamic visitUnicodeRangeTerm(CssUnicodeRangeTerm node) {}

  @override
  dynamic visitLiteralTerm(CssLiteralTerm node) {}

  @override
  dynamic visitHexColorTerm(CssHexColorTerm node) {}

  @override
  dynamic visitNumberTerm(CssNumberTerm node) {}

  @override
  dynamic visitUnitTerm(CssUnitTerm node) {}

  @override
  dynamic visitLengthTerm(CssLengthTerm node) {
    visitUnitTerm(node);
  }

  @override
  dynamic visitPercentageTerm(CssPercentageTerm node) {
    visitLiteralTerm(node);
  }

  @override
  dynamic visitEmTerm(CssEmTerm node) {
    visitLiteralTerm(node);
  }

  @override
  dynamic visitExTerm(CssExTerm node) {
    visitLiteralTerm(node);
  }

  @override
  dynamic visitAngleTerm(CssAngleTerm node) {
    visitUnitTerm(node);
  }

  @override
  dynamic visitTimeTerm(CssTimeTerm node) {
    visitUnitTerm(node);
  }

  @override
  dynamic visitFreqTerm(CssFreqTerm node) {
    visitUnitTerm(node);
  }

  @override
  dynamic visitFractionTerm(CssFractionTerm node) {
    visitLiteralTerm(node);
  }

  @override
  dynamic visitUriTerm(CssUriTerm node) {
    visitLiteralTerm(node);
  }

  @override
  dynamic visitResolutionTerm(CssResolutionTerm node) {
    visitUnitTerm(node);
  }

  @override
  dynamic visitChTerm(CssChTerm node) {
    visitUnitTerm(node);
  }

  @override
  dynamic visitRemTerm(CssRemTerm node) {
    visitUnitTerm(node);
  }

  @override
  dynamic visitViewportTerm(CssViewportTerm node) {
    visitUnitTerm(node);
  }

  @override
  dynamic visitFunctionTerm(CssFunctionTerm node) {
    visitLiteralTerm(node);
    visitExpressions(node._params);
  }

  @override
  dynamic visitGroupTerm(CssGroupTerm node) {
    for (CssLiteralTerm term in node._terms) {
      term.visit(this);
    }
  }

  @override
  dynamic visitItemTerm(CssItemTerm node) {
    visitNumberTerm(node);
  }

  @override
  dynamic visitIE8Term(CssIE8Term node) {}

  @override
  dynamic visitOperatorSlash(CssOperatorSlash node) {}

  @override
  dynamic visitOperatorComma(CssOperatorComma node) {}

  @override
  dynamic visitOperatorPlus(CssOperatorPlus node) {}

  @override
  dynamic visitOperatorMinus(CssOperatorMinus node) {}

  @override
  dynamic visitVarUsage(CssVarUsage node) {
    _visitNodeList(node.defaultValues);
  }

  @override
  dynamic visitExpressions(CssExpressions node) {
    _visitNodeList(node.expressions);
  }

  @override
  dynamic visitBinaryExpression(CssBinaryExpression node) {
    throw UnimplementedError();
  }

  @override
  dynamic visitUnaryExpression(UnaryExpression node) {
    throw UnimplementedError();
  }

  @override
  dynamic visitIdentifier(CssIdentifier node) {}

  @override
  dynamic visitWildcard(CssWildcard node) {}

  @override
  dynamic visitThisOperator(CssThisOperator node) {}

  @override
  dynamic visitNegation(CssNegation node) {}

  @override
  dynamic visitDartStyleExpression(CssDartStyleExpression node) {}

  @override
  dynamic visitFontExpression(CssFontExpression node) {
    throw UnimplementedError();
  }

  @override
  dynamic visitBoxExpression(CssBoxExpression node) {
    throw UnimplementedError();
  }

  @override
  dynamic visitMarginExpression(CssMarginExpression node) {
    throw UnimplementedError();
  }

  @override
  dynamic visitBorderExpression(CssBorderExpression node) {
    throw UnimplementedError();
  }

  @override
  dynamic visitHeightExpression(CssHeightExpression node) {
    throw UnimplementedError();
  }

  @override
  dynamic visitPaddingExpression(CssPaddingExpression node) {
    throw UnimplementedError();
  }

  @override
  dynamic visitWidthExpression(CssWidthExpression node) {
    throw UnimplementedError();
  }
}
