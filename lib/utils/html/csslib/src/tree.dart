// ignore_for_file: prefer_initializing_formals
part of '../visitor.dart';

class CssIdentifier extends CssTreeNode {
  String name;

  CssIdentifier(this.name, SourceSpan? span) : super(span);

  @override
  CssIdentifier clone() => CssIdentifier(name, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitIdentifier(this);

  @override
  String toString() {
    return span?.text ?? name;
  }
}

class CssWildcard extends CssTreeNode {
  CssWildcard(SourceSpan? span) : super(span);
  @override
  CssWildcard clone() => CssWildcard(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitWildcard(this);

  String get name => '*';
}

class CssThisOperator extends CssTreeNode {
  CssThisOperator(SourceSpan? span) : super(span);
  @override
  CssThisOperator clone() => CssThisOperator(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitThisOperator(this);

  String get name => '&';
}

class CssNegation extends CssTreeNode {
  CssNegation(SourceSpan? span) : super(span);
  @override
  CssNegation clone() => CssNegation(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNegation(this);

  String get name => 'not';
}

class CssCalcTerm extends CssLiteralTerm {
  final CssLiteralTerm expr;

  CssCalcTerm(dynamic value, String t, this.expr, SourceSpan? span)
      : super(value, t, span);

  @override
  CssCalcTerm clone() => CssCalcTerm(value, text, expr.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitCalcTerm(this);

  @override
  String toString() => '$text($expr)';
}

class CssComment extends CssTreeNode {
  final String comment;

  CssComment(this.comment, SourceSpan? span) : super(span);
  @override
  CssComment clone() => CssComment(comment, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitCssComment(this);
}

class CssCommentDefinition extends CssComment {
  CssCommentDefinition(String comment, SourceSpan? span) : super(comment, span);
  @override
  CssCommentDefinition clone() => CssCommentDefinition(comment, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitCommentDefinition(this);
}

class CssSelectorGroup extends CssTreeNode {
  final List<CssSelector> selectors;

  CssSelectorGroup(this.selectors, SourceSpan? span) : super(span);

  @override
  CssSelectorGroup clone() => CssSelectorGroup(selectors, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSelectorGroup(this);
}

class CssSelector extends CssTreeNode {
  final List<CssSimpleSelectorSequence> simpleSelectorSequences;

  CssSelector(this.simpleSelectorSequences, SourceSpan? span) : super(span);

  void add(CssSimpleSelectorSequence seq) => simpleSelectorSequences.add(seq);

  int get length => simpleSelectorSequences.length;

