// ignore_for_file: prefer_initializing_formals
part of '../visitor.dart';

class Identifier extends TreeNode {
  String name;

  Identifier(this.name, SourceSpan? span) : super(span);

  @override
  Identifier clone() => Identifier(name, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitIdentifier(this);

  @override
  String toString() {
    return span?.text ?? name;
  }
}

class Wildcard extends TreeNode {
  Wildcard(SourceSpan? span) : super(span);
  @override
  Wildcard clone() => Wildcard(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitWildcard(this);

  String get name => '*';
}

class ThisOperator extends TreeNode {
  ThisOperator(SourceSpan? span) : super(span);
  @override
  ThisOperator clone() => ThisOperator(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitThisOperator(this);

  String get name => '&';
}

class Negation extends TreeNode {
  Negation(SourceSpan? span) : super(span);
  @override
  Negation clone() => Negation(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNegation(this);

  String get name => 'not';
}

class CalcTerm extends LiteralTerm {
  final LiteralTerm expr;

  CalcTerm(dynamic value, String t, this.expr, SourceSpan? span)
      : super(value, t, span);

  @override
  CalcTerm clone() => CalcTerm(value, text, expr.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitCalcTerm(this);

  @override
  String toString() => '$text($expr)';
}

class CssComment extends TreeNode {
  final String comment;

  CssComment(this.comment, SourceSpan? span) : super(span);
  @override
  CssComment clone() => CssComment(comment, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitCssComment(this);
}

class CommentDefinition extends CssComment {
  CommentDefinition(String comment, SourceSpan? span) : super(comment, span);
  @override
  CommentDefinition clone() => CommentDefinition(comment, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitCommentDefinition(this);
}

class SelectorGroup extends TreeNode {
  final List<Selector> selectors;

  SelectorGroup(this.selectors, SourceSpan? span) : super(span);

  @override
  SelectorGroup clone() => SelectorGroup(selectors, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSelectorGroup(this);
}

class Selector extends TreeNode {
  final List<SimpleSelectorSequence> simpleSelectorSequences;

  Selector(this.simpleSelectorSequences, SourceSpan? span) : super(span);

  void add(SimpleSelectorSequence seq) => simpleSelectorSequences.add(seq);

  int get length => simpleSelectorSequences.length;

