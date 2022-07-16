// ignore_for_file: avoid_function_literals_in_foreach_calls

part of '../parser.dart';

class Analyzer {
  final List<StyleSheet> _styleSheets;
  final Messages _messages;

  Analyzer(this._styleSheets, this._messages);

  void run() {
    _styleSheets.forEach(
        (styleSheet) => TopLevelIncludes.expand(_messages, _styleSheets));

    _styleSheets.forEach(
        (styleSheet) => DeclarationIncludes.expand(_messages, _styleSheets));

    _styleSheets.forEach((styleSheet) => MixinsAndIncludes.remove(styleSheet));

    _styleSheets.forEach((styleSheet) => ExpandNestedSelectors()
      ..visitStyleSheet(styleSheet)
      ..flatten(styleSheet));

    _styleSheets.forEach((styleSheet) {
      var allExtends = AllExtends()..visitStyleSheet(styleSheet);
      InheritExtends(_messages, allExtends).visitStyleSheet(styleSheet);
    });
  }
}

class ExpandNestedSelectors extends Visitor {
  RuleSet? _parentRuleSet;

  SelectorGroup? _topLevelSelectorGroup;

  SelectorGroup? _nestedSelectorGroup;

  DeclarationGroup? _flatDeclarationGroup;

  List<RuleSet> _expandedRuleSets = [];

  final _expansions = <RuleSet, List<RuleSet>>{};

  @override
  void visitRuleSet(RuleSet node) {
    final oldParent = _parentRuleSet;

    var oldNestedSelectorGroups = _nestedSelectorGroup;

    if (_nestedSelectorGroup == null) {
      final newSelectors = node.selectorGroup!.selectors.toList();
      _topLevelSelectorGroup = SelectorGroup(newSelectors, node.span);
      _nestedSelectorGroup = _topLevelSelectorGroup;
    } else {
      _nestedSelectorGroup = _mergeToFlatten(node);
    }

    _parentRuleSet = node;

    super.visitRuleSet(node);

    _parentRuleSet = oldParent;

    node.declarationGroup.declarations
        .removeWhere((declaration) => declaration is RuleSet);

    _nestedSelectorGroup = oldNestedSelectorGroups;

    if (_parentRuleSet == null) {
      if (_expandedRuleSets.isNotEmpty) {
        _expansions[node] = _expandedRuleSets;
        _expandedRuleSets = [];
      }
      assert(_flatDeclarationGroup == null);
      assert(_nestedSelectorGroup == null);
    }
  }

  SelectorGroup _mergeToFlatten(RuleSet node) {
    var nestedSelectors = _nestedSelectorGroup!.selectors;
    var selectors = node.selectorGroup!.selectors;

    var newSelectors = <Selector>[];
    for (var selector in selectors) {
      for (var nestedSelector in nestedSelectors) {
        var seq = _mergeNestedSelector(nestedSelector.simpleSelectorSequences,
            selector.simpleSelectorSequences);
        newSelectors.add(Selector(seq, node.span));
      }
    }

    return SelectorGroup(newSelectors, node.span);
  }

  List<SimpleSelectorSequence> _mergeNestedSelector(
      List<SimpleSelectorSequence> parent,
      List<SimpleSelectorSequence> current) {
    var hasThis = current.any((s) => s.simpleSelector.isThis);

    var newSequence = <SimpleSelectorSequence>[];

    if (!hasThis) {
      newSequence.addAll(parent);
      newSequence.addAll(_convertToDescendentSequence(current));
    } else {
      for (var sequence in current) {
        if (sequence.simpleSelector.isThis) {
          var hasPrefix = newSequence.isNotEmpty &&
              newSequence.last.simpleSelector.name.isNotEmpty;
          newSequence.addAll(
              hasPrefix ? _convertToDescendentSequence(parent) : parent);
        } else {
          newSequence.add(sequence);
        }
      }
    }

    return newSequence;
  }

