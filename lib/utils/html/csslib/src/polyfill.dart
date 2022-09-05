part of '../parser.dart';

class CssPolyFill {
  final CssMessages _messages;
  Map<String, VarDefinition> _allVarDefinitions = <String, VarDefinition>{};

  Set<CssStyleSheet> allStyleSheets = <CssStyleSheet>{};

  CssPolyFill(this._messages);

  void process(CssStyleSheet styleSheet, {List<CssStyleSheet>? includes}) {
    if (includes != null) {
      processVarDefinitions(includes);
    }
    processVars(styleSheet);

    _RemoveVarDefinitions().visitTree(styleSheet);
  }

  void processVarDefinitions(List<CssStyleSheet> includes) {
    for (CssStyleSheet include in includes) {
      _allVarDefinitions = (_VarDefinitionsIncludes(_allVarDefinitions)
            ..visitTree(include))
          .varDefs;
    }
  }

  void processVars(CssStyleSheet styleSheet) {
    Map<String, VarDefinition> mainStyleSheetVarDefs =
        (_VarDefAndUsage(_messages, _allVarDefinitions)..visitTree(styleSheet))
            .varDefs;

    mainStyleSheetVarDefs.forEach((key, value) {
      // ignore: unused_local_variable
      for (CssExpression unused
          in (value.expression as CssExpressions).expressions) {
        mainStyleSheetVarDefs[key] =
            _findTerminalVarDefinition(_allVarDefinitions, value);
      }
    });
  }
}

class _VarDefinitionsIncludes extends Visitor {
  final Map<String, VarDefinition> varDefs;

  _VarDefinitionsIncludes(this.varDefs);

  @override
  void visitTree(CssStyleSheet tree) {
    visitStyleSheet(tree);
  }

  @override
  void visitVarDefinition(VarDefinition node) {
    varDefs[node.definedName] = node;
    super.visitVarDefinition(node);
  }

  @override
  void visitVarDefinitionDirective(CssVarDefinitionDirective node) {
    visitVarDefinition(node.def);
  }
}

class _VarDefAndUsage extends Visitor {
  final CssMessages _messages;
  final Map<String, VarDefinition> _knownVarDefs;
  final varDefs = <String, VarDefinition>{};

  VarDefinition? currVarDefinition;
  List<CssExpression>? currentExpressions;

  _VarDefAndUsage(this._messages, this._knownVarDefs);

  @override
  void visitTree(CssStyleSheet tree) {
    visitStyleSheet(tree);
  }

  @override
  void visitVarDefinition(VarDefinition node) {
    currVarDefinition = node;

    _knownVarDefs[node.definedName] = node;
    varDefs[node.definedName] = node;

    super.visitVarDefinition(node);

    currVarDefinition = null;
  }

  @override
  void visitVarDefinitionDirective(CssVarDefinitionDirective node) {
    visitVarDefinition(node.def);
  }

  @override
  void visitExpressions(CssExpressions node) {
    currentExpressions = node.expressions;
    super.visitExpressions(node);
    currentExpressions = null;
  }

  @override
  void visitVarUsage(CssVarUsage node) {
    if (currVarDefinition != null && currVarDefinition!.badUsage) return;

    List<CssExpression>? expressions = currentExpressions;
    int index = expressions!.indexOf(node);
    assert(index >= 0);
    VarDefinition? def = _knownVarDefs[node.name];
    if (def != null) {
      if (def.badUsage) {
        expressions.removeAt(index);
        return;
      }
      _resolveVarUsage(currentExpressions!, index,
          _findTerminalVarDefinition(_knownVarDefs, def));
    } else if (node.defaultValues.any((e) => e is CssVarUsage)) {
      List<CssExpression> terminalDefaults = <CssExpression>[];
      for (CssExpression defaultValue in node.defaultValues) {
        terminalDefaults
            .addAll(resolveUsageTerminal(defaultValue as CssVarUsage));
      }
      expressions.replaceRange(index, index + 1, terminalDefaults);
    } else if (node.defaultValues.isNotEmpty) {
      expressions.replaceRange(index, index + 1, node.defaultValues);
    } else {
      if (currVarDefinition != null) {
        currVarDefinition!.badUsage = true;
        VarDefinition? mainStyleSheetDef = varDefs[node.name];
        if (mainStyleSheetDef != null) {
          varDefs.remove(currVarDefinition!.property);
        }
      }

      expressions.removeAt(index);
      _messages.warning('Variable is not defined.', node.span);
    }

    List<CssExpression>? oldExpressions = currentExpressions;
    currentExpressions = node.defaultValues;
    super.visitVarUsage(node);
    currentExpressions = oldExpressions;
  }

  List<CssExpression> resolveUsageTerminal(CssVarUsage usage) {
    List<CssExpression> result = <CssExpression>[];

    VarDefinition? varDef = _knownVarDefs[usage.name];
    List<CssExpression> expressions;
    if (varDef == null) {
      expressions = usage.defaultValues;
    } else {
      expressions = (varDef.expression as CssExpressions).expressions;
    }

    for (CssExpression expr in expressions) {
      if (expr is CssVarUsage) {
        result.addAll(resolveUsageTerminal(expr));
      }
    }

    if (result.isEmpty && varDef != null) {
      result = (varDef.expression as CssExpressions).expressions;
    }

    return result;
  }

  void _resolveVarUsage(
      List<CssExpression> expressions, int index, VarDefinition def) {
    List<CssExpression> defExpressions =
        (def.expression as CssExpressions).expressions;
    expressions.replaceRange(index, index + 1, defExpressions);
  }
}

class _RemoveVarDefinitions extends Visitor {
  @override
  void visitTree(CssStyleSheet tree) {
    visitStyleSheet(tree);
  }

  @override
  void visitStyleSheet(CssStyleSheet ss) {
    ss.topLevels.removeWhere((e) => e is CssVarDefinitionDirective);
    super.visitStyleSheet(ss);
  }

  @override
  void visitDeclarationGroup(DeclarationGroup node) {
    node.declarations.removeWhere((e) => e is VarDefinition);
    super.visitDeclarationGroup(node);
  }
}

VarDefinition _findTerminalVarDefinition(
    Map<String, VarDefinition> varDefs, VarDefinition varDef) {
  CssExpressions expressions = varDef.expression as CssExpressions;
  for (CssExpression expr in expressions.expressions) {
    if (expr is CssVarUsage) {
      String usageName = expr.name;
      VarDefinition? foundDef = varDefs[usageName];

      if (foundDef == null) {
        List<CssExpression> defaultValues = expr.defaultValues;
        List<CssExpression> replaceExprs = expressions.expressions;
        assert(replaceExprs.length == 1);
        replaceExprs.replaceRange(0, 1, defaultValues);
        return varDef;
      }
      return _findTerminalVarDefinition(varDefs, foundDef);
    } else {
      return varDef;
    }
  }

  return varDef;
}
