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
      AllExtends allExtends = AllExtends()..visitStyleSheet(styleSheet);
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

    SelectorGroup? oldNestedSelectorGroups = _nestedSelectorGroup;

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
    List<Selector> nestedSelectors = _nestedSelectorGroup!.selectors;
    List<Selector> selectors = node.selectorGroup!.selectors;

    List<Selector> newSelectors = <Selector>[];
    for (Selector selector in selectors) {
      for (Selector nestedSelector in nestedSelectors) {
        List<SimpleSelectorSequence> seq = _mergeNestedSelector(
            nestedSelector.simpleSelectorSequences,
            selector.simpleSelectorSequences);
        newSelectors.add(Selector(seq, node.span));
      }
    }

    return SelectorGroup(newSelectors, node.span);
  }

  List<SimpleSelectorSequence> _mergeNestedSelector(
      List<SimpleSelectorSequence> parent,
      List<SimpleSelectorSequence> current) {
    bool hasThis = current.any((s) => s.simpleSelector.isThis);

    List<SimpleSelectorSequence> newSequence = <SimpleSelectorSequence>[];

    if (!hasThis) {
      newSequence.addAll(parent);
      newSequence.addAll(_convertToDescendentSequence(current));
    } else {
      for (SimpleSelectorSequence sequence in current) {
        if (sequence.simpleSelector.isThis) {
          bool hasPrefix = newSequence.isNotEmpty &&
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

    List<SimpleSelectorSequence> newSequences = <SimpleSelectorSequence>[];
    SimpleSelectorSequence first = sequences.first;
    newSequences.add(SimpleSelectorSequence(
        first.simpleSelector, first.span, TokenKind.COMBINATOR_DESCENDANT));
    newSequences.addAll(sequences.skip(1));

    return newSequences;
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    SourceSpan span = node.span;

    DeclarationGroup currentGroup = DeclarationGroup([], span);

    DeclarationGroup? oldGroup = _flatDeclarationGroup;
    _flatDeclarationGroup = currentGroup;

    int expandedLength = _expandedRuleSets.length;

    super.visitDeclarationGroup(node);

    _flatDeclarationGroup = oldGroup;

    if (_nestedSelectorGroup == _topLevelSelectorGroup) return;

    if (currentGroup.declarations.isEmpty) return;

    SelectorGroup? selectorGroup = _nestedSelectorGroup;

    RuleSet newRuleSet = RuleSet(selectorGroup, currentGroup, span);

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
      int index = styleSheet.topLevels.indexOf(ruleSet);
      if (index == -1) {
        bool found = _MediaRulesReplacer.replace(styleSheet, ruleSet, newRules);
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
    _MediaRulesReplacer visitor = _MediaRulesReplacer(ruleSet, newRules);
    visitor.visitStyleSheet(styleSheet);
    return visitor._foundAndReplaced;
  }

  _MediaRulesReplacer(this._ruleSet, this._newRules);

  @override
  void visitMediaDirective(MediaDirective node) {
    int index = node.rules.indexOf(_ruleSet);
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
    for (StyleSheet styleSheet in styleSheets) {
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
      MixinDefinition? mixinDef = map[node.name];
      if (mixinDef is MixinRulesetDirective) {
        _TopLevelIncludeReplacer.replace(
            _messages, _styleSheet!, node, mixinDef.rulesets);
      } else if (currDef is MixinRulesetDirective && _anyRulesets(currDef)) {
        final mixinRuleset = currDef;
        int index = mixinRuleset.rulesets.indexOf(node);
        mixinRuleset.rulesets.removeAt(index);
        _messages.warning(
            'Using declaration mixin ${node.name} as top-level mixin',
            node.span);
      }
    } else {
      if (currDef is MixinRulesetDirective) {
        MixinRulesetDirective rulesetDirect = currDef;
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
    _TopLevelIncludeReplacer visitor =
        _TopLevelIncludeReplacer(include, newRules);
    visitor.visitStyleSheet(styleSheet);
    return visitor._foundAndReplaced;
  }

  _TopLevelIncludeReplacer(this._include, this._newRules);

  @override
  void visitStyleSheet(StyleSheet node) {
    int index = node.topLevels.indexOf(_include);
    if (index != -1) {
      node.topLevels.insertAll(index + 1, _newRules);
      node.topLevels.replaceRange(index, index + 1, [NoOp()]);
      _foundAndReplaced = true;
    }
    super.visitStyleSheet(node);
  }

  @override
  void visitMixinRulesetDirective(MixinRulesetDirective node) {
    int index = node.rulesets.indexOf(_include);
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

  int index = 0;
  for (dynamic item in list) {
    dynamic includeNode =
        (item is IncludeMixinAtDeclaration) ? item.include : item;
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
    for (int index = 0; index < _definedArgs!.length; index++) {
      dynamic definedArg = _definedArgs![index];
      VarDefinition? varDef;
      if (definedArg is VarDefinition) {
        varDef = definedArg;
      } else if (definedArg is VarDefinitionDirective) {
        VarDefinitionDirective varDirective = definedArg;
        varDef = varDirective.def;
      }
      List<Expression> callArg = callArgs[index];

      List<List<Expression>> defArgs = _varDefsAsCallArgs(callArg);
      if (defArgs.isNotEmpty) {
        callArgs.insertAll(index, defArgs);
        callArgs.removeAt(index + defArgs.length);
        callArg = callArgs[index];
      }

      Map<Expressions, Set<int>>? expressions = varUsages[varDef!.definedName];
      expressions!.forEach((k, v) {
        for (int usagesIndex in v) {
          k.expressions.replaceRange(usagesIndex, usagesIndex + 1, callArg);
        }
      });
    }

    return mixinDef.clone();
  }

  List<List<Expression>> _varDefsAsCallArgs(dynamic callArg) {
    List<List<Expression>> defArgs = <List<Expression>>[];
    if (callArg is List) {
      dynamic firstCallArg = callArg[0];
      if (firstCallArg is VarUsage) {
        VarDefinition? varDef = varDefs![firstCallArg.name];
        List<Expression> expressions =
            (varDef!.expression as Expressions).expressions;
        assert(expressions.length > 1);
        for (Expression expr in expressions) {
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
    Expressions? oldExpressions = _currExpressions;
    int oldIndex = _currIndex;

    _currExpressions = node;
    for (_currIndex = 0; _currIndex < node.expressions.length; _currIndex++) {
      node.expressions[_currIndex].visit(this);
    }

    _currIndex = oldIndex;
    _currExpressions = oldExpressions;
  }

  void _addExpression(Map<Expressions, Set<int>> expressions) {
    Set<int> indexSet = <int>{};
    indexSet.add(_currIndex);
    expressions[_currExpressions!] = indexSet;
  }

  @override
  void visitVarUsage(VarUsage node) {
    assert(_currIndex != -1);
    assert(_currExpressions != null);
    if (varUsages.containsKey(node.name)) {
      Map<Expressions, Set<int>>? expressions = varUsages[node.name];
      Set<int>? allIndexes = expressions![_currExpressions];
      if (allIndexes == null) {
        _addExpression(expressions);
      } else {
        allIndexes.add(_currIndex);
      }
    } else {
      Map<Expressions, Set<int>> newExpressions = <Expressions, Set<int>>{};
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
    for (StyleSheet styleSheet in styleSheets) {
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
      MixinDefinition? mixinDef = map[node.include.name];

      if (mixinDef is MixinRulesetDirective) {
        if (!_allIncludes(mixinDef.rulesets) && currDeclGroup != null) {
          int index = _findInclude(currDeclGroup!.declarations, node);
          if (index != -1) {
            currDeclGroup!.declarations
                .replaceRange(index, index + 1, [NoOp()]);
          }
          _messages.warning(
              'Using top-level mixin ${node.include.name} as a declaration',
              node.span);
        } else {
          List<TreeNode> origRulesets = mixinDef.rulesets;
          List<Declaration> rulesets = <Declaration>[];
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
        CallMixin callMixin = _createCallDeclMixin(mixinDef);
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
      MixinDefinition? mixinDef = map[node.name];
      if (currDef is MixinDeclarationDirective &&
          mixinDef is MixinDeclarationDirective) {
        _IncludeReplacer.replace(
            _styleSheet!, node, mixinDef.declarations.declarations);
      } else if (currDef is MixinDeclarationDirective) {
        List<TreeNode> decls =
            (currDef as MixinDeclarationDirective).declarations.declarations;
        int index = _findInclude(decls, node);
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
    List<Expression> exprs = (node.expression as Expressions).expressions;
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
    _IncludeReplacer visitor = _IncludeReplacer(include, newDeclarations);
    visitor.visitStyleSheet(ss);
  }

  _IncludeReplacer(this._include, this._newDeclarations);

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    int index = _findInclude(node.declarations, _include);
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
    int index = ss.topLevels.length;
    while (--index >= 0) {
      if (_nodesToRemove(ss.topLevels[index])) {
        ss.topLevels.removeAt(index);
      }
    }
    super.visitStyleSheet(ss);
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    int index = node.declarations.length;
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
    SelectorGroup? oldSelectorGroup = _currSelectorGroup;
    _currSelectorGroup = node.selectorGroup;

    super.visitRuleSet(node);

    _currSelectorGroup = oldSelectorGroup;
  }

  @override
  void visitExtendDeclaration(ExtendDeclaration node) {
    String inheritName = '';
    for (TreeNode selector in node.selectors) {
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
    int? oldDeclIndex = _currDeclIndex;

    List<TreeNode> decls = node.declarations;
    for (_currDeclIndex = 0;
        _currDeclIndex! < decls.length;
        _currDeclIndex = _currDeclIndex! + 1) {
      decls[_currDeclIndex!].visit(this);
    }

    if (_extendsToRemove.isNotEmpty) {
      int removeTotal = _extendsToRemove.length - 1;
      for (int index = removeTotal; index >= 0; index--) {
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
    for (int selectorsIndex = 0;
        selectorsIndex < node.selectors.length;
        selectorsIndex++) {
      Selector selectors = node.selectors[selectorsIndex];
      bool isLastNone = false;
      String selectorName = '';
      for (int index = 0;
          index < selectors.simpleSelectorSequences.length;
          index++) {
        SimpleSelectorSequence simpleSeq =
            selectors.simpleSelectorSequences[index];
        String namePart = simpleSeq.simpleSelector.toString();
        selectorName = (isLastNone) ? (selectorName + namePart) : namePart;
        List<SelectorGroup>? matches = _allExtends.inherits[selectorName];
        if (matches != null) {
          for (SelectorGroup match in matches) {
            Selector newSelectors = selectors.clone();
            Selector newSeq = match.selectors[0].clone();
            if (isLastNone) {
              node.selectors.add(newSeq);
            } else {
              int orgCombinator =
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