  List<SimpleSelectorSequence> _convertToDescendentSequence(
      List<SimpleSelectorSequence> sequences) {
    if (sequences.isEmpty) return sequences;

    var newSequences = <SimpleSelectorSequence>[];
    var first = sequences.first;
    newSequences.add(SimpleSelectorSequence(
        first.simpleSelector, first.span, TokenKind.COMBINATOR_DESCENDANT));
    newSequences.addAll(sequences.skip(1));

    return newSequences;
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    var span = node.span;

    var currentGroup = DeclarationGroup([], span);

    var oldGroup = _flatDeclarationGroup;
    _flatDeclarationGroup = currentGroup;

    var expandedLength = _expandedRuleSets.length;

    super.visitDeclarationGroup(node);

    _flatDeclarationGroup = oldGroup;

    if (_nestedSelectorGroup == _topLevelSelectorGroup) return;

    if (currentGroup.declarations.isEmpty) return;

    var selectorGroup = _nestedSelectorGroup;

    var newRuleSet = RuleSet(selectorGroup, currentGroup, span);

    if (expandedLength == _expandedRuleSets.length) {
      _expandedRuleSets.add(newRuleSet);
    } else {
      _expandedRuleSets.insert(expandedLength, newRuleSet);
    }
  }

  @override
  void visitDeclaration(Declaration node) {
    if (_parentRuleSet != null) {
      _flatDeclarationGroup!.declarations.add(node);
    }
    super.visitDeclaration(node);
  }

  @override
  void visitVarDefinition(VarDefinition node) {
    if (_parentRuleSet != null) {
      _flatDeclarationGroup!.declarations.add(node);
    }
    super.visitVarDefinition(node);
  }

  @override
  void visitExtendDeclaration(ExtendDeclaration node) {
    if (_parentRuleSet != null) {
      _flatDeclarationGroup!.declarations.add(node);
    }
    super.visitExtendDeclaration(node);
  }

  @override
  void visitMarginGroup(MarginGroup node) {
    if (_parentRuleSet != null) {
      _flatDeclarationGroup!.declarations.add(node);
    }
    super.visitMarginGroup(node);
  }

  void flatten(StyleSheet styleSheet) {
    _expansions.forEach((RuleSet ruleSet, List<RuleSet> newRules) {
      var index = styleSheet.topLevels.indexOf(ruleSet);
      if (index == -1) {
        var found = _MediaRulesReplacer.replace(styleSheet, ruleSet, newRules);
        assert(found);
      } else {
        styleSheet.topLevels.insertAll(index + 1, newRules);
      }
    });
    _expansions.clear();
  }
}

class _MediaRulesReplacer extends Visitor {
  final RuleSet _ruleSet;
  final List<RuleSet> _newRules;
  bool _foundAndReplaced = false;

  static bool replace(
      StyleSheet styleSheet, RuleSet ruleSet, List<RuleSet> newRules) {
    var visitor = _MediaRulesReplacer(ruleSet, newRules);
    visitor.visitStyleSheet(styleSheet);
    return visitor._foundAndReplaced;
  }

  _MediaRulesReplacer(this._ruleSet, this._newRules);

  @override
  void visitMediaDirective(MediaDirective node) {
    var index = node.rules.indexOf(_ruleSet);
    if (index != -1) {
      node.rules.insertAll(index + 1, _newRules);
      _foundAndReplaced = true;
    }
  }
}

class TopLevelIncludes extends Visitor {
  StyleSheet? _styleSheet;
  final Messages _messages;

  final map = <String, MixinDefinition>{};
  MixinDefinition? currDef;

  static void expand(Messages messages, List<StyleSheet> styleSheets) {
    TopLevelIncludes(messages, styleSheets);
  }

  bool _anyRulesets(MixinRulesetDirective def) =>
      def.rulesets.any((rule) => rule is RuleSet);

  TopLevelIncludes(this._messages, List<StyleSheet> styleSheets) {
    for (var styleSheet in styleSheets) {
      visitTree(styleSheet);
    }
  }

