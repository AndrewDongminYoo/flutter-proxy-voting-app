// ignore_for_file: avoid_function_literals_in_foreach_calls

part of '../parser.dart';

class Analyzer {
  final List<CssStyleSheet> _styleSheets;
  final CssMessages _messages;

  Analyzer(this._styleSheets, this._messages);

  void run() {
    _styleSheets.forEach((CssStyleSheet styleSheet) =>
        TopLevelIncludes.expand(_messages, _styleSheets));

    _styleSheets.forEach((CssStyleSheet styleSheet) =>
        DeclarationIncludes.expand(_messages, _styleSheets));

    _styleSheets.forEach(
        (CssStyleSheet styleSheet) => MixinsAndIncludes.remove(styleSheet));

    _styleSheets.forEach((CssStyleSheet styleSheet) => ExpandNestedSelectors()
      ..visitStyleSheet(styleSheet)
      ..flatten(styleSheet));

    _styleSheets.forEach((CssStyleSheet styleSheet) {
      AllExtends allExtends = AllExtends()..visitStyleSheet(styleSheet);
      InheritExtends(_messages, allExtends).visitStyleSheet(styleSheet);
    });
  }
}

class ExpandNestedSelectors extends Visitor {
  CssRuleSet? _parentRuleSet;

  CssSelectorGroup? _topLevelSelectorGroup;

  CssSelectorGroup? _nestedSelectorGroup;

  DeclarationGroup? _flatDeclarationGroup;

  List<CssRuleSet> _expandedRuleSets = [];

  final Map<CssRuleSet, List<CssRuleSet>> _expansions =
      <CssRuleSet, List<CssRuleSet>>{};