  @override
  Selector clone() {
    List<SimpleSelectorSequence> simpleSequences =
        simpleSelectorSequences.map((ss) => ss.clone()).toList();

    return Selector(simpleSequences, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSelector(this);
}

class SimpleSelectorSequence extends TreeNode {
  int combinator;
  final SimpleSelector simpleSelector;

  SimpleSelectorSequence(this.simpleSelector, SourceSpan? span,
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
  SimpleSelectorSequence clone() =>
      SimpleSelectorSequence(simpleSelector, span, combinator);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitSimpleSelectorSequence(this);

  @override
  String toString() => simpleSelector.name;
}

abstract class SimpleSelector extends TreeNode {
  final dynamic _name;

  SimpleSelector(this._name, SourceSpan? span) : super(span);

  String get name => _name.name as String;

  bool get isWildcard => _name is Wildcard;

  bool get isThis => _name is ThisOperator;

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSimpleSelector(this);
}

class ElementSelector extends SimpleSelector {
  ElementSelector(name, SourceSpan? span) : super(name, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitElementSelector(this);

  @override
  ElementSelector clone() => ElementSelector(_name, span);

  @override
  String toString() => name;
}

class NamespaceSelector extends SimpleSelector {
  final dynamic _namespace;

  NamespaceSelector(this._namespace, dynamic name, SourceSpan? span)
      : super(name, span);

  String get namespace => _namespace is Wildcard
      ? '*'
      : _namespace == null
          ? ''
          : (_namespace as Identifier).name;

  bool get isNamespaceWildcard => _namespace is Wildcard;

  SimpleSelector? get nameAsSimpleSelector => _name as SimpleSelector?;

  @override
  NamespaceSelector clone() => NamespaceSelector(_namespace, '', span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNamespaceSelector(this);

  @override
  String toString() => '$namespace|${nameAsSimpleSelector!.name}';
}

class AttributeSelector extends SimpleSelector {
  final int _op;
  final dynamic value;

  AttributeSelector(Identifier name, this._op, this.value, SourceSpan? span)
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
      if (value is Identifier) {
        return value.toString();
      } else {
        return '"$value"';
      }
    } else {
      return '';
    }
  }

  @override
  AttributeSelector clone() =>
      AttributeSelector(_name as Identifier, _op, value, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitAttributeSelector(this);

  @override
  String toString() => '[$name${matchOperator()}${valueToString()}]';
}

class IdSelector extends SimpleSelector {
  IdSelector(Identifier name, SourceSpan? span) : super(name, span);
  @override
  IdSelector clone() => IdSelector(_name as Identifier, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitIdSelector(this);

  @override
  String toString() => '#$_name';
}

class ClassSelector extends SimpleSelector {
  ClassSelector(Identifier name, SourceSpan? span) : super(name, span);
  @override
  ClassSelector clone() => ClassSelector(_name as Identifier, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitClassSelector(this);

  @override
  String toString() => '.$_name';
}

class PseudoClassSelector extends SimpleSelector {
  PseudoClassSelector(Identifier name, SourceSpan? span) : super(name, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitPseudoClassSelector(this);

  @override
  PseudoClassSelector clone() => PseudoClassSelector(_name as Identifier, span);

  @override
  String toString() => ':$name';
}

class PseudoElementSelector extends SimpleSelector {
  final bool isLegacy;

  PseudoElementSelector(Identifier name, SourceSpan? span,
      {this.isLegacy = false})
      : super(name, span);
  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitPseudoElementSelector(this);

  @override
  PseudoElementSelector clone() =>
      PseudoElementSelector(_name as Identifier, span);

  @override
  String toString() => "${isLegacy ? ':' : '::'}$name";
}

class PseudoClassFunctionSelector extends PseudoClassSelector {
  final TreeNode argument;

  PseudoClassFunctionSelector(Identifier name, this.argument, SourceSpan? span)
      : super(name, span);

  @override
  PseudoClassFunctionSelector clone() =>
      PseudoClassFunctionSelector(_name as Identifier, argument, span);

  Selector get selector => argument as Selector;
  SelectorExpression get expression => argument as SelectorExpression;

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitPseudoClassFunctionSelector(this);
}

class PseudoElementFunctionSelector extends PseudoElementSelector {
  final SelectorExpression expression;

  PseudoElementFunctionSelector(
      Identifier name, this.expression, SourceSpan? span)
      : super(name, span);

  @override
  PseudoElementFunctionSelector clone() =>
      PseudoElementFunctionSelector(_name as Identifier, expression, span);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitPseudoElementFunctionSelector(this);
}

class SelectorExpression extends TreeNode {
  final List<Expression> expressions;

  SelectorExpression(this.expressions, SourceSpan? span) : super(span);

  @override
  SourceSpan get span => super.span!;

  @override
  SelectorExpression clone() {
    return SelectorExpression(expressions.map((e) => e.clone()).toList(), span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSelectorExpression(this);
}

class NegationSelector extends SimpleSelector {
  final SimpleSelector? negationArg;

  NegationSelector(this.negationArg, SourceSpan? span)
      : super(Negation(span), span);

  @override
  NegationSelector clone() => NegationSelector(negationArg, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNegationSelector(this);
}

class NoOp extends TreeNode {
  NoOp() : super(null);

  @override
  NoOp clone() => NoOp();

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNoOp(this);
}

class StyleSheet extends TreeNode {
  final List<TreeNode> topLevels;

  StyleSheet(this.topLevels, SourceSpan? span) : super(span) {
    for (final node in topLevels) {
      assert(node is TopLevelProduction || node is Directive);
    }
  }

  StyleSheet.selector(this.topLevels, SourceSpan? span) : super(span);

  @override
  SourceSpan get span => super.span!;

  @override
  StyleSheet clone() {
    List<TreeNode> clonedTopLevels = topLevels.map((e) => e.clone()).toList();
    return StyleSheet(clonedTopLevels, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitStyleSheet(this);
}

class TopLevelProduction extends TreeNode {
  TopLevelProduction(SourceSpan? span) : super(span);
  @override
  SourceSpan get span => super.span!;
  @override
  TopLevelProduction clone() => TopLevelProduction(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitTopLevelProduction(this);
}

class RuleSet extends TopLevelProduction {
  final SelectorGroup? selectorGroup;
  final DeclarationGroup declarationGroup;

  RuleSet(this.selectorGroup, this.declarationGroup, SourceSpan? span)
      : super(span);

  @override
  RuleSet clone() {
    SelectorGroup cloneSelectorGroup = selectorGroup!.clone();
    DeclarationGroup cloneDeclarationGroup = declarationGroup.clone();
    return RuleSet(cloneSelectorGroup, cloneDeclarationGroup, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitRuleSet(this);
}

class Directive extends TreeNode {
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

class DocumentDirective extends Directive {
  final List<LiteralTerm> functions;
  final List<TreeNode> groupRuleBody;

  DocumentDirective(this.functions, this.groupRuleBody, SourceSpan? span)
      : super(span);

  @override
  DocumentDirective clone() {
    List<LiteralTerm> clonedFunctions = <LiteralTerm>[];
    for (LiteralTerm function in functions) {
      clonedFunctions.add(function.clone());
    }
    List<TreeNode> clonedGroupRuleBody = <TreeNode>[];
    for (TreeNode rule in groupRuleBody) {
      clonedGroupRuleBody.add(rule.clone());
    }
    return DocumentDirective(clonedFunctions, clonedGroupRuleBody, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitDocumentDirective(this);
}

class SupportsDirective extends Directive {
  final SupportsCondition? condition;
  final List<TreeNode> groupRuleBody;

  SupportsDirective(this.condition, this.groupRuleBody, SourceSpan? span)
      : super(span);

  @override
  SupportsDirective clone() {
    SupportsCondition clonedCondition = condition!.clone() as SupportsCondition;
    List<TreeNode> clonedGroupRuleBody = <TreeNode>[];
    for (TreeNode rule in groupRuleBody) {
      clonedGroupRuleBody.add(rule.clone());
    }
    return SupportsDirective(clonedCondition, clonedGroupRuleBody, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSupportsDirective(this);
}

abstract class SupportsCondition extends TreeNode {
  SupportsCondition(SourceSpan? span) : super(span);
  @override
  SourceSpan get span => super.span!;
}

class SupportsConditionInParens extends SupportsCondition {
  final TreeNode? condition;

  SupportsConditionInParens(Declaration? declaration, SourceSpan? span)
      : condition = declaration,
        super(span);

  SupportsConditionInParens.nested(
      SupportsCondition condition, SourceSpan? span)
      : condition = condition,
        super(span);

  @override
  SupportsConditionInParens clone() =>
      SupportsConditionInParens(condition!.clone() as Declaration, span);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitSupportsConditionInParens(this);
}

class SupportsNegation extends SupportsCondition {
  final SupportsConditionInParens condition;

  SupportsNegation(this.condition, SourceSpan? span) : super(span);

  @override
  SupportsNegation clone() => SupportsNegation(condition.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSupportsNegation(this);
}

class SupportsConjunction extends SupportsCondition {
  final List<SupportsConditionInParens> conditions;

  SupportsConjunction(this.conditions, SourceSpan? span) : super(span);

  @override
  SupportsConjunction clone() {
    List<SupportsConditionInParens> clonedConditions =
        <SupportsConditionInParens>[];
    for (SupportsConditionInParens condition in conditions) {
      clonedConditions.add(condition.clone());
    }
    return SupportsConjunction(clonedConditions, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSupportsConjunction(this);
}

class SupportsDisjunction extends SupportsCondition {
  final List<SupportsConditionInParens> conditions;

  SupportsDisjunction(this.conditions, SourceSpan? span) : super(span);

  @override
  SupportsDisjunction clone() {
    List<SupportsConditionInParens> clonedConditions =
        <SupportsConditionInParens>[];
    for (SupportsConditionInParens condition in conditions) {
      clonedConditions.add(condition.clone());
    }
    return SupportsDisjunction(clonedConditions, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitSupportsDisjunction(this);
}

class ViewportDirective extends Directive {
  final String name;
  final DeclarationGroup declarations;

  ViewportDirective(this.name, this.declarations, SourceSpan? span)
      : super(span);

  @override
  ViewportDirective clone() =>
      ViewportDirective(name, declarations.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitViewportDirective(this);
}

class ImportDirective extends Directive {
  final String import;

  final List<MediaQuery> mediaQueries;

  ImportDirective(this.import, this.mediaQueries, SourceSpan? span)
      : super(span);

  @override
  ImportDirective clone() {
    List<MediaQuery> cloneMediaQueries = <MediaQuery>[];
    for (MediaQuery mediaQuery in mediaQueries) {
      cloneMediaQueries.add(mediaQuery.clone());
    }
    return ImportDirective(import, cloneMediaQueries, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitImportDirective(this);
}

class MediaExpression extends TreeNode {
  final bool andOperator;
  final Identifier _mediaFeature;
  final Expressions exprs;

  MediaExpression(
      this.andOperator, this._mediaFeature, this.exprs, SourceSpan? span)
      : super(span);

  String get mediaFeature => _mediaFeature.name;

  @override
  SourceSpan get span => super.span!;

  @override
  MediaExpression clone() {
    Expressions clonedExprs = exprs.clone();
    return MediaExpression(andOperator, _mediaFeature, clonedExprs, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMediaExpression(this);
}

class MediaQuery extends TreeNode {
  final int _mediaUnary;
  final Identifier? _mediaType;
  final List<MediaExpression> expressions;

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
    List<MediaExpression> cloneExpressions = <MediaExpression>[];
    for (MediaExpression expr in expressions) {
      cloneExpressions.add(expr.clone());
    }
    return MediaQuery(_mediaUnary, _mediaType, cloneExpressions, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMediaQuery(this);
}

class MediaDirective extends Directive {
  final List<MediaQuery> mediaQueries;
  final List<TreeNode> rules;

  MediaDirective(this.mediaQueries, this.rules, SourceSpan? span) : super(span);

  @override
  MediaDirective clone() {
    List<MediaQuery> cloneQueries = <MediaQuery>[];
    for (MediaQuery mediaQuery in mediaQueries) {
      cloneQueries.add(mediaQuery.clone());
    }
    List<TreeNode> cloneRules = <TreeNode>[];
    for (TreeNode rule in rules) {
      cloneRules.add(rule.clone());
    }
    return MediaDirective(cloneQueries, cloneRules, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMediaDirective(this);
}

class HostDirective extends Directive {
  final List<TreeNode> rules;

  HostDirective(this.rules, SourceSpan? span) : super(span);

  @override
  HostDirective clone() {
    List<TreeNode> cloneRules = <TreeNode>[];
    for (TreeNode rule in rules) {
      cloneRules.add(rule.clone());
    }
    return HostDirective(cloneRules, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitHostDirective(this);
}

class PageDirective extends Directive {
  final String? _ident;
  final String? _pseudoPage;
  final List<DeclarationGroup> _declsMargin;

  PageDirective(
      this._ident, this._pseudoPage, this._declsMargin, SourceSpan? span)
      : super(span);

  @override
  PageDirective clone() {
    List<DeclarationGroup> cloneDeclsMargin = <DeclarationGroup>[];
    for (DeclarationGroup declMargin in _declsMargin) {
      cloneDeclsMargin.add(declMargin.clone());
    }
    return PageDirective(_ident, _pseudoPage, cloneDeclsMargin, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitPageDirective(this);

  bool get hasIdent => _ident?.isNotEmpty ?? false;
  bool get hasPseudoPage => _pseudoPage?.isNotEmpty ?? false;
}

class CharsetDirective extends Directive {
  final String charEncoding;

  CharsetDirective(this.charEncoding, SourceSpan? span) : super(span);
  @override
  CharsetDirective clone() => CharsetDirective(charEncoding, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitCharsetDirective(this);
}

class KeyFrameDirective extends Directive {
  final int _keyframeName;
  final Identifier? name;
  final List<KeyFrameBlock> _blocks;

  KeyFrameDirective(this._keyframeName, this.name, SourceSpan? span)
      : _blocks = [],
        super(span);

  void add(KeyFrameBlock block) {
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
  KeyFrameDirective clone() {
    KeyFrameDirective directive =
        KeyFrameDirective(_keyframeName, name!.clone(), span);
    for (KeyFrameBlock block in _blocks) {
      directive.add(block.clone());
    }
    return directive;
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitKeyFrameDirective(this);
}

class KeyFrameBlock extends Expression {
  final Expressions _blockSelectors;
  final DeclarationGroup _declarations;

  KeyFrameBlock(this._blockSelectors, this._declarations, SourceSpan? span)
      : super(span);

  @override
  KeyFrameBlock clone() =>
      KeyFrameBlock(_blockSelectors.clone(), _declarations.clone(), span);
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
  final List<TreeNode> rules;

  StyletDirective(this.dartClassName, this.rules, SourceSpan? span)
      : super(span);

  @override
  bool get isBuiltIn => false;
  @override
  bool get isExtension => true;

  @override
  StyletDirective clone() {
    List<TreeNode> cloneRules = <TreeNode>[];
    for (TreeNode rule in rules) {
      cloneRules.add(rule.clone());
    }
    return StyletDirective(dartClassName, cloneRules, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitStyletDirective(this);
}

class NamespaceDirective extends Directive {
  final String _prefix;

  final String? _uri;

  NamespaceDirective(this._prefix, this._uri, SourceSpan? span) : super(span);

  @override
  NamespaceDirective clone() => NamespaceDirective(_prefix, _uri, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNamespaceDirective(this);

  String get prefix => _prefix.isNotEmpty ? '$_prefix ' : '';
}

class VarDefinitionDirective extends Directive {
  final VarDefinition def;

  VarDefinitionDirective(this.def, SourceSpan? span) : super(span);

  @override
  VarDefinitionDirective clone() => VarDefinitionDirective(def.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitVarDefinitionDirective(this);
}

class MixinDefinition extends Directive {
  final String name;
  final List<TreeNode> definedArgs;
  final bool varArgs;

  MixinDefinition(this.name, this.definedArgs, this.varArgs, SourceSpan? span)
      : super(span);

  @override
  MixinDefinition clone() {
    List<TreeNode> cloneDefinedArgs = <TreeNode>[];
    for (TreeNode definedArg in definedArgs) {
      cloneDefinedArgs.add(definedArg.clone());
    }
    return MixinDefinition(name, cloneDefinedArgs, varArgs, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMixinDefinition(this);
}

class MixinRulesetDirective extends MixinDefinition {
  final List<TreeNode> rulesets;

  MixinRulesetDirective(String name, List<TreeNode> args, bool varArgs,
      this.rulesets, SourceSpan? span)
      : super(name, args, varArgs, span);

  @override
  MixinRulesetDirective clone() {
    List<VarDefinition> clonedArgs = <VarDefinition>[];
    for (TreeNode arg in definedArgs) {
      clonedArgs.add(arg.clone() as VarDefinition);
    }
    List<TreeNode> clonedRulesets = <TreeNode>[];
    for (TreeNode ruleset in rulesets) {
      clonedRulesets.add(ruleset.clone());
    }
    return MixinRulesetDirective(
        name, clonedArgs, varArgs, clonedRulesets, span);
  }

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitMixinRulesetDirective(this);
}

class MixinDeclarationDirective extends MixinDefinition {
  final DeclarationGroup declarations;

  MixinDeclarationDirective(String name, List<TreeNode> args, bool varArgs,
      this.declarations, SourceSpan? span)
      : super(name, args, varArgs, span);

  @override
  MixinDeclarationDirective clone() {
    List<TreeNode> clonedArgs = <TreeNode>[];
    for (TreeNode arg in definedArgs) {
      clonedArgs.add(arg.clone());
    }
    return MixinDeclarationDirective(
        name, clonedArgs, varArgs, declarations.clone(), span);
  }

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitMixinDeclarationDirective(this);
}

class IncludeDirective extends Directive {
  final String name;
  final List<List<Expression>> args;

  IncludeDirective(this.name, this.args, SourceSpan? span) : super(span);

  @override
  IncludeDirective clone() {
    List<List<Expression>> cloneArgs = <List<Expression>>[];
    for (List<Expression> arg in args) {
      cloneArgs.add(arg.map((term) => term.clone()).toList());
    }
    return IncludeDirective(name, cloneArgs, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitIncludeDirective(this);
}

class ContentDirective extends Directive {
  ContentDirective(SourceSpan? span) : super(span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitContentDirective(this);
}

class Declaration extends TreeNode {
  final Identifier? _property;
  final Expression? expression;

  DartStyleExpression? dartStyle;
  final bool important;

  final bool isIE7;

  Declaration(this._property, this.expression, this.dartStyle, SourceSpan? span,
      {this.important = false, bool ie7 = false})
      : isIE7 = ie7,
        super(span);

  String get property => isIE7 ? '*${_property!.name}' : _property!.name;

  bool get hasDartStyle => dartStyle != null;

  @override
  SourceSpan get span => super.span!;

  @override
  Declaration clone() =>
      Declaration(_property!.clone(), expression!.clone(), dartStyle, span,
          important: important);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitDeclaration(this);
}

class VarDefinition extends Declaration {
  bool badUsage = false;

  VarDefinition(Identifier? definedName, Expression? expr, SourceSpan? span)
      : super(definedName, expr, null, span);

  String get definedName => _property!.name;

  @override
  VarDefinition clone() =>
      VarDefinition(_property!.clone(), expression?.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitVarDefinition(this);
}

class IncludeMixinAtDeclaration extends Declaration {
  final IncludeDirective include;

  IncludeMixinAtDeclaration(this.include, SourceSpan? span)
      : super(null, null, null, span);

  @override
  IncludeMixinAtDeclaration clone() =>
      IncludeMixinAtDeclaration(include.clone(), span);

  @override
  dynamic visit(VisitorBase visitor) =>
      visitor.visitIncludeMixinAtDeclaration(this);
}

class ExtendDeclaration extends Declaration {
  final List<TreeNode> selectors;

  ExtendDeclaration(this.selectors, SourceSpan? span)
      : super(null, null, null, span);

  @override
  ExtendDeclaration clone() {
    List<TreeNode> newSelector = selectors.map((s) => s.clone()).toList();
    return ExtendDeclaration(newSelector, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitExtendDeclaration(this);
}

class DeclarationGroup extends TreeNode {
  final List<TreeNode> declarations;

  DeclarationGroup(this.declarations, SourceSpan? span) : super(span);

  @override
  SourceSpan get span => super.span!;

  @override
  DeclarationGroup clone() {
    List<TreeNode> clonedDecls = declarations.map((d) => d.clone()).toList();
    return DeclarationGroup(clonedDecls, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitDeclarationGroup(this);
}

class MarginGroup extends DeclarationGroup {
  final int marginSym;

  MarginGroup(this.marginSym, List<TreeNode> decls, SourceSpan? span)
      : super(decls, span);
  @override
  MarginGroup clone() =>
      MarginGroup(marginSym, super.clone().declarations, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMarginGroup(this);
}

class VarUsage extends Expression {
  final String name;
  final List<Expression> defaultValues;

  VarUsage(this.name, this.defaultValues, SourceSpan? span) : super(span);

  @override
  VarUsage clone() {
    List<Expression> clonedValues = <Expression>[];
    for (Expression expr in defaultValues) {
      clonedValues.add(expr.clone());
    }
    return VarUsage(name, clonedValues, span);
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitVarUsage(this);
}

class OperatorSlash extends Expression {
  OperatorSlash(SourceSpan? span) : super(span);
  @override
  OperatorSlash clone() => OperatorSlash(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitOperatorSlash(this);
}

class OperatorComma extends Expression {
  OperatorComma(SourceSpan? span) : super(span);
  @override
  OperatorComma clone() => OperatorComma(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitOperatorComma(this);
}

class OperatorPlus extends Expression {
  OperatorPlus(SourceSpan? span) : super(span);
  @override
  OperatorPlus clone() => OperatorPlus(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitOperatorPlus(this);
}

class OperatorMinus extends Expression {
  OperatorMinus(SourceSpan? span) : super(span);
  @override
  OperatorMinus clone() => OperatorMinus(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitOperatorMinus(this);
}

class UnicodeRangeTerm extends Expression {
  final String? first;
  final String? second;

  UnicodeRangeTerm(this.first, this.second, SourceSpan? span) : super(span);

  bool get hasSecond => second != null;

  @override
  UnicodeRangeTerm clone() => UnicodeRangeTerm(first, second, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitUnicodeRangeTerm(this);
}

class LiteralTerm extends Expression {
  dynamic value;
  String text;

  LiteralTerm(this.value, this.text, SourceSpan? span) : super(span);

  @override
  LiteralTerm clone() => LiteralTerm(value, text, span);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitLiteralTerm(this);
}

class NumberTerm extends LiteralTerm {
  NumberTerm(value, String t, SourceSpan? span) : super(value, t, span);
  @override
  NumberTerm clone() => NumberTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitNumberTerm(this);
}

class UnitTerm extends LiteralTerm {
  final int unit;

  UnitTerm(value, String t, SourceSpan? span, this.unit)
      : super(value, t, span);

  @override
  UnitTerm clone() => UnitTerm(value, text, span, unit);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitUnitTerm(this);

  String? unitToString() => CssTokenKind.unitToString(unit);

  @override
  String toString() => '$text${unitToString()}';
}

class LengthTerm extends UnitTerm {
  LengthTerm(value, String t, SourceSpan? span,
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
  LengthTerm clone() => LengthTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitLengthTerm(this);
}

class PercentageTerm extends LiteralTerm {
  PercentageTerm(value, String t, SourceSpan? span) : super(value, t, span);
  @override
  PercentageTerm clone() => PercentageTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitPercentageTerm(this);
}

class EmTerm extends LiteralTerm {
  EmTerm(value, String t, SourceSpan? span) : super(value, t, span);
  @override
  EmTerm clone() => EmTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitEmTerm(this);
}

class ExTerm extends LiteralTerm {
  ExTerm(value, String t, SourceSpan? span) : super(value, t, span);
  @override
  ExTerm clone() => ExTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitExTerm(this);
}

class AngleTerm extends UnitTerm {
  AngleTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(this.unit == CssTokenKind.UNIT_ANGLE_DEG ||
        this.unit == CssTokenKind.UNIT_ANGLE_RAD ||
        this.unit == CssTokenKind.UNIT_ANGLE_GRAD ||
        this.unit == CssTokenKind.UNIT_ANGLE_TURN);
  }

  @override
  AngleTerm clone() => AngleTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitAngleTerm(this);
}

class TimeTerm extends UnitTerm {
  TimeTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(this.unit == CssTokenKind.UNIT_ANGLE_DEG ||
        this.unit == CssTokenKind.UNIT_TIME_MS ||
        this.unit == CssTokenKind.UNIT_TIME_S);
  }

  @override
  TimeTerm clone() => TimeTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitTimeTerm(this);
}

class FreqTerm extends UnitTerm {
  FreqTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_FREQ_HZ ||
        unit == CssTokenKind.UNIT_FREQ_KHZ);
  }

  @override
  FreqTerm clone() => FreqTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitFreqTerm(this);
}

class FractionTerm extends LiteralTerm {
  FractionTerm(dynamic value, String t, SourceSpan? span)
      : super(value, t, span);

  @override
  FractionTerm clone() => FractionTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitFractionTerm(this);
}

class UriTerm extends LiteralTerm {
  UriTerm(String value, SourceSpan? span) : super(value, value, span);

  @override
  UriTerm clone() => UriTerm(value as String, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitUriTerm(this);
}

class ResolutionTerm extends UnitTerm {
  ResolutionTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_RESOLUTION_DPI ||
        unit == CssTokenKind.UNIT_RESOLUTION_DPCM ||
        unit == CssTokenKind.UNIT_RESOLUTION_DPPX);
  }

  @override
  ResolutionTerm clone() => ResolutionTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitResolutionTerm(this);
}

class ChTerm extends UnitTerm {
  ChTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_CH);
  }

  @override
  ChTerm clone() => ChTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitChTerm(this);
}

class RemTerm extends UnitTerm {
  RemTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_REM);
  }

  @override
  RemTerm clone() => RemTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitRemTerm(this);
}

class ViewportTerm extends UnitTerm {
  ViewportTerm(dynamic value, String t, SourceSpan? span,
      [int unit = CssTokenKind.UNIT_LENGTH_PX])
      : super(value, t, span, unit) {
    assert(unit == CssTokenKind.UNIT_VIEWPORT_VW ||
        unit == CssTokenKind.UNIT_VIEWPORT_VH ||
        unit == CssTokenKind.UNIT_VIEWPORT_VMIN ||
        unit == CssTokenKind.UNIT_VIEWPORT_VMAX);
  }

  @override
  ViewportTerm clone() => ViewportTerm(value, text, span, unit);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitViewportTerm(this);
}

class BadHexValue {}

class HexColorTerm extends LiteralTerm {
  HexColorTerm(dynamic value, String t, SourceSpan? span)
      : super(value, t, span);

  @override
  HexColorTerm clone() => HexColorTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitHexColorTerm(this);
}

class FunctionTerm extends LiteralTerm {
  final Expressions _params;

  FunctionTerm(dynamic value, String t, this._params, SourceSpan? span)
      : super(value, t, span);

  @override
  FunctionTerm clone() => FunctionTerm(value, text, _params.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitFunctionTerm(this);
}

class IE8Term extends LiteralTerm {
  IE8Term(SourceSpan? span) : super('\\9', '\\9', span);
  @override
  IE8Term clone() => IE8Term(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitIE8Term(this);
}

class GroupTerm extends Expression {
  final List<LiteralTerm> _terms;

  GroupTerm(SourceSpan? span)
      : _terms = [],
        super(span);

  void add(LiteralTerm term) {
    _terms.add(term);
  }

  @override
  GroupTerm clone() => GroupTerm(span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitGroupTerm(this);
}

class ItemTerm extends NumberTerm {
  ItemTerm(dynamic value, String t, SourceSpan? span) : super(value, t, span);

  @override
  ItemTerm clone() => ItemTerm(value, text, span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitItemTerm(this);
}

class Expressions extends Expression {
  final List<Expression> expressions = [];

  Expressions(SourceSpan? span) : super(span);

  void add(Expression expression) {
    expressions.add(expression);
  }

  @override
  Expressions clone() {
    Expressions clonedExprs = Expressions(span);
    for (Expression expr in expressions) {
      clonedExprs.add(expr.clone());
    }
    return clonedExprs;
  }

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitExpressions(this);
}

class BinaryExpression extends Expression {
  final CssToken op;
  final Expression x;
  final Expression y;

  BinaryExpression(this.op, this.x, this.y, SourceSpan? span) : super(span);

  @override
  BinaryExpression clone() => BinaryExpression(op, x.clone(), y.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitBinaryExpression(this);
}

class UnaryExpression extends Expression {
  final CssToken op;
  final Expression self;

  UnaryExpression(this.op, this.self, SourceSpan? span) : super(span);

  @override
  UnaryExpression clone() => UnaryExpression(op, self.clone(), span);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitUnaryExpression(this);
}

abstract class DartStyleExpression extends TreeNode {
  static const int unknownType = 0;
  static const int fontStyle = 1;
  static const int marginStyle = 2;
  static const int borderStyle = 3;
  static const int paddingStyle = 4;
  static const int heightStyle = 5;
  static const int widthStyle = 6;

  final int? _styleType;
  int? priority;

  DartStyleExpression(this._styleType, SourceSpan? span) : super(span);

  DartStyleExpression? merged(DartStyleExpression newDartExpr);

  bool get isUnknown => _styleType == 0 || _styleType == null;
  bool get isFont => _styleType == fontStyle;
  bool get isMargin => _styleType == marginStyle;
  bool get isBorder => _styleType == borderStyle;
  bool get isPadding => _styleType == paddingStyle;
  bool get isHeight => _styleType == heightStyle;
  bool get isWidth => _styleType == widthStyle;
  bool get isBoxExpression => isMargin || isBorder || isPadding;

  bool isSame(DartStyleExpression other) => _styleType == other._styleType;

  @override
  SourceSpan get span => super.span!;

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitDartStyleExpression(this);
}

class FontExpression extends DartStyleExpression {
  final Font font;

  FontExpression(SourceSpan? span,
      {Object? /* LengthTerm | num */ size,
      List<String>? family,
      int? weight,
      String? style,
      String? variant,
      LineHeight? lineHeight})
      : font = Font(
            size: (size is LengthTerm ? size.value : size) as num?,
            family: family,
            weight: weight,
            style: style,
            variant: variant,
            lineHeight: lineHeight),
        super(DartStyleExpression.fontStyle, span);

  @override
  FontExpression? merged(DartStyleExpression newDartExpr) {
    if (newDartExpr is FontExpression && isFont && newDartExpr.isFont) {
      return FontExpression.merge(this, newDartExpr);
    }
    return null;
  }

  factory FontExpression.merge(FontExpression x, FontExpression y) {
    return FontExpression._merge(x, y, y.span);
  }

  FontExpression._merge(FontExpression x, FontExpression y, SourceSpan? span)
      : font = Font.merge(x.font, y.font)!,
        super(DartStyleExpression.fontStyle, span);

  @override
  FontExpression clone() => FontExpression(span,
      size: font.size,
      family: font.family,
      weight: font.weight,
      style: font.style,
      variant: font.variant,
      lineHeight: font.lineHeight);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitFontExpression(this);
}

abstract class BoxExpression extends DartStyleExpression {
  final BoxEdge? box;

  BoxExpression(int? styleType, SourceSpan? span, this.box)
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

class MarginExpression extends BoxExpression {
  MarginExpression(SourceSpan? span,
      {num? top, num? right, num? bottom, num? left})
      : super(DartStyleExpression.marginStyle, span,
            BoxEdge(left, top, right, bottom));

  MarginExpression.boxEdge(SourceSpan? span, BoxEdge? box)
      : super(DartStyleExpression.marginStyle, span, box);

  @override
  MarginExpression? merged(DartStyleExpression newDartExpr) {
    if (newDartExpr is MarginExpression && isMargin && newDartExpr.isMargin) {
      return MarginExpression.merge(this, newDartExpr);
    }

    return null;
  }

  factory MarginExpression.merge(MarginExpression x, MarginExpression y) {
    return MarginExpression._merge(x, y, y.span);
  }

  MarginExpression._merge(
      MarginExpression x, MarginExpression y, SourceSpan? span)
      : super(x._styleType, span, BoxEdge.merge(x.box, y.box));

  @override
  MarginExpression clone() => MarginExpression(span,
      top: box!.top, right: box!.right, bottom: box!.bottom, left: box!.left);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitMarginExpression(this);
}

class BorderExpression extends BoxExpression {
  BorderExpression(SourceSpan? span,
      {num? top, num? right, num? bottom, num? left})
      : super(DartStyleExpression.borderStyle, span,
            BoxEdge(left, top, right, bottom));

  BorderExpression.boxEdge(SourceSpan? span, BoxEdge box)
      : super(DartStyleExpression.borderStyle, span, box);

  @override
  BorderExpression? merged(DartStyleExpression newDartExpr) {
    if (newDartExpr is BorderExpression && isBorder && newDartExpr.isBorder) {
      return BorderExpression.merge(this, newDartExpr);
    }

    return null;
  }

  factory BorderExpression.merge(BorderExpression x, BorderExpression y) {
    return BorderExpression._merge(x, y, y.span);
  }

  BorderExpression._merge(
      BorderExpression x, BorderExpression y, SourceSpan? span)
      : super(
            DartStyleExpression.borderStyle, span, BoxEdge.merge(x.box, y.box));

  @override
  BorderExpression clone() => BorderExpression(span,
      top: box!.top, right: box!.right, bottom: box!.bottom, left: box!.left);

  @override
  dynamic visit(VisitorBase visitor) => visitor.visitBorderExpression(this);
}

class HeightExpression extends DartStyleExpression {
  final dynamic height;

  HeightExpression(SourceSpan? span, this.height)
      : super(DartStyleExpression.heightStyle, span);

  @override
  HeightExpression? merged(DartStyleExpression newDartExpr) {
    if (isHeight && newDartExpr.isHeight) {
      return newDartExpr as HeightExpression;
    }

    return null;
  }

  @override
  HeightExpression clone() => HeightExpression(span, height);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitHeightExpression(this);
}

class WidthExpression extends DartStyleExpression {
  final dynamic width;

  WidthExpression(SourceSpan? span, this.width)
      : super(DartStyleExpression.widthStyle, span);

  @override
  WidthExpression? merged(DartStyleExpression newDartExpr) {
    if (newDartExpr is WidthExpression && isWidth && newDartExpr.isWidth) {
      return newDartExpr;
    }

    return null;
  }

  @override
  WidthExpression clone() => WidthExpression(span, width);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitWidthExpression(this);
}

class PaddingExpression extends BoxExpression {
  PaddingExpression(SourceSpan? span,
      {num? top, num? right, num? bottom, num? left})
      : super(DartStyleExpression.paddingStyle, span,
            BoxEdge(left, top, right, bottom));

  PaddingExpression.boxEdge(SourceSpan? span, BoxEdge? box)
      : super(DartStyleExpression.paddingStyle, span, box);

  @override
  PaddingExpression? merged(DartStyleExpression newDartExpr) {
    if (newDartExpr is PaddingExpression &&
        isPadding &&
        newDartExpr.isPadding) {
      return PaddingExpression.merge(this, newDartExpr);
    }

    return null;
  }

  factory PaddingExpression.merge(PaddingExpression x, PaddingExpression y) {
    return PaddingExpression._merge(x, y, y.span);
  }

  PaddingExpression._merge(
      PaddingExpression x, PaddingExpression y, SourceSpan? span)
      : super(DartStyleExpression.paddingStyle, span,
            BoxEdge.merge(x.box, y.box));

  @override
  PaddingExpression clone() => PaddingExpression(span,
      top: box!.top, right: box!.right, bottom: box!.bottom, left: box!.left);
  @override
  dynamic visit(VisitorBase visitor) => visitor.visitPaddingExpression(this);
}