  @override
  CssSelector clone() {
    List<CssSimpleSelectorSequence> simpleSequences =
        simpleSelectorSequences.map((ss) => ss.clone()).toList();

    return CssSelector(simpleSequences, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSelector(this);
}

class CssSimpleSelectorSequence extends CssTreeNode {
  int combinator;
  final CssSimpleSelector simpleSelector;

  CssSimpleSelectorSequence(this.simpleSelector, SourceSpan? span,
      [int combinator = CssTokenKind.COMBINATOR_NONE])
      : combinator = combinator,
        super(span);

  bool get isCombinatorNone => combinator == CssTokenKind.COMBINATOR_NONE;
  bool get isCombinatorPlus => combinator == CssTokenKind.COMBINATOR_PLUS;
  bool get isCombinatorGreater => combinator == CssTokenKind.COMBINATOR_GREATER;
  bool get isCombinatorTilde => combinator == CssTokenKind.COMBINATOR_TILDE;
  bool get isCombinatorDescendant =>
      combinator == CssTokenKind.COMBINATOR_DESCENDANT;

  String get _combinatorToString {
    switch (combinator) {
      case CssTokenKind.COMBINATOR_DESCENDANT:
        return ' ';
      case CssTokenKind.COMBINATOR_GREATER:
        return ' > ';
      case CssTokenKind.COMBINATOR_PLUS:
        return ' + ';
      case CssTokenKind.COMBINATOR_TILDE:
        return ' ~ ';
      default:
        return '';
    }
  }

  @override
  CssSimpleSelectorSequence clone() =>
      CssSimpleSelectorSequence(simpleSelector, span, combinator);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitSimpleSelectorSequence(this);

  @override
  String toString() => simpleSelector.name;
}

abstract class CssSimpleSelector extends CssTreeNode {
  final dynamic _name;

  CssSimpleSelector(this._name, SourceSpan? span) : super(span);

  String get name => _name.name as String;

  bool get isWildcard => _name is CssWildcard;

  bool get isThis => _name is CssThisOperator;

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSimpleSelector(this);
}

class ElementSelector extends CssSimpleSelector {
  ElementSelector(name, SourceSpan? span) : super(name, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitElementSelector(this);

  @override
  ElementSelector clone() => ElementSelector(_name, span);

  @override
  String toString() => name;
}

class NamespaceSelector extends CssSimpleSelector {
  final dynamic _namespace;

  NamespaceSelector(this._namespace, dynamic name, SourceSpan? span)
      : super(name, span);

  String get namespace => _namespace is CssWildcard
      ? '*'
      : _namespace == null
          ? ''
          : (_namespace as CssIdentifier).name;

  bool get isNamespaceWildcard => _namespace is CssWildcard;

  CssSimpleSelector? get nameAsSimpleSelector => _name as CssSimpleSelector?;

  @override
  NamespaceSelector clone() => NamespaceSelector(_namespace, '', span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNamespaceSelector(this);

  @override
  String toString() => '$namespace|${nameAsSimpleSelector!.name}';
}

class CssAttributeSelector extends CssSimpleSelector {
  final int _op;
  final dynamic value;

  CssAttributeSelector(
      CssIdentifier name, this._op, this.value, SourceSpan? span)
      : super(name, span);

  int get operatorKind => _op;

  String? matchOperator() {
    switch (_op) {
      case CssTokenKind.EQUALS:
        return '=';
      case CssTokenKind.INCLUDES:
        return '~=';
      case CssTokenKind.DASH_MATCH:
        return '|=';
      case CssTokenKind.PREFIX_MATCH:
        return '^=';
      case CssTokenKind.SUFFIX_MATCH:
        return '\$=';
      case CssTokenKind.SUBSTRING_MATCH:
        return '*=';
      case CssTokenKind.NO_MATCH:
        return '';
    }
    return null;
  }

  String? matchOperatorAsTokenString() {
    switch (_op) {
      case CssTokenKind.EQUALS:
        return 'EQUALS';
      case CssTokenKind.INCLUDES:
        return 'INCLUDES';
      case CssTokenKind.DASH_MATCH:
        return 'DASH_MATCH';
      case CssTokenKind.PREFIX_MATCH:
        return 'PREFIX_MATCH';
      case CssTokenKind.SUFFIX_MATCH:
        return 'SUFFIX_MATCH';
      case CssTokenKind.SUBSTRING_MATCH:
        return 'SUBSTRING_MATCH';
    }
    return null;
  }

  String valueToString() {
    if (value != null) {
      if (value is CssIdentifier) {
        return value.toString();
      } else {
        return '"$value"';
      }
    } else {
      return '';
    }
  }

  @override
  CssAttributeSelector clone() =>
      CssAttributeSelector(_name as CssIdentifier, _op, value, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitAttributeSelector(this);

  @override
  String toString() => '[$name${matchOperator()}${valueToString()}]';
}

class CssIdSelector extends CssSimpleSelector {
  CssIdSelector(CssIdentifier name, SourceSpan? span) : super(name, span);
  @override
  CssIdSelector clone() => CssIdSelector(_name as CssIdentifier, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitIdSelector(this);

  @override
  String toString() => '#$_name';
}

class CssClassSelector extends CssSimpleSelector {
  CssClassSelector(CssIdentifier name, SourceSpan? span) : super(name, span);
  @override
  CssClassSelector clone() => CssClassSelector(_name as CssIdentifier, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitClassSelector(this);

  @override
  String toString() => '.$_name';
}

class CssPseudoClassSelector extends CssSimpleSelector {
  CssPseudoClassSelector(CssIdentifier name, SourceSpan? span)
      : super(name, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitPseudoClassSelector(this);

  @override
  CssPseudoClassSelector clone() =>
      CssPseudoClassSelector(_name as CssIdentifier, span);

  @override
  String toString() => ':$name';
}

class CssPseudoElementSelector extends CssSimpleSelector {
  final bool isLegacy;

  CssPseudoElementSelector(CssIdentifier name, SourceSpan? span,
      {this.isLegacy = false})
      : super(name, span);
  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitPseudoElementSelector(this);

  @override
  CssPseudoElementSelector clone() =>
      CssPseudoElementSelector(_name as CssIdentifier, span);

  @override
  String toString() => "${isLegacy ? ':' : '::'}$name";
}

class PseudoClassFunctionSelector extends CssPseudoClassSelector {
  final CssTreeNode argument;

  PseudoClassFunctionSelector(
      CssIdentifier name, this.argument, SourceSpan? span)
      : super(name, span);

  @override
  PseudoClassFunctionSelector clone() =>
      PseudoClassFunctionSelector(_name as CssIdentifier, argument, span);

  CssSelector get selector => argument as CssSelector;
  CssSelectorExpression get expression => argument as CssSelectorExpression;

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitPseudoClassFunctionSelector(this);
}

class CssPseudoElementFunctionSelector extends CssPseudoElementSelector {
  final CssSelectorExpression expression;

  CssPseudoElementFunctionSelector(
      CssIdentifier name, this.expression, SourceSpan? span)
      : super(name, span);

  @override
  CssPseudoElementFunctionSelector clone() => CssPseudoElementFunctionSelector(
      _name as CssIdentifier, expression, span);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitPseudoElementFunctionSelector(this);
}

class CssSelectorExpression extends CssTreeNode {
  final List<CssExpression> expressions;

  CssSelectorExpression(this.expressions, SourceSpan? span) : super(span);

  @override
  SourceSpan get span => super.span!;

  @override
  CssSelectorExpression clone() {
    return CssSelectorExpression(
        expressions.map((e) => e.clone()).toList(), span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSelectorExpression(this);
}

class CssNegationSelector extends CssSimpleSelector {
  final CssSimpleSelector? negationArg;

  CssNegationSelector(this.negationArg, SourceSpan? span)
      : super(CssNegation(span), span);

  @override
  CssNegationSelector clone() => CssNegationSelector(negationArg, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNegationSelector(this);
}

class CssNoOp extends CssTreeNode {
  CssNoOp() : super(null);

  @override
  CssNoOp clone() => CssNoOp();

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNoOp(this);
}

class CssStyleSheet extends CssTreeNode {
  final List<CssTreeNode> topLevels;

  CssStyleSheet(this.topLevels, SourceSpan? span) : super(span) {
    for (final node in topLevels) {
      assert(node is CssTopLevelProduction || node is Directive);
    }
  }

  CssStyleSheet.selector(this.topLevels, SourceSpan? span) : super(span);

  @override
  SourceSpan get span => super.span!;

  @override
  CssStyleSheet clone() {
    List<CssTreeNode> clonedTopLevels =
        topLevels.map((e) => e.clone()).toList();
    return CssStyleSheet(clonedTopLevels, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitStyleSheet(this);
}

class CssTopLevelProduction extends CssTreeNode {
  CssTopLevelProduction(SourceSpan? span) : super(span);
  @override
  SourceSpan get span => super.span!;
  @override
  CssTopLevelProduction clone() => CssTopLevelProduction(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitTopLevelProduction(this);
}

class CssRuleSet extends CssTopLevelProduction {
  final CssSelectorGroup? selectorGroup;
  final DeclarationGroup declarationGroup;

  CssRuleSet(this.selectorGroup, this.declarationGroup, SourceSpan? span)
      : super(span);

  @override
  CssRuleSet clone() {
    CssSelectorGroup cloneSelectorGroup = selectorGroup!.clone();
    DeclarationGroup cloneDeclarationGroup = declarationGroup.clone();
    return CssRuleSet(cloneSelectorGroup, cloneDeclarationGroup, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitRuleSet(this);
}

class Directive extends CssTreeNode {
  Directive(SourceSpan? span) : super(span);

  bool get isBuiltIn => true;
  bool get isExtension => false;

  @override
  SourceSpan get span => super.span!;

  @override
  Directive clone() => Directive(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitDirective(this);
}

class CssDocumentDirective extends Directive {
  final List<CssLiteralTerm> functions;
  final List<CssTreeNode> groupRuleBody;

  CssDocumentDirective(this.functions, this.groupRuleBody, SourceSpan? span)
      : super(span);

  @override
  CssDocumentDirective clone() {
    List<CssLiteralTerm> clonedFunctions = <CssLiteralTerm>[];
    for (CssLiteralTerm function in functions) {
      clonedFunctions.add(function.clone());
    }
    List<CssTreeNode> clonedGroupRuleBody = <CssTreeNode>[];
    for (CssTreeNode rule in groupRuleBody) {
      clonedGroupRuleBody.add(rule.clone());
    }
    return CssDocumentDirective(clonedFunctions, clonedGroupRuleBody, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitDocumentDirective(this);
}

class CssSupportsDirective extends Directive {
  final SupportsCondition? condition;
  final List<CssTreeNode> groupRuleBody;

  CssSupportsDirective(this.condition, this.groupRuleBody, SourceSpan? span)
      : super(span);

  @override
  CssSupportsDirective clone() {
    SupportsCondition clonedCondition = condition!.clone() as SupportsCondition;
    List<CssTreeNode> clonedGroupRuleBody = <CssTreeNode>[];
    for (CssTreeNode rule in groupRuleBody) {
      clonedGroupRuleBody.add(rule.clone());
    }
    return CssSupportsDirective(clonedCondition, clonedGroupRuleBody, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSupportsDirective(this);
}

abstract class SupportsCondition extends CssTreeNode {
  SupportsCondition(SourceSpan? span) : super(span);
  @override
  SourceSpan get span => super.span!;
}

class CssSupportsConditionInParens extends SupportsCondition {
  final CssTreeNode? condition;

  CssSupportsConditionInParens(CssDeclaration? declaration, SourceSpan? span)
      : condition = declaration,
        super(span);

  CssSupportsConditionInParens.nested(
      SupportsCondition condition, SourceSpan? span)
      : condition = condition,
        super(span);

  @override
  CssSupportsConditionInParens clone() =>
      CssSupportsConditionInParens(condition!.clone() as CssDeclaration, span);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitSupportsConditionInParens(this);
}

class SupportsNegation extends SupportsCondition {
  final CssSupportsConditionInParens condition;

  SupportsNegation(this.condition, SourceSpan? span) : super(span);

  @override
  SupportsNegation clone() => SupportsNegation(condition.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSupportsNegation(this);
}

class SupportsConjunction extends SupportsCondition {
  final List<CssSupportsConditionInParens> conditions;

  SupportsConjunction(this.conditions, SourceSpan? span) : super(span);

  @override
  SupportsConjunction clone() {
    List<CssSupportsConditionInParens> clonedConditions =
        <CssSupportsConditionInParens>[];
    for (CssSupportsConditionInParens condition in conditions) {
      clonedConditions.add(condition.clone());
    }
    return SupportsConjunction(clonedConditions, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSupportsConjunction(this);
}

class CssSupportsDisjunction extends SupportsCondition {
  final List<CssSupportsConditionInParens> conditions;

  CssSupportsDisjunction(this.conditions, SourceSpan? span) : super(span);

  @override
  CssSupportsDisjunction clone() {
    List<CssSupportsConditionInParens> clonedConditions =
        <CssSupportsConditionInParens>[];
    for (CssSupportsConditionInParens condition in conditions) {
      clonedConditions.add(condition.clone());
    }
    return CssSupportsDisjunction(clonedConditions, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSupportsDisjunction(this);
}

class CssViewportDirective extends Directive {
  final String name;
  final DeclarationGroup declarations;

  CssViewportDirective(this.name, this.declarations, SourceSpan? span)
      : super(span);

  @override
  CssViewportDirective clone() =>
      CssViewportDirective(name, declarations.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitViewportDirective(this);
}

class CssImportDirective extends Directive {
  final String import;

  final List<MediaQuery> mediaQueries;

  CssImportDirective(this.import, this.mediaQueries, SourceSpan? span)
      : super(span);

  @override
  CssImportDirective clone() {
    List<MediaQuery> cloneMediaQueries = <MediaQuery>[];
    for (MediaQuery mediaQuery in mediaQueries) {
      cloneMediaQueries.add(mediaQuery.clone());
    }
    return CssImportDirective(import, cloneMediaQueries, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitImportDirective(this);
}

class CssMediaExpression extends CssTreeNode {
  final bool andOperator;
  final CssIdentifier _mediaFeature;
  final CssExpressions exprs;

  CssMediaExpression(
      this.andOperator, this._mediaFeature, this.exprs, SourceSpan? span)
      : super(span);

  String get mediaFeature => _mediaFeature.name;

  @override
  SourceSpan get span => super.span!;

  @override
  CssMediaExpression clone() {
    CssExpressions clonedExprs = exprs.clone();
    return CssMediaExpression(andOperator, _mediaFeature, clonedExprs, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMediaExpression(this);
}

class MediaQuery extends CssTreeNode {
  final int _mediaUnary;
  final CssIdentifier? _mediaType;
  final List<CssMediaExpression> expressions;

  MediaQuery(
      this._mediaUnary, this._mediaType, this.expressions, SourceSpan? span)
      : super(span);

  bool get hasMediaType => _mediaType != null;
  String get mediaType => _mediaType!.name;

  bool get hasUnary => _mediaUnary != -1;
  String get unary =>
      CssTokenKind.idToValue(CssTokenKind.MEDIA_OPERATORS, _mediaUnary)!
          .toUpperCase();

  @override
  SourceSpan get span => super.span!;

  @override
  MediaQuery clone() {
    List<CssMediaExpression> cloneExpressions = <CssMediaExpression>[];
    for (CssMediaExpression expr in expressions) {
      cloneExpressions.add(expr.clone());
    }
    return MediaQuery(_mediaUnary, _mediaType, cloneExpressions, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMediaQuery(this);
}

class CssMediaDirective extends Directive {
  final List<MediaQuery> mediaQueries;
  final List<CssTreeNode> rules;

  CssMediaDirective(this.mediaQueries, this.rules, SourceSpan? span)
      : super(span);

  @override
  CssMediaDirective clone() {
    List<MediaQuery> cloneQueries = <MediaQuery>[];
    for (MediaQuery mediaQuery in mediaQueries) {
      cloneQueries.add(mediaQuery.clone());
    }
    List<CssTreeNode> cloneRules = <CssTreeNode>[];
    for (CssTreeNode rule in rules) {
      cloneRules.add(rule.clone());
    }
    return CssMediaDirective(cloneQueries, cloneRules, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMediaDirective(this);
}

class CssHostDirective extends Directive {
  final List<CssTreeNode> rules;

  CssHostDirective(this.rules, SourceSpan? span) : super(span);

  @override
  CssHostDirective clone() {
    List<CssTreeNode> cloneRules = <CssTreeNode>[];
    for (CssTreeNode rule in rules) {
      cloneRules.add(rule.clone());
    }
    return CssHostDirective(cloneRules, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitHostDirective(this);
}

class CssPageDirective extends Directive {
  final String? _ident;
  final String? _pseudoPage;
  final List<DeclarationGroup> _declsMargin;

  CssPageDirective(
      this._ident, this._pseudoPage, this._declsMargin, SourceSpan? span)
      : super(span);

  @override
  CssPageDirective clone() {
    List<DeclarationGroup> cloneDeclsMargin = <DeclarationGroup>[];
    for (DeclarationGroup declMargin in _declsMargin) {
      cloneDeclsMargin.add(declMargin.clone());
    }
    return CssPageDirective(_ident, _pseudoPage, cloneDeclsMargin, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitPageDirective(this);

  bool get hasIdent => _ident?.isNotEmpty ?? false;
  bool get hasPseudoPage => _pseudoPage?.isNotEmpty ?? false;
}

class CssCharsetDirective extends Directive {
  final String charEncoding;

  CssCharsetDirective(this.charEncoding, SourceSpan? span) : super(span);
  @override
  CssCharsetDirective clone() => CssCharsetDirective(charEncoding, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitCharsetDirective(this);
}

class CssKeyFrameDirective extends Directive {
  final int _keyframeName;
  final CssIdentifier? name;
  final List<CssKeyFrameBlock> _blocks;

  CssKeyFrameDirective(this._keyframeName, this.name, SourceSpan? span)
      : _blocks = [],
        super(span);

  void add(CssKeyFrameBlock block) {
    _blocks.add(block);
  }

  String? get keyFrameName {
    switch (_keyframeName) {
      case CssTokenKind.DIRECTIVE_KEYFRAMES:
      case CssTokenKind.DIRECTIVE_MS_KEYFRAMES:
        return '@keyframes';
      case CssTokenKind.DIRECTIVE_WEB_KIT_KEYFRAMES:
        return '@-webkit-keyframes';
      case CssTokenKind.DIRECTIVE_MOZ_KEYFRAMES:
        return '@-moz-keyframes';
      case CssTokenKind.DIRECTIVE_O_KEYFRAMES:
        return '@-o-keyframes';
    }
    return null;
  }

  @override
  CssKeyFrameDirective clone() {
    CssKeyFrameDirective directive =
        CssKeyFrameDirective(_keyframeName, name!.clone(), span);
    for (CssKeyFrameBlock block in _blocks) {
      directive.add(block.clone());
    }
    return directive;
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitKeyFrameDirective(this);
}

class CssKeyFrameBlock extends CssExpression {
  final CssExpressions _blockSelectors;
  final DeclarationGroup _declarations;

  CssKeyFrameBlock(this._blockSelectors, this._declarations, SourceSpan? span)
      : super(span);

  @override
  CssKeyFrameBlock clone() =>
      CssKeyFrameBlock(_blockSelectors.clone(), _declarations.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitKeyFrameBlock(this);
}

class FontFaceDirective extends Directive {
  final DeclarationGroup _declarations;

  FontFaceDirective(this._declarations, SourceSpan? span) : super(span);

  @override
  FontFaceDirective clone() => FontFaceDirective(_declarations.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitFontFaceDirective(this);
}

class StyletDirective extends Directive {
  final String dartClassName;
  final List<CssTreeNode> rules;

  StyletDirective(this.dartClassName, this.rules, SourceSpan? span)
      : super(span);

  @override
  bool get isBuiltIn => false;
  @override
  bool get isExtension => true;

  @override
  StyletDirective clone() {
    List<CssTreeNode> cloneRules = <CssTreeNode>[];
    for (CssTreeNode rule in rules) {
      cloneRules.add(rule.clone());
    }
    return StyletDirective(dartClassName, cloneRules, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitStyletDirective(this);
}

class CssNamespaceDirective extends Directive {
  final String _prefix;

  final String? _uri;

  CssNamespaceDirective(this._prefix, this._uri, SourceSpan? span)
      : super(span);

  @override
  CssNamespaceDirective clone() => CssNamespaceDirective(_prefix, _uri, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNamespaceDirective(this);

  String get prefix => _prefix.isNotEmpty ? '$_prefix ' : '';
}

class CssVarDefinitionDirective extends Directive {
  final VarDefinition def;

  CssVarDefinitionDirective(this.def, SourceSpan? span) : super(span);

  @override
  CssVarDefinitionDirective clone() =>
      CssVarDefinitionDirective(def.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitVarDefinitionDirective(this);
}

class CssMixinDefinition extends Directive {
  final String name;
  final List<CssTreeNode> definedArgs;
  final bool varArgs;

  CssMixinDefinition(
      this.name, this.definedArgs, this.varArgs, SourceSpan? span)
      : super(span);

  @override
  CssMixinDefinition clone() {
    List<CssTreeNode> cloneDefinedArgs = <CssTreeNode>[];
    for (CssTreeNode definedArg in definedArgs) {
      cloneDefinedArgs.add(definedArg.clone());
    }
    return CssMixinDefinition(name, cloneDefinedArgs, varArgs, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMixinDefinition(this);
}

class CssMixinRulesetDirective extends CssMixinDefinition {
  final List<CssTreeNode> rulesets;

  CssMixinRulesetDirective(String name, List<CssTreeNode> args, bool varArgs,
      this.rulesets, SourceSpan? span)
      : super(name, args, varArgs, span);

  @override
  CssMixinRulesetDirective clone() {
    List<VarDefinition> clonedArgs = <VarDefinition>[];
    for (CssTreeNode arg in definedArgs) {
      clonedArgs.add(arg.clone() as VarDefinition);
    }
    List<CssTreeNode> clonedRulesets = <CssTreeNode>[];
    for (CssTreeNode ruleset in rulesets) {
      clonedRulesets.add(ruleset.clone());
    }
    return CssMixinRulesetDirective(
        name, clonedArgs, varArgs, clonedRulesets, span);
  }

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitMixinRulesetDirective(this);
}

class CssMixinDeclarationDirective extends CssMixinDefinition {
  final DeclarationGroup declarations;

  CssMixinDeclarationDirective(String name, List<CssTreeNode> args,
      bool varArgs, this.declarations, SourceSpan? span)
      : super(name, args, varArgs, span);

  @override
  CssMixinDeclarationDirective clone() {
    List<CssTreeNode> clonedArgs = <CssTreeNode>[];
    for (CssTreeNode arg in definedArgs) {
      clonedArgs.add(arg.clone());
    }
    return CssMixinDeclarationDirective(
        name, clonedArgs, varArgs, declarations.clone(), span);
  }

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitMixinDeclarationDirective(this);
}

class IncludeDirective extends Directive {
  final String name;
  final List<List<CssExpression>> args;

  IncludeDirective(this.name, this.args, SourceSpan? span) : super(span);

  @override
  IncludeDirective clone() {
    List<List<CssExpression>> cloneArgs = <List<CssExpression>>[];
    for (List<CssExpression> arg in args) {
      cloneArgs.add(arg.map((term) => term.clone()).toList());
    }
    return IncludeDirective(name, cloneArgs, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitIncludeDirective(this);
}

class CssContentDirective extends Directive {
  CssContentDirective(SourceSpan? span) : super(span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitContentDirective(this);
}

class CssDeclaration extends CssTreeNode {
  final CssIdentifier? _property;
  final CssExpression? expression;

  CssDartStyleExpression? dartStyle;
  final bool important;

  final bool isIE7;

  CssDeclaration(
      this._property, this.expression, this.dartStyle, SourceSpan? span,
      {this.important = false, bool ie7 = false})
      : isIE7 = ie7,
        super(span);

  String get property => isIE7 ? '*${_property!.name}' : _property!.name;

  bool get hasDartStyle => dartStyle != null;

  @override
  SourceSpan get span => super.span!;

  @override
  CssDeclaration clone() =>
      CssDeclaration(_property!.clone(), expression!.clone(), dartStyle, span,
          important: important);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitDeclaration(this);
}

class VarDefinition extends CssDeclaration {
  bool badUsage = false;

  VarDefinition(
      CssIdentifier? definedName, CssExpression? expr, SourceSpan? span)
      : super(definedName, expr, null, span);

  String get definedName => _property!.name;

  @override
  VarDefinition clone() =>
      VarDefinition(_property!.clone(), expression?.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitVarDefinition(this);
}

class CssIncludeMixinAtDeclaration extends CssDeclaration {
  final IncludeDirective include;

  CssIncludeMixinAtDeclaration(this.include, SourceSpan? span)
      : super(null, null, null, span);

  @override
  CssIncludeMixinAtDeclaration clone() =>
      CssIncludeMixinAtDeclaration(include.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitIncludeMixinAtDeclaration(this);
}

class CssExtendDeclaration extends CssDeclaration {
  final List<CssTreeNode> selectors;

  CssExtendDeclaration(this.selectors, SourceSpan? span)
      : super(null, null, null, span);

  @override
  CssExtendDeclaration clone() {
    List<CssTreeNode> newSelector = selectors.map((s) => s.clone()).toList();
    return CssExtendDeclaration(newSelector, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitExtendDeclaration(this);
}

class DeclarationGroup extends CssTreeNode {
  final List<CssTreeNode> declarations;

  DeclarationGroup(this.declarations, SourceSpan? span) : super(span);

  @override
  SourceSpan get span => super.span!;

  @override
  DeclarationGroup clone() {
    List<CssTreeNode> clonedDecls = declarations.map((d) => d.clone()).toList();
    return DeclarationGroup(clonedDecls, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitDeclarationGroup(this);
}

class CssMarginGroup extends DeclarationGroup {
  final int marginSym;

  CssMarginGroup(this.marginSym, List<CssTreeNode> decls, SourceSpan? span)
      : super(decls, span);
  @override
  CssMarginGroup clone() =>
      CssMarginGroup(marginSym, super.clone().declarations, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMarginGroup(this);
}

class CssVarUsage extends CssExpression {
  final String name;
  final List<CssExpression> defaultValues;

  CssVarUsage(this.name, this.defaultValues, SourceSpan? span) : super(span);

  @override
  CssVarUsage clone() {
    List<CssExpression> clonedValues = <CssExpression>[];
    for (CssExpression expr in defaultValues) {
      clonedValues.add(expr.clone());
    }
    return CssVarUsage(name, clonedValues, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitVarUsage(this);
}

class CssOperatorSlash extends CssExpression {
  CssOperatorSlash(SourceSpan? span) : super(span);
  @override
  CssOperatorSlash clone() => CssOperatorSlash(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitOperatorSlash(this);
}

class CssOperatorComma extends CssExpression {
  CssOperatorComma(SourceSpan? span) : super(span);
  @override
  CssOperatorComma clone() => CssOperatorComma(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitOperatorComma(this);
}

class CssOperatorPlus extends CssExpression {
  CssOperatorPlus(SourceSpan? span) : super(span);
  @override
  CssOperatorPlus clone() => CssOperatorPlus(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitOperatorPlus(this);
}

class CssOperatorMinus extends CssExpression {
  CssOperatorMinus(SourceSpan? span) : super(span);
  @override
  CssOperatorMinus clone() => CssOperatorMinus(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitOperatorMinus(this);
}

class CssUnicodeRangeTerm extends CssExpression {
  final String? first;
  final String? second;

  CssUnicodeRangeTerm(this.first, this.second, SourceSpan? span) : super(span);

  bool get hasSecond => second != null;

  @override
  CssUnicodeRangeTerm clone() => CssUnicodeRangeTerm(first, second, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitUnicodeRangeTerm(this);
}

class CssLiteralTerm extends CssExpression {
  dynamic value;
  String text;

  CssLiteralTerm(this.value, this.text, SourceSpan? span) : super(span);

  @override
  CssLiteralTerm clone() => CssLiteralTerm(value, text, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitLiteralTerm(this);
}

class CssNumberTerm extends CssLiteralTerm {
  CssNumberTerm(value, String t, SourceSpan? span) : super(value, t, span);
  @override
  CssNumberTerm clone() => CssNumberTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNumberTerm(this);
}

class CssUnitTerm extends CssLiteralTerm {
  final int unit;

  CssUnitTerm(value, String t, SourceSpan? span, this.unit)
      : super(value, t, span);

  @override
  CssUnitTerm clone() => CssUnitTerm(value, text, span, unit);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitUnitTerm(this);

  String? unitToString() => CssTokenKind.unitToString(unit);

  @override
  String toString() => '$text${unitToString()}';
}

class CssLengthTerm extends CssUnitTerm {
  CssLengthTerm(value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(this.unit == CssTokenKind.UNIT_LENGTH_PX ||
        this.unit == CssTokenKind.UNIT_LENGTH_CM ||
        this.unit == CssTokenKind.UNIT_LENGTH_MM ||
        this.unit == CssTokenKind.UNIT_LENGTH_IN ||
        this.unit == CssTokenKind.UNIT_LENGTH_PT ||
        this.unit == CssTokenKind.UNIT_LENGTH_PC);
  }
  @override
  CssLengthTerm clone() => CssLengthTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitLengthTerm(this);
}

class CssPercentageTerm extends CssLiteralTerm {
  CssPercentageTerm(value, String t, SourceSpan? span) : super(value, t, span);
  @override
  CssPercentageTerm clone() => CssPercentageTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitPercentageTerm(this);
}

class CssEmTerm extends CssLiteralTerm {
  CssEmTerm(value, String t, SourceSpan? span) : super(value, t, span);
  @override
  CssEmTerm clone() => CssEmTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitEmTerm(this);
}

class CssExTerm extends CssLiteralTerm {
  CssExTerm(value, String t, SourceSpan? span) : super(value, t, span);
  @override
  CssExTerm clone() => CssExTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitExTerm(this);
}

class CssAngleTerm extends CssUnitTerm {
  CssAngleTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(this.unit == CssTokenKind.UNIT_ANGLE_DEG ||
        this.unit == CssTokenKind.UNIT_ANGLE_RAD ||
        this.unit == CssTokenKind.UNIT_ANGLE_GRAD ||
        this.unit == CssTokenKind.UNIT_ANGLE_TURN);
  }

  @override
  CssAngleTerm clone() => CssAngleTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitAngleTerm(this);
}

class CssTimeTerm extends CssUnitTerm {
  CssTimeTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(this.unit == CssTokenKind.UNIT_ANGLE_DEG ||
        this.unit == CssTokenKind.UNIT_TIME_MS ||
        this.unit == CssTokenKind.UNIT_TIME_S);
  }

  @override
  CssTimeTerm clone() => CssTimeTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitTimeTerm(this);
}

class CssFreqTerm extends CssUnitTerm {
  CssFreqTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_FREQ_HZ ||
        unit == CssTokenKind.UNIT_FREQ_KHZ);
  }

  @override
  CssFreqTerm clone() => CssFreqTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitFreqTerm(this);
}

class CssFractionTerm extends CssLiteralTerm {
  CssFractionTerm(dynamic value, String t, SourceSpan? span)
      : super(value, t, span);

  @override
  CssFractionTerm clone() => CssFractionTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitFractionTerm(this);
}

class CssUriTerm extends CssLiteralTerm {
  CssUriTerm(String value, SourceSpan? span) : super(value, value, span);

  @override
  CssUriTerm clone() => CssUriTerm(value as String, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitUriTerm(this);
}

class CssResolutionTerm extends CssUnitTerm {
  CssResolutionTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_RESOLUTION_DPI ||
        unit == CssTokenKind.UNIT_RESOLUTION_DPCM ||
        unit == CssTokenKind.UNIT_RESOLUTION_DPPX);
  }

  @override
  CssResolutionTerm clone() => CssResolutionTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitResolutionTerm(this);
}

class CssChTerm extends CssUnitTerm {
  CssChTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_CH);
  }

  @override
  CssChTerm clone() => CssChTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitChTerm(this);
}

class CssRemTerm extends CssUnitTerm {
  CssRemTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_REM);
  }

  @override
  CssRemTerm clone() => CssRemTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitRemTerm(this);
}

class CssViewportTerm extends CssUnitTerm {
  CssViewportTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_VIEWPORT_VW ||
        unit == CssTokenKind.UNIT_VIEWPORT_VH ||
        unit == CssTokenKind.UNIT_VIEWPORT_VMIN ||
        unit == CssTokenKind.UNIT_VIEWPORT_VMAX);
  }

  @override
  CssViewportTerm clone() => CssViewportTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitViewportTerm(this);
}

class BadHexValue {}

class CssHexColorTerm extends CssLiteralTerm {
  CssHexColorTerm(dynamic value, String t, SourceSpan? span)
      : super(value, t, span);

  @override
  CssHexColorTerm clone() => CssHexColorTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitHexColorTerm(this);
}

class CssFunctionTerm extends CssLiteralTerm {
  final CssExpressions _params;

  CssFunctionTerm(dynamic value, String t, this._params, SourceSpan? span)
      : super(value, t, span);

  @override
  CssFunctionTerm clone() =>
      CssFunctionTerm(value, text, _params.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitFunctionTerm(this);
}

class CssIE8Term extends CssLiteralTerm {
  CssIE8Term(SourceSpan? span) : super('\\9', '\\9', span);
  @override
  CssIE8Term clone() => CssIE8Term(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitIE8Term(this);
}

class CssGroupTerm extends CssExpression {
  final List<CssLiteralTerm> _terms;

  CssGroupTerm(SourceSpan? span)
      : _terms = [],
        super(span);

  void add(CssLiteralTerm term) {
    _terms.add(term);
  }

  @override
  CssGroupTerm clone() => CssGroupTerm(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitGroupTerm(this);
}

class CssItemTerm extends CssNumberTerm {
  CssItemTerm(dynamic value, String t, SourceSpan? span)
      : super(value, t, span);

  @override
  CssItemTerm clone() => CssItemTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitItemTerm(this);
}

class CssExpressions extends CssExpression {
  final List<CssExpression> expressions = [];

  CssExpressions(SourceSpan? span) : super(span);

  void add(CssExpression expression) {
    expressions.add(expression);
  }

  @override
  CssExpressions clone() {
    CssExpressions clonedExprs = CssExpressions(span);
    for (CssExpression expr in expressions) {
      clonedExprs.add(expr.clone());
    }
    return clonedExprs;
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitExpressions(this);
}

class CssBinaryExpression extends CssExpression {
  final CssToken op;
  final CssExpression x;
  final CssExpression y;

  CssBinaryExpression(this.op, this.x, this.y, SourceSpan? span) : super(span);

  @override
  CssBinaryExpression clone() =>
      CssBinaryExpression(op, x.clone(), y.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitBinaryExpression(this);
}

class UnaryExpression extends CssExpression {
  final CssToken op;
  final CssExpression self;

  UnaryExpression(this.op, this.self, SourceSpan? span) : super(span);

  @override
  UnaryExpression clone() => UnaryExpression(op, self.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitUnaryExpression(this);
}

abstract class CssDartStyleExpression extends CssTreeNode {
  static const int unknownType = 0;
  static const int fontStyle = 1;
  static const int marginStyle = 2;
  static const int borderStyle = 3;
  static const int paddingStyle = 4;
  static const int heightStyle = 5;
  static const int widthStyle = 6;

  final int? _styleType;
  int? priority;

  CssDartStyleExpression(this._styleType, SourceSpan? span) : super(span);

  CssDartStyleExpression? merged(CssDartStyleExpression newDartExpr);

  bool get isUnknown => _styleType == 0 || _styleType == null;
  bool get isFont => _styleType == fontStyle;
  bool get isMargin => _styleType == marginStyle;
  bool get isBorder => _styleType == borderStyle;
  bool get isPadding => _styleType == paddingStyle;
  bool get isHeight => _styleType == heightStyle;
  bool get isWidth => _styleType == widthStyle;
  bool get isBoxExpression => isMargin || isBorder || isPadding;

  bool isSame(CssDartStyleExpression other) => _styleType == other._styleType;

  @override
  SourceSpan get span => super.span!;

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitDartStyleExpression(this);
}

class CssFontExpression extends CssDartStyleExpression {
  final CssFont font;

  CssFontExpression(SourceSpan? span,
      {Object? /* LengthTerm | num */ size,
      List<String>? family,
      int? weight,
      String? style,
      String? variant,
      LineHeight? lineHeight})
      : font = CssFont(
            size: (size is CssLengthTerm ? size.value : size) as num?,
            family: family,
            weight: weight,
            style: style,
            variant: variant,
            lineHeight: lineHeight),
        super(CssDartStyleExpression.fontStyle, span);

  @override
  CssFontExpression? merged(CssDartStyleExpression newDartExpr) {
    if (newDartExpr is CssFontExpression && isFont && newDartExpr.isFont) {
      return CssFontExpression.merge(this, newDartExpr);
    }
    return null;
  }

  factory CssFontExpression.merge(CssFontExpression x, CssFontExpression y) {
    return CssFontExpression._merge(x, y, y.span);
  }

  CssFontExpression._merge(
      CssFontExpression x, CssFontExpression y, SourceSpan? span)
      : font = CssFont.merge(x.font, y.font)!,
        super(CssDartStyleExpression.fontStyle, span);

  @override
  CssFontExpression clone() => CssFontExpression(span,
      size: font.size,
      family: font.family,
      weight: font.weight,
      style: font.style,
      variant: font.variant,
      lineHeight: font.lineHeight);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitFontExpression(this);
}

abstract class CssBoxExpression extends CssDartStyleExpression {
  final CssBoxEdge? box;

  CssBoxExpression(int? styleType, SourceSpan? span, this.box)
      : super(styleType, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitBoxExpression(this);

  String get formattedBoxEdge {
    if (box!.top == box!.left &&
        box!.top == box!.bottom &&
        box!.top == box!.right) {
      return '.uniform(${box!.top})';
    } else {
      num left = box!.left ?? 0;
      num top = box!.top ?? 0;
      num right = box!.right ?? 0;
      num bottom = box!.bottom ?? 0;
      return '.clockwiseFromTop($top,$right,$bottom,$left)';
    }
  }
}

class CssMarginExpression extends CssBoxExpression {
  CssMarginExpression(SourceSpan? span,
      {num? top, num? right, num? bottom, num? left})
      : super(CssDartStyleExpression.marginStyle, span,
            CssBoxEdge(left, top, right, bottom));

  CssMarginExpression.boxEdge(SourceSpan? span, CssBoxEdge? box)
      : super(CssDartStyleExpression.marginStyle, span, box);

  @override
  CssMarginExpression? merged(CssDartStyleExpression newDartExpr) {
    if (newDartExpr is CssMarginExpression &&
        isMargin &&
        newDartExpr.isMargin) {
      return CssMarginExpression.merge(this, newDartExpr);
    }

    return null;
  }

  factory CssMarginExpression.merge(
      CssMarginExpression x, CssMarginExpression y) {
    return CssMarginExpression._merge(x, y, y.span);
  }

  CssMarginExpression._merge(
      CssMarginExpression x, CssMarginExpression y, SourceSpan? span)
      : super(x._styleType, span, CssBoxEdge.merge(x.box, y.box));

  @override
  CssMarginExpression clone() => CssMarginExpression(span,
      top: box!.top, right: box!.right, bottom: box!.bottom, left: box!.left);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMarginExpression(this);
}

class CssBorderExpression extends CssBoxExpression {
  CssBorderExpression(SourceSpan? span,
      {num? top, num? right, num? bottom, num? left})
      : super(CssDartStyleExpression.borderStyle, span,
            CssBoxEdge(left, top, right, bottom));

  CssBorderExpression.boxEdge(SourceSpan? span, CssBoxEdge box)
      : super(CssDartStyleExpression.borderStyle, span, box);

  @override
  CssBorderExpression? merged(CssDartStyleExpression newDartExpr) {
    if (newDartExpr is CssBorderExpression &&
        isBorder &&
        newDartExpr.isBorder) {
      return CssBorderExpression.merge(this, newDartExpr);
    }

    return null;
  }

  factory CssBorderExpression.merge(
      CssBorderExpression x, CssBorderExpression y) {
    return CssBorderExpression._merge(x, y, y.span);
  }

  CssBorderExpression._merge(
      CssBorderExpression x, CssBorderExpression y, SourceSpan? span)
      : super(CssDartStyleExpression.borderStyle, span,
            CssBoxEdge.merge(x.box, y.box));

  @override
  CssBorderExpression clone() => CssBorderExpression(span,
      top: box!.top, right: box!.right, bottom: box!.bottom, left: box!.left);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitBorderExpression(this);
}

class CssHeightExpression extends CssDartStyleExpression {
  final dynamic height;

  CssHeightExpression(SourceSpan? span, this.height)
      : super(CssDartStyleExpression.heightStyle, span);

  @override
  CssHeightExpression? merged(CssDartStyleExpression newDartExpr) {
    if (isHeight && newDartExpr.isHeight) {
      return newDartExpr as CssHeightExpression;
    }

    return null;
  }

  @override
  CssHeightExpression clone() => CssHeightExpression(span, height);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitHeightExpression(this);
}

class CssWidthExpression extends CssDartStyleExpression {
  final dynamic width;

  CssWidthExpression(SourceSpan? span, this.width)
      : super(CssDartStyleExpression.widthStyle, span);

  @override
  CssWidthExpression? merged(CssDartStyleExpression newDartExpr) {
    if (newDartExpr is CssWidthExpression && isWidth && newDartExpr.isWidth) {
      return newDartExpr;
    }

    return null;
  }

  @override
  CssWidthExpression clone() => CssWidthExpression(span, width);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitWidthExpression(this);
}

class CssPaddingExpression extends CssBoxExpression {
  CssPaddingExpression(SourceSpan? span,
      {num? top, num? right, num? bottom, num? left})
      : super(CssDartStyleExpression.paddingStyle, span,
            CssBoxEdge(left, top, right, bottom));

  CssPaddingExpression.boxEdge(SourceSpan? span, CssBoxEdge? box)
      : super(CssDartStyleExpression.paddingStyle, span, box);

  @override
  CssPaddingExpression? merged(CssDartStyleExpression newDartExpr) {
    if (newDartExpr is CssPaddingExpression &&
        isPadding &&
        newDartExpr.isPadding) {
      return CssPaddingExpression.merge(this, newDartExpr);
    }

    return null;
  }

  factory CssPaddingExpression.merge(
      CssPaddingExpression x, CssPaddingExpression y) {
    return CssPaddingExpression._merge(x, y, y.span);
  }

  CssPaddingExpression._merge(
      CssPaddingExpression x, CssPaddingExpression y, SourceSpan? span)
      : super(CssDartStyleExpression.paddingStyle, span,
            CssBoxEdge.merge(x.box, y.box));

  @override
  CssPaddingExpression clone() => CssPaddingExpression(span,
      top: box!.top, right: box!.right, bottom: box!.bottom, left: box!.left);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitPaddingExpression(this);
}