  @override
  void visitRuleSet(CssRuleSet node) {
    final CssRuleSet? oldParent = _parentRuleSet;

    CssSelectorGroup? oldNestedSelectorGroups = _nestedSelectorGroup;

    if (_nestedSelectorGroup == null) {
      final List<CssSelector> newSelectors =
          node.selectorGroup!.selectors.toList();
      _topLevelSelectorGroup = CssSelectorGroup(newSelectors, node.span);
      _nestedSelectorGroup = _topLevelSelectorGroup;
    } else {
      _nestedSelectorGroup = _mergeToFlatten(node);
    }

    _parentRuleSet = node;

    super.visitRuleSet(node);

    _parentRuleSet = oldParent;

    node.declarationGroup.declarations
        .removeWhere((declaration) => declaration is CssRuleSet);

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

  CssSelectorGroup _mergeToFlatten(CssRuleSet node) {
    List<CssSelector> nestedSelectors = _nestedSelectorGroup!.selectors;
    List<CssSelector> selectors = node.selectorGroup!.selectors;

    List<CssSelector> newSelectors = <CssSelector>[];
    for (CssSelector selector in selectors) {
      for (CssSelector nestedSelector in nestedSelectors) {
        List<CssSimpleSelectorSequence> seq = _mergeNestedSelector(
            nestedSelector.simpleSelectorSequences,
            selector.simpleSelectorSequences);
        newSelectors.add(CssSelector(seq, node.span));
      }
    }

    return CssSelectorGroup(newSelectors, node.span);
  }

  List<CssSimpleSelectorSequence> _mergeNestedSelector(
      List<CssSimpleSelectorSequence> parent,
      List<CssSimpleSelectorSequence> current) {
    bool hasThis = current.any((s) => s.simpleSelector.isThis);

    List<CssSimpleSelectorSequence> newSequence = <CssSimpleSelectorSequence>[];

    if (!hasThis) {
      newSequence.addAll(parent);
      newSequence.addAll(_convertToDescendentSequence(current));
    } else {
      for (CssSimpleSelectorSequence sequence in current) {
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

  List<CssSimpleSelectorSequence> _convertToDescendentSequence(
      List<CssSimpleSelectorSequence> sequences) {
    if (sequences.isEmpty) return sequences;

    List<CssSimpleSelectorSequence> newSequences =
        <CssSimpleSelectorSequence>[];
    CssSimpleSelectorSequence first = sequences.first;
    newSequences.add(CssSimpleSelectorSequence(
        first.simpleSelector, first.span, CssTokenKind.COMBINATOR_DESCENDANT));
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

    CssSelectorGroup? selectorGroup = _nestedSelectorGroup;

    CssRuleSet newRuleSet = CssRuleSet(selectorGroup, currentGroup, span);

    if (expandedLength == _expandedRuleSets.length) {
      _expandedRuleSets.add(newRuleSet);
    } else {
      _expandedRuleSets.insert(expandedLength, newRuleSet);
    }
  }

  @override
  void visitDeclaration(CssDeclaration node) {
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
  void visitExtendDeclaration(CssExtendDeclaration node) {
    if (_parentRuleSet != null) {
      _flatDeclarationGroup!.declarations.add(node);
    }
    super.visitExtendDeclaration(node);
  }

  @override
  void visitMarginGroup(CssMarginGroup node) {
    if (_parentRuleSet != null) {
      _flatDeclarationGroup!.declarations.add(node);
    }
    super.visitMarginGroup(node);
  }

  void flatten(CssStyleSheet styleSheet) {
    _expansions.forEach((CssRuleSet ruleSet, List<CssRuleSet> newRules) {
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
  final CssRuleSet _ruleSet;
  final List<CssRuleSet> _newRules;
  bool _foundAndReplaced = false;

  static bool replace(
      CssStyleSheet styleSheet, CssRuleSet ruleSet, List<CssRuleSet> newRules) {
    _MediaRulesReplacer visitor = _MediaRulesReplacer(ruleSet, newRules);
    visitor.visitStyleSheet(styleSheet);
    return visitor._foundAndReplaced;
  }

  _MediaRulesReplacer(this._ruleSet, this._newRules);

  @override
  void visitMediaDirective(CssMediaDirective node) {
    int index = node.rules.indexOf(_ruleSet);
    if (index != -1) {
      node.rules.insertAll(index + 1, _newRules);
      _foundAndReplaced = true;
    }
  }
}

class TopLevelIncludes extends Visitor {
  CssStyleSheet? _styleSheet;
  final CssMessages _messages;

  final Map<dynamic, dynamic> map = <String, CssMixinDefinition>{};
  CssMixinDefinition? currDef;

  static void expand(CssMessages messages, List<CssStyleSheet> styleSheets) {
    TopLevelIncludes(messages, styleSheets);
  }

  bool _anyRulesets(CssMixinRulesetDirective def) =>
      def.rulesets.any((rule) => rule is CssRuleSet);

  TopLevelIncludes(this._messages, List<CssStyleSheet> styleSheets) {
    for (CssStyleSheet styleSheet in styleSheets) {
      visitTree(styleSheet);
    }
  }

  @override
  void visitStyleSheet(CssStyleSheet ss) {
    _styleSheet = ss;
    super.visitStyleSheet(ss);
    _styleSheet = null;
  }

  @override
  void visitIncludeDirective(IncludeDirective node) {
    final CssMixinDefinition? currDef = this.currDef;
    if (map.containsKey(node.name)) {
      CssMixinDefinition? mixinDef = map[node.name];
      if (mixinDef is CssMixinRulesetDirective) {
        _TopLevelIncludeReplacer.replace(
            _messages, _styleSheet!, node, mixinDef.rulesets);
      } else if (currDef is CssMixinRulesetDirective && _anyRulesets(currDef)) {
        final CssMixinRulesetDirective mixinRuleset = currDef;
        int index = mixinRuleset.rulesets.indexOf(node);
        mixinRuleset.rulesets.removeAt(index);
        _messages.warning(
            'Using declaration mixin ${node.name} as top-level mixin',
            node.span);
      }
    } else {
      if (currDef is CssMixinRulesetDirective) {
        CssMixinRulesetDirective rulesetDirect = currDef;
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
  void visitMixinRulesetDirective(CssMixinRulesetDirective node) {
    currDef = node;

    super.visitMixinRulesetDirective(node);

    map[node.name] = node;
    currDef = null;
  }

  @override
  void visitMixinDeclarationDirective(CssMixinDeclarationDirective node) {
    currDef = node;

    super.visitMixinDeclarationDirective(node);

    map[node.name] = node;
    currDef = null;
  }
}

class _TopLevelIncludeReplacer extends Visitor {
  final IncludeDirective _include;
  final List<CssTreeNode> _newRules;
  bool _foundAndReplaced = false;

  static bool replace(CssMessages messages, CssStyleSheet styleSheet,
      IncludeDirective include, List<CssTreeNode> newRules) {
    _TopLevelIncludeReplacer visitor =
        _TopLevelIncludeReplacer(include, newRules);
    visitor.visitStyleSheet(styleSheet);
    return visitor._foundAndReplaced;
  }

  _TopLevelIncludeReplacer(this._include, this._newRules);

  @override
  void visitStyleSheet(CssStyleSheet node) {
    int index = node.topLevels.indexOf(_include);
    if (index != -1) {
      node.topLevels.insertAll(index + 1, _newRules);
      node.topLevels.replaceRange(index, index + 1, [CssNoOp()]);
      _foundAndReplaced = true;
    }
    super.visitStyleSheet(node);
  }

  @override
  void visitMixinRulesetDirective(CssMixinRulesetDirective node) {
    int index = node.rulesets.indexOf(_include);
    if (index != -1) {
      node.rulesets.insertAll(index + 1, _newRules);
      node.rulesets.replaceRange(index, index + 1, [CssNoOp()]);
      _foundAndReplaced = true;
    }
    super.visitMixinRulesetDirective(node);
  }
}

int _findInclude(List<dynamic> list, CssTreeNode node) {
  final IncludeDirective matchNode = (node is CssIncludeMixinAtDeclaration)
      ? node.include
      : node as IncludeDirective;

  int index = 0;
  for (dynamic item in list) {
    dynamic includeNode =
        (item is CssIncludeMixinAtDeclaration) ? item.include : item;
    if (includeNode == matchNode) return index;
    index++;
  }
  return -1;
}

class CallMixin extends Visitor {
  final CssMixinDefinition mixinDef;
  List<dynamic>? _definedArgs;
  CssExpressions? _currExpressions;
  int _currIndex = -1;

  final Map<dynamic, dynamic> varUsages =
      <String, Map<CssExpressions, Set<int>>>{};

  final Map<String, VarDefinition>? varDefs;

  CallMixin(this.mixinDef, [this.varDefs]) {
    if (mixinDef is CssMixinRulesetDirective) {
      visitMixinRulesetDirective(mixinDef as CssMixinRulesetDirective);
    } else {
      visitMixinDeclarationDirective(mixinDef as CssMixinDeclarationDirective);
    }
  }

  CssMixinDefinition transform(List<List<CssExpression>> callArgs) {
    for (int index = 0; index < _definedArgs!.length; index++) {
      dynamic definedArg = _definedArgs![index];
      VarDefinition? varDef;
      if (definedArg is VarDefinition) {
        varDef = definedArg;
      } else if (definedArg is CssVarDefinitionDirective) {
        CssVarDefinitionDirective varDirective = definedArg;
        varDef = varDirective.def;
      }
      List<CssExpression> callArg = callArgs[index];

      List<List<CssExpression>> defArgs = _varDefsAsCallArgs(callArg);
      if (defArgs.isNotEmpty) {
        callArgs.insertAll(index, defArgs);
        callArgs.removeAt(index + defArgs.length);
        callArg = callArgs[index];
      }

      Map<CssExpressions, Set<int>>? expressions =
          varUsages[varDef!.definedName];
      expressions!.forEach((CssExpressions k, Set<int> v) {
        for (int usagesIndex in v) {
          k.expressions.replaceRange(usagesIndex, usagesIndex + 1, callArg);
        }
      });
    }

    return mixinDef.clone();
  }

  List<List<CssExpression>> _varDefsAsCallArgs(dynamic callArg) {
    List<List<CssExpression>> defArgs = <List<CssExpression>>[];
    if (callArg is List) {
      dynamic firstCallArg = callArg[0];
      if (firstCallArg is CssVarUsage) {
        VarDefinition? varDef = varDefs![firstCallArg.name];
        List<CssExpression> expressions =
            (varDef!.expression as CssExpressions).expressions;
        assert(expressions.length > 1);
        for (CssExpression expr in expressions) {
          if (expr is! CssOperatorComma) {
            defArgs.add([expr]);
          }
        }
      }
    }
    return defArgs;
  }

  @override
  void visitExpressions(CssExpressions node) {
    CssExpressions? oldExpressions = _currExpressions;
    int oldIndex = _currIndex;

    _currExpressions = node;
    for (_currIndex = 0; _currIndex < node.expressions.length; _currIndex++) {
      node.expressions[_currIndex].visit(this);
    }

    _currIndex = oldIndex;
    _currExpressions = oldExpressions;
  }

  void _addExpression(Map<CssExpressions, Set<int>> expressions) {
    Set<int> indexSet = <int>{};
    indexSet.add(_currIndex);
    expressions[_currExpressions!] = indexSet;
  }

  @override
  void visitVarUsage(CssVarUsage node) {
    assert(_currIndex != -1);
    assert(_currExpressions != null);
    if (varUsages.containsKey(node.name)) {
      Map<CssExpressions, Set<int>>? expressions = varUsages[node.name];
      Set<int>? allIndexes = expressions![_currExpressions];
      if (allIndexes == null) {
        _addExpression(expressions);
      } else {
        allIndexes.add(_currIndex);
      }
    } else {
      Map<CssExpressions, Set<int>> newExpressions =
          <CssExpressions, Set<int>>{};
      _addExpression(newExpressions);
      varUsages[node.name] = newExpressions;
    }
    super.visitVarUsage(node);
  }

  @override
  void visitMixinDeclarationDirective(CssMixinDeclarationDirective node) {
    _definedArgs = node.definedArgs;
    super.visitMixinDeclarationDirective(node);
  }

  @override
  void visitMixinRulesetDirective(CssMixinRulesetDirective node) {
    _definedArgs = node.definedArgs;
    super.visitMixinRulesetDirective(node);
  }
}

class DeclarationIncludes extends Visitor {
  CssStyleSheet? _styleSheet;
  final CssMessages _messages;

  final Map<String, CssMixinDefinition> map = <String, CssMixinDefinition>{};

  final Map<String, CallMixin> callMap = <String, CallMixin>{};
  CssMixinDefinition? currDef;
  DeclarationGroup? currDeclGroup;

  final Map<String, VarDefinition> varDefs = <String, VarDefinition>{};

  static void expand(CssMessages messages, List<CssStyleSheet> styleSheets) {
    DeclarationIncludes(messages, styleSheets);
  }

  DeclarationIncludes(this._messages, List<CssStyleSheet> styleSheets) {
    for (CssStyleSheet styleSheet in styleSheets) {
      visitTree(styleSheet);
    }
  }

  bool _allIncludes(List<CssTreeNode> rulesets) =>
      rulesets.every((rule) => rule is IncludeDirective || rule is CssNoOp);

  CallMixin _createCallDeclMixin(CssMixinDefinition mixinDef) =>
      callMap[mixinDef.name] ??= CallMixin(mixinDef, varDefs);

  @override
  void visitStyleSheet(CssStyleSheet ss) {
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
  void visitIncludeMixinAtDeclaration(CssIncludeMixinAtDeclaration node) {
    if (map.containsKey(node.include.name)) {
      CssMixinDefinition? mixinDef = map[node.include.name];

      if (mixinDef is CssMixinRulesetDirective) {
        if (!_allIncludes(mixinDef.rulesets) && currDeclGroup != null) {
          int index = _findInclude(currDeclGroup!.declarations, node);
          if (index != -1) {
            currDeclGroup!.declarations
                .replaceRange(index, index + 1, [CssNoOp()]);
          }
          _messages.warning(
              'Using top-level mixin ${node.include.name} as a declaration',
              node.span);
        } else {
          List<CssTreeNode> origRulesets = mixinDef.rulesets;
          List<CssDeclaration> rulesets = <CssDeclaration>[];
          if (origRulesets
              .every((CssTreeNode ruleset) => ruleset is IncludeDirective)) {
            origRulesets.forEach((CssTreeNode ruleset) {
              rulesets.add(CssIncludeMixinAtDeclaration(
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

      if (mixinDef is CssMixinDeclarationDirective) {
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
      CssMixinDefinition? mixinDef = map[node.name];
      if (currDef is CssMixinDeclarationDirective &&
          mixinDef is CssMixinDeclarationDirective) {
        _IncludeReplacer.replace(
            _styleSheet!, node, mixinDef.declarations.declarations);
      } else if (currDef is CssMixinDeclarationDirective) {
        List<CssTreeNode> decls =
            (currDef as CssMixinDeclarationDirective).declarations.declarations;
        int index = _findInclude(decls, node);
        if (index != -1) {
          decls.replaceRange(index, index + 1, [CssNoOp()]);
        }
      }
    }

    super.visitIncludeDirective(node);
  }

  @override
  void visitMixinRulesetDirective(CssMixinRulesetDirective node) {
    currDef = node;

    super.visitMixinRulesetDirective(node);

    map[node.name] = node;
    currDef = null;
  }

  @override
  void visitMixinDeclarationDirective(CssMixinDeclarationDirective node) {
    currDef = node;

    super.visitMixinDeclarationDirective(node);

    map[node.name] = node;
    currDef = null;
  }

  @override
  void visitVarDefinition(VarDefinition node) {
    List<CssExpression> exprs = (node.expression as CssExpressions).expressions;
    if (exprs.length > 1) {
      varDefs[node.definedName] = node;
    }
    super.visitVarDefinition(node);
  }

  @override
  void visitVarDefinitionDirective(CssVarDefinitionDirective node) {
    visitVarDefinition(node.def);
  }
}

class _IncludeReplacer extends Visitor {
  final CssTreeNode _include;
  final List<CssTreeNode> _newDeclarations;

  static void replace(CssStyleSheet ss, CssTreeNode include,
      List<CssTreeNode> newDeclarations) {
    _IncludeReplacer visitor = _IncludeReplacer(include, newDeclarations);
    visitor.visitStyleSheet(ss);
  }

  _IncludeReplacer(this._include, this._newDeclarations);

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    int index = _findInclude(node.declarations, _include);
    if (index != -1) {
      node.declarations.insertAll(index + 1, _newDeclarations);
      node.declarations.replaceRange(index, index + 1, [CssNoOp()]);
    }
    super.visitDeclarationGroup(node);
  }
}

class MixinsAndIncludes extends Visitor {
  static void remove(CssStyleSheet styleSheet) {
    MixinsAndIncludes().visitStyleSheet(styleSheet);
  }

  bool _nodesToRemove(node) =>
      node is IncludeDirective || node is CssMixinDefinition || node is CssNoOp;

  @override
  void visitStyleSheet(CssStyleSheet ss) {
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
  final Map<String, List<CssSelectorGroup>> inherits =
      <String, List<CssSelectorGroup>>{};

  CssSelectorGroup? _currSelectorGroup;
  int? _currDeclIndex;
  final List<int> _extendsToRemove = <int>[];

  @override
  void visitRuleSet(CssRuleSet node) {
    CssSelectorGroup? oldSelectorGroup = _currSelectorGroup;
    _currSelectorGroup = node.selectorGroup;

    super.visitRuleSet(node);

    _currSelectorGroup = oldSelectorGroup;
  }

  @override
  void visitExtendDeclaration(CssExtendDeclaration node) {
    String inheritName = '';
    for (CssTreeNode selector in node.selectors) {
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

    List<CssTreeNode> decls = node.declarations;
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

  InheritExtends(CssMessages messages, this._allExtends);

  @override
  void visitSelectorGroup(CssSelectorGroup node) {
    for (int selectorsIndex = 0;
        selectorsIndex < node.selectors.length;
        selectorsIndex++) {
      CssSelector selectors = node.selectors[selectorsIndex];
      bool isLastNone = false;
      String selectorName = '';
      for (int index = 0;
          index < selectors.simpleSelectorSequences.length;
          index++) {
        CssSimpleSelectorSequence simpleSeq =
            selectors.simpleSelectorSequences[index];
        String namePart = simpleSeq.simpleSelector.toString();
        selectorName = (isLastNone) ? (selectorName + namePart) : namePart;
        List<CssSelectorGroup>? matches = _allExtends.inherits[selectorName];
        if (matches != null) {
          for (CssSelectorGroup match in matches) {
            CssSelector newSelectors = selectors.clone();
            CssSelector newSeq = match.selectors[0].clone();
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