  @override
  void visitStyleSheet(StyleSheet ss) {
    _styleSheet = ss;
    super.visitStyleSheet(ss);
    _styleSheet = null;
  }

  @override
  void visitIncludeDirective(IncludeDirective node) {
    final currDef = this.currDef;
    if (map.containsKey(node.name)) {
      var mixinDef = map[node.name];
      if (mixinDef is MixinRulesetDirective) {
        _TopLevelIncludeReplacer.replace(
            _messages, _styleSheet!, node, mixinDef.rulesets);
      } else if (currDef is MixinRulesetDirective && _anyRulesets(currDef)) {
        final mixinRuleset = currDef;
        var index = mixinRuleset.rulesets.indexOf(node);
        mixinRuleset.rulesets.removeAt(index);
        _messages.warning(
            'Using declaration mixin ${node.name} as top-level mixin',
            node.span);
      }
    } else {
      if (currDef is MixinRulesetDirective) {
        var rulesetDirect = currDef;
        rulesetDirect.rulesets.removeWhere((entry) {
          if (entry == node) {
            _messages.warning('Undefined mixin ${node.name}', node.span);
            return true;
          }
          return false;
        });
      }
    }
    super.visitIncludeDirective(node);
  }

  @override
  void visitMixinRulesetDirective(MixinRulesetDirective node) {
    currDef = node;

    super.visitMixinRulesetDirective(node);

    map[node.name] = node;
    currDef = null;
  }

  @override
  void visitMixinDeclarationDirective(MixinDeclarationDirective node) {
    currDef = node;

    super.visitMixinDeclarationDirective(node);

    map[node.name] = node;
    currDef = null;
  }
}

class _TopLevelIncludeReplacer extends Visitor {
  final IncludeDirective _include;
  final List<TreeNode> _newRules;
  bool _foundAndReplaced = false;

  static bool replace(Messages messages, StyleSheet styleSheet,
      IncludeDirective include, List<TreeNode> newRules) {
    var visitor = _TopLevelIncludeReplacer(include, newRules);
    visitor.visitStyleSheet(styleSheet);
    return visitor._foundAndReplaced;
  }

  _TopLevelIncludeReplacer(this._include, this._newRules);

  @override
  void visitStyleSheet(StyleSheet node) {
    var index = node.topLevels.indexOf(_include);
    if (index != -1) {
      node.topLevels.insertAll(index + 1, _newRules);
      node.topLevels.replaceRange(index, index + 1, [NoOp()]);
      _foundAndReplaced = true;
    }
    super.visitStyleSheet(node);
  }

  @override
  void visitMixinRulesetDirective(MixinRulesetDirective node) {
    var index = node.rulesets.indexOf(_include);
    if (index != -1) {
      node.rulesets.insertAll(index + 1, _newRules);
      node.rulesets.replaceRange(index, index + 1, [NoOp()]);
      _foundAndReplaced = true;
    }
    super.visitMixinRulesetDirective(node);
  }
}

int _findInclude(List list, TreeNode node) {
  final matchNode = (node is IncludeMixinAtDeclaration)
      ? node.include
      : node as IncludeDirective;

  var index = 0;
  for (var item in list) {
    var includeNode = (item is IncludeMixinAtDeclaration) ? item.include : item;
    if (includeNode == matchNode) return index;
    index++;
  }
  return -1;
}

class CallMixin extends Visitor {
  final MixinDefinition mixinDef;
  List? _definedArgs;
  Expressions? _currExpressions;
  int _currIndex = -1;

  final varUsages = <String, Map<Expressions, Set<int>>>{};

  final Map<String, VarDefinition>? varDefs;

  CallMixin(this.mixinDef, [this.varDefs]) {
    if (mixinDef is MixinRulesetDirective) {
      visitMixinRulesetDirective(mixinDef as MixinRulesetDirective);
    } else {
      visitMixinDeclarationDirective(mixinDef as MixinDeclarationDirective);
    }
  }

