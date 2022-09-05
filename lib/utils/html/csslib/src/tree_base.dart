part of '../visitor.dart';

abstract class CssTreeNode {
  final SourceSpan? span;

  CssTreeNode(this.span);

  CssTreeNode clone();

  dynamic visit(VisitorBase visitor);

  String toDebugString() {
    TreeOutput to = TreeOutput();
    _TreePrinter tp = _TreePrinter(to, true);
    visit(tp);
    return to.buf.toString();
  }
}

abstract class CssExpression extends CssTreeNode {
  CssExpression(SourceSpan? span) : super(span);
  @override
  CssExpression clone();
}

class TreeOutput {
  int depth = 0;
  final StringBuffer buf = StringBuffer();
  VisitorBase? printer;

  void write(String s) {
    for (int i = 0; i < depth; i++) {
      buf.write(' ');
    }
    buf.write(s);
  }

  void writeln(String s) {
    write(s);
    buf.write('\n');
  }

  void heading(String name, [SourceSpan? span]) {
    write(name);
    if (span != null) {
      buf.write('  (${span.message('')})');
    }
    buf.write('\n');
  }

  String toValue(value) {
    if (value == null) {
      return 'null';
    } else if (value is CssIdentifier) {
      return value.name;
    } else {
      return value.toString();
    }
  }

  void writeNode(String label, CssTreeNode? node) {
    write('$label: ');
    depth += 1;
    if (node != null) {
      node.visit(printer!);
    } else {
      writeln('null');
    }
    depth -= 1;
  }

  void writeValue(String label, value) {
    String v = toValue(value);
    writeln('$label: $v');
  }

  void writeNodeList(String label, List<CssTreeNode>? list) {
    writeln('$label [');
    if (list != null) {
      depth += 1;
      for (CssTreeNode node in list) {
        node.visit(printer!);
      }
      depth -= 1;
      writeln(']');
    }
  }

  @override
  String toString() => buf.toString();
}
