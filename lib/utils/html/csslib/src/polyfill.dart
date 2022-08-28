part of '../parser.dart';

class PolyFill {
  final Messages _messages;
  Map<String, VarDefinition> _allVarDefinitions = <String, VarDefinition>{};

  Set<StyleSheet> allStyleSheets = <StyleSheet>{};

  PolyFill(this._messages);

  void process(StyleSheet styleSheet, {List<StyleSheet>? includes}) {
    if (includes != null) {
      processVarDefinitions(includes);
    }
    processVars(styleSheet);

    _RemoveVarDefinitions().visitTree(styleSheet);
  }

  void processVarDefinitions(List<StyleSheet> includes) {
    for (StyleSheet include in includes) {
      _allVarDefinitions = (_VarDefinitionsIncludes(_allVarDefinitions)
            ..visitTree(include))
          .varDefs;
    }
  }

  void processVars(StyleSheet styleSheet) {
    Map<String, VarDefinition> mainStyleSheetVarDefs =
        (_VarDefAndUsage(_messages, _allVarDefinitions)..visitTree(styleSheet))
            .varDefs;

    mainStyleSheetVarDefs.forEach((key, value) {
      // ignore: unused_local_variable
      for (Expression unused in (value.expression as Expressions).expressions) {
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
  void visitTree(StyleSheet tree) {
    visitStyleSheet(tree);
  }

  @override
  void visitVarDefinition(VarDefinition node) {
    varDefs[node.definedName] = node;
    super.visitVarDefinition(node);
  }

  @override
  void visitVarDefinitionDirective(VarDefinitionDirective node) {
    visitVarDefinition(node.def);
  }
}

class _VarDefAndUsage extends Visitor {
  final Messages _messages;
  final Map<String, VarDefinition> _knownVarDefs;
  final varDefs = <String, VarDefinition>{};

  VarDefinition? currVarDefinition;
  List<Expression>? currentExpressions;

  _VarDefAndUsage(this._messages, this._knownVarDefs);

  @override
  void visitTree(StyleSheet tree) {
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
  void visitVarDefinitionDirective(VarDefinitionDirective node) {
    visitVarDefinition(node.def);
  }

  @override
  void visitExpressions(Expressions node) {
    currentExpressions = node.expressions;
    super.visitExpressions(node);
    currentExpressions = null;
  }

  @override
  void visitVarUsage(VarUsage node) {
    if (currVarDefinition != null && currVarDefinition!.badUsage) return;

    var expressions = currentExpressions;
    var index = expressions!.indexOf(node);
    assert(index >= 0);
    var def = _knownVarDefs[node.name];
    if (def != null) {
      if (def.badUsage) {
        expressions.removeAt(index);
        return;
      }
      _resolveVarUsage(currentExpressions!, index,
          _findTerminalVarDefinition(_knownVarDefs, def));
    } else if (node.defaultValues.any((e) => e is VarUsage)) {
      var terminalDefaults = <Expression>[];
      for (var defaultValue in node.defaultValues) {
        terminalDefaults.addAll(resolveUsageTerminal(defaultValue as VarUsage));
      }
      expressions.replaceRange(index, index + 1, terminalDefaults);
    } else if (node.defaultValues.isNotEmpty) {
      expressions.replaceRange(index, index + 1, node.defaultValues);
    } else {
      if (currVarDefinition != null) {
        currVarDefinition!.badUsage = true;
        var mainStyleSheetDef = varDefs[node.name];
        if (mainStyleSheetDef != null) {
          varDefs.remove(currVarDefinition!.property);
        }
      }

      expressions.removeAt(index);
      _messages.warning('Variable is not defined.', node.span);
    }

    var oldExpressions = currentExpressions;
    currentExpressions = node.defaultValues;
    super.visitVarUsage(node);
    currentExpressions = oldExpressions;
  }

  List<Expression> resolveUsageTerminal(VarUsage usage) {
    var result = <Expression>[];

    var varDef = _knownVarDefs[usage.name];
    List<Expression> expressions;
    if (varDef == null) {
      expressions = usage.defaultValues;
    } else {
      expressions = (varDef.expression as Expressions).expressions;
    }

    for (var expr in expressions) {
      if (expr is VarUsage) {
        result.addAll(resolveUsageTerminal(expr));
      }
    }

    if (result.isEmpty && varDef != null) {
      result = (varDef.expression as Expressions).expressions;
    }

    return result;
  }

  void _resolveVarUsage(
      List<Expression> expressions, int index, VarDefinition def) {
    var defExpressions = (def.expression as Expressions).expressions;
    expressions.replaceRange(index, index + 1, defExpressions);
  }
}

class _RemoveVarDefinitions extends Visitor {
  @override
  void visitTree(StyleSheet tree) {
    visitStyleSheet(tree);
  }

  @override
  void visitStyleSheet(StyleSheet ss) {
    ss.topLevels.removeWhere((e) => e is VarDefinitionDirective);
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
  var expressions = varDef.expression as Expressions;
  for (var expr in expressions.expressions) {
    if (expr is VarUsage) {
      var usageName = expr.name;
      var foundDef = varDefs[usageName];

      if (foundDef == null) {
        var defaultValues = expr.defaultValues;
        var replaceExprs = expressions.expressions;
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