  MixinDefinition transform(List<List<Expression>> callArgs) {
    for (var index = 0; index < _definedArgs!.length; index++) {
      var definedArg = _definedArgs![index];
      VarDefinition? varDef;
      if (definedArg is VarDefinition) {
        varDef = definedArg;
      } else if (definedArg is VarDefinitionDirective) {
        var varDirective = definedArg;
        varDef = varDirective.def;
      }
      var callArg = callArgs[index];

      var defArgs = _varDefsAsCallArgs(callArg);
      if (defArgs.isNotEmpty) {
        callArgs.insertAll(index, defArgs);
        callArgs.removeAt(index + defArgs.length);
        callArg = callArgs[index];
      }

      var expressions = varUsages[varDef!.definedName];
      expressions!.forEach((k, v) {
        for (var usagesIndex in v) {
          k.expressions.replaceRange(usagesIndex, usagesIndex + 1, callArg);
        }
      });
    }

    return mixinDef.clone();
  }

  List<List<Expression>> _varDefsAsCallArgs(var callArg) {
    var defArgs = <List<Expression>>[];
    if (callArg is List) {
      var firstCallArg = callArg[0];
      if (firstCallArg is VarUsage) {
        var varDef = varDefs![firstCallArg.name];
        var expressions = (varDef!.expression as Expressions).expressions;
        assert(expressions.length > 1);
        for (var expr in expressions) {
          if (expr is! OperatorComma) {
            defArgs.add([expr]);
          }
        }
      }
    }
    return defArgs;
  }

  @override
  void visitExpressions(Expressions node) {
    var oldExpressions = _currExpressions;
    var oldIndex = _currIndex;

    _currExpressions = node;
    for (_currIndex = 0; _currIndex < node.expressions.length; _currIndex++) {
      node.expressions[_currIndex].visit(this);
    }

    _currIndex = oldIndex;
    _currExpressions = oldExpressions;
  }

  void _addExpression(Map<Expressions, Set<int>> expressions) {
    var indexSet = <int>{};
    indexSet.add(_currIndex);
    expressions[_currExpressions!] = indexSet;
  }

  @override
  void visitVarUsage(VarUsage node) {
    assert(_currIndex != -1);
    assert(_currExpressions != null);
    if (varUsages.containsKey(node.name)) {
      var expressions = varUsages[node.name];
      var allIndexes = expressions![_currExpressions];
      if (allIndexes == null) {
        _addExpression(expressions);
      } else {
        allIndexes.add(_currIndex);
      }
    } else {
      var newExpressions = <Expressions, Set<int>>{};
      _addExpression(newExpressions);
      varUsages[node.name] = newExpressions;
    }
    super.visitVarUsage(node);
  }

  @override
  void visitMixinDeclarationDirective(MixinDeclarationDirective node) {
    _definedArgs = node.definedArgs;
    super.visitMixinDeclarationDirective(node);
  }

  @override
  void visitMixinRulesetDirective(MixinRulesetDirective node) {
    _definedArgs = node.definedArgs;
    super.visitMixinRulesetDirective(node);
  }
}

class DeclarationIncludes extends Visitor {
  StyleSheet? _styleSheet;
  final Messages _messages;

  final Map<String, MixinDefinition> map = <String, MixinDefinition>{};

  final Map<String, CallMixin> callMap = <String, CallMixin>{};
  MixinDefinition? currDef;
  DeclarationGroup? currDeclGroup;

  final varDefs = <String, VarDefinition>{};

  static void expand(Messages messages, List<StyleSheet> styleSheets) {
    DeclarationIncludes(messages, styleSheets);
  }

  DeclarationIncludes(this._messages, List<StyleSheet> styleSheets) {
    for (var styleSheet in styleSheets) {
      visitTree(styleSheet);
    }
  }

  bool _allIncludes(List<TreeNode> rulesets) =>
      rulesets.every((rule) => rule is IncludeDirective || rule is NoOp);

  CallMixin _createCallDeclMixin(MixinDefinition mixinDef) =>
      callMap[mixinDef.name] ??= CallMixin(mixinDef, varDefs);

  @override
  void visitStyleSheet(StyleSheet ss) {
    _styleSheet = ss;
    super.visitStyleSheet(ss);
    _styleSheet = null;
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    currDeclGroup = node;
    super.visitDeclarationGroup(node);
    currDeclGroup = null;
  }

  @override
  void visitIncludeMixinAtDeclaration(IncludeMixinAtDeclaration node) {
    if (map.containsKey(node.include.name)) {
      var mixinDef = map[node.include.name];

      if (mixinDef is MixinRulesetDirective) {
        if (!_allIncludes(mixinDef.rulesets) && currDeclGroup != null) {
          var index = _findInclude(currDeclGroup!.declarations, node);
          if (index != -1) {
            currDeclGroup!.declarations
                .replaceRange(index, index + 1, [NoOp()]);
          }
          _messages.warning(
              'Using top-level mixin ${node.include.name} as a declaration',
              node.span);
        } else {
          var origRulesets = mixinDef.rulesets;
          var rulesets = <Declaration>[];
          if (origRulesets.every((ruleset) => ruleset is IncludeDirective)) {
            origRulesets.forEach((ruleset) {
              rulesets.add(IncludeMixinAtDeclaration(
                  ruleset as IncludeDirective, ruleset.span));
            });
            _IncludeReplacer.replace(_styleSheet!, node, rulesets);
          }
        }
      }

      if (mixinDef!.definedArgs.isNotEmpty && node.include.args.isNotEmpty) {
        var callMixin = _createCallDeclMixin(mixinDef);
        mixinDef = callMixin.transform(node.include.args);
      }

      if (mixinDef is MixinDeclarationDirective) {
        _IncludeReplacer.replace(
            _styleSheet!, node, mixinDef.declarations.declarations);
      }
    } else {
      _messages.warning('Undefined mixin ${node.include.name}', node.span);
    }

    super.visitIncludeMixinAtDeclaration(node);
  }

  @override
  void visitIncludeDirective(IncludeDirective node) {
    if (map.containsKey(node.name)) {
      var mixinDef = map[node.name];
      if (currDef is MixinDeclarationDirective &&
          mixinDef is MixinDeclarationDirective) {
        _IncludeReplacer.replace(
            _styleSheet!, node, mixinDef.declarations.declarations);
      } else if (currDef is MixinDeclarationDirective) {
        var decls =
            (currDef as MixinDeclarationDirective).declarations.declarations;
        var index = _findInclude(decls, node);
        if (index != -1) {
          decls.replaceRange(index, index + 1, [NoOp()]);
        }
      }
    }

    super.visitIncludeDirective(node);
  }

  @override
  void visitMixinRulesetDirective(MixinRulesetDirective node) {
    currDef = node;

    super.visitMixinRulesetDirective(node);

    map[node.name] = node;
    currDef = null;
  }

  @override
  void visitMixinDeclarationDirective(MixinDeclarationDirective node) {
    currDef = node;

    super.visitMixinDeclarationDirective(node);

    map[node.name] = node;
    currDef = null;
  }

  @override
  void visitVarDefinition(VarDefinition node) {
    var exprs = (node.expression as Expressions).expressions;
    if (exprs.length > 1) {
      varDefs[node.definedName] = node;
    }
    super.visitVarDefinition(node);
  }

  @override
  void visitVarDefinitionDirective(VarDefinitionDirective node) {
    visitVarDefinition(node.def);
  }
}

class _IncludeReplacer extends Visitor {
  final TreeNode _include;
  final List<TreeNode> _newDeclarations;

  static void replace(
      StyleSheet ss, TreeNode include, List<TreeNode> newDeclarations) {
    var visitor = _IncludeReplacer(include, newDeclarations);
    visitor.visitStyleSheet(ss);
  }

  _IncludeReplacer(this._include, this._newDeclarations);

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    var index = _findInclude(node.declarations, _include);
    if (index != -1) {
      node.declarations.insertAll(index + 1, _newDeclarations);
      node.declarations.replaceRange(index, index + 1, [NoOp()]);
    }
    super.visitDeclarationGroup(node);
  }
}

class MixinsAndIncludes extends Visitor {
  static void remove(StyleSheet styleSheet) {
    MixinsAndIncludes().visitStyleSheet(styleSheet);
  }

  bool _nodesToRemove(node) =>
      node is IncludeDirective || node is MixinDefinition || node is NoOp;

  @override
  void visitStyleSheet(StyleSheet ss) {
    var index = ss.topLevels.length;
    while (--index >= 0) {
      if (_nodesToRemove(ss.topLevels[index])) {
        ss.topLevels.removeAt(index);
      }
    }
    super.visitStyleSheet(ss);
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    var index = node.declarations.length;
    while (--index >= 0) {
      if (_nodesToRemove(node.declarations[index])) {
        node.declarations.removeAt(index);
      }
    }
    super.visitDeclarationGroup(node);
  }
}

class AllExtends extends Visitor {
  final inherits = <String, List<SelectorGroup>>{};

  SelectorGroup? _currSelectorGroup;
  int? _currDeclIndex;
  final _extendsToRemove = <int>[];

  @override
  void visitRuleSet(RuleSet node) {
    var oldSelectorGroup = _currSelectorGroup;
    _currSelectorGroup = node.selectorGroup;

    super.visitRuleSet(node);

    _currSelectorGroup = oldSelectorGroup;
  }

  @override
  void visitExtendDeclaration(ExtendDeclaration node) {
    var inheritName = '';
    for (var selector in node.selectors) {
      inheritName += selector.toString();
    }
    if (inherits.containsKey(inheritName)) {
      inherits[inheritName]!.add(_currSelectorGroup!);
    } else {
      inherits[inheritName] = [_currSelectorGroup!];
    }

    _extendsToRemove.add(_currDeclIndex!);

    super.visitExtendDeclaration(node);
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    var oldDeclIndex = _currDeclIndex;

    var decls = node.declarations;
    for (_currDeclIndex = 0;
        _currDeclIndex! < decls.length;
        _currDeclIndex = _currDeclIndex! + 1) {
      decls[_currDeclIndex!].visit(this);
    }

    if (_extendsToRemove.isNotEmpty) {
      var removeTotal = _extendsToRemove.length - 1;
      for (var index = removeTotal; index >= 0; index--) {
        decls.removeAt(_extendsToRemove[index]);
      }
      _extendsToRemove.clear();
    }

    _currDeclIndex = oldDeclIndex;
  }
}

class InheritExtends extends Visitor {
  final AllExtends _allExtends;

  InheritExtends(Messages messages, this._allExtends);

  @override
  void visitSelectorGroup(SelectorGroup node) {
    for (var selectorsIndex = 0;
        selectorsIndex < node.selectors.length;
        selectorsIndex++) {
      var selectors = node.selectors[selectorsIndex];
      var isLastNone = false;
      var selectorName = '';
      for (var index = 0;
          index < selectors.simpleSelectorSequences.length;
          index++) {
        var simpleSeq = selectors.simpleSelectorSequences[index];
        var namePart = simpleSeq.simpleSelector.toString();
        selectorName = (isLastNone) ? (selectorName + namePart) : namePart;
        var matches = _allExtends.inherits[selectorName];
        if (matches != null) {
          for (var match in matches) {
            var newSelectors = selectors.clone();
            var newSeq = match.selectors[0].clone();
            if (isLastNone) {
              node.selectors.add(newSeq);
            } else {
              var orgCombinator =
                  newSelectors.simpleSelectorSequences[index].combinator;
              newSeq.simpleSelectorSequences[0].combinator = orgCombinator;

              newSelectors.simpleSelectorSequences.replaceRange(
                  index, index + 1, newSeq.simpleSelectorSequences);
              node.selectors.add(newSelectors);
            }
            isLastNone = false;
          }
        } else {
          isLastNone = simpleSeq.isCombinatorNone;
        }
      }
    }
    super.visitSelectorGroup(node);
  }
}