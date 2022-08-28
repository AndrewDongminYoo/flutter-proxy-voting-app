library treebuilder;

// 🎯 Dart imports:
import 'dart:collection';

// 📦 Package imports:
import 'package:source_span/source_span.dart';

// 🌎 Project imports:
import '../dom.dart';
import '../html.parser.dart' show getElementNameTuple;
import 'src.dart';

class ActiveFormattingElements extends ListProxy<Element?> {
  @override
  void add(Element? element) {
    int equalCount = 0;
    if (element != null) {
      for (Element? element in reversed) {
        if (element == null) {
          break;
        }
        if (_nodesEqual(element, element)) {
          equalCount += 1;
        }
        if (equalCount == 3) {
          remove(element);
          break;
        }
      }
    }
    super.add(element);
  }
}

bool _mapEquals(Map a, Map b) {
  if (a.length != b.length) return false;
  if (a.isEmpty) return true;

  for (dynamic keyA in a.keys) {
    final valB = b[keyA];
    if (valB == null && !b.containsKey(keyA)) {
      return false;
    }

    if (a[keyA] != valB) {
      return false;
    }
  }
  return true;
}

bool _nodesEqual(Element node1, Element node2) {
  return getElementNameTuple(node1) == getElementNameTuple(node2) &&
      _mapEquals(node1.attributes, node2.attributes);
}

class TreeBuilder {
  final String? defaultNamespace;

  late Document document;

  final List<Element> openElements = <Element>[];

  final ListProxy<Element?> activeFormattingElements =
      ActiveFormattingElements();

  Node? headPointer;

  Element? formPointer;

  bool insertFromTable = false;

  TreeBuilder(bool namespaceHTMLElements)
      : defaultNamespace = namespaceHTMLElements ? Namespaces.html : null {
    reset();
  }

  void reset() {
    openElements.clear();
    activeFormattingElements.clear();

    headPointer = null;
    formPointer = null;

    insertFromTable = false;

    document = Document();
  }

  bool elementInScope(target, {String? variant}) {
    final exactNode = target is Node;

    dynamic listElements1 = scopingElements;
    List<dynamic> listElements2 = const [];
    bool invert = false;
    if (variant != null) {
      switch (variant) {
        case 'button':
          listElements2 = const [Pair(Namespaces.html, 'button')];
          break;
        case 'list':
          listElements2 = const [
            Pair(Namespaces.html, 'ol'),
            Pair(Namespaces.html, 'ul')
          ];
          break;
        case 'table':
          listElements1 = const [
            Pair(Namespaces.html, 'html'),
            Pair(Namespaces.html, 'table')
          ];
          break;
        case 'select':
          listElements1 = const [
            Pair(Namespaces.html, 'optgroup'),
            Pair(Namespaces.html, 'option')
          ];
          invert = true;
          break;
        default:
          throw StateError('We should never reach this point');
      }
    }

    for (Element node in openElements.reversed) {
      if (!exactNode && node.localName == target ||
          exactNode && node == target) {
        return true;
      } else if (invert !=
          (listElements1.contains(getElementNameTuple(node)) ||
              listElements2.contains(getElementNameTuple(node)))) {
        return false;
      }
    }

    throw StateError('We should never reach this point');
  }

  void reconstructActiveFormattingElements() {
    if (activeFormattingElements.isEmpty) {
      return;
    }

    int i = activeFormattingElements.length - 1;
    Element? entry = activeFormattingElements[i];
    if (entry == null || openElements.contains(entry)) {
      return;
    }

    while (entry != null && !openElements.contains(entry)) {
      if (i == 0) {
        i = -1;
        break;
      }
      i -= 1;

      entry = activeFormattingElements[i];
    }

    while (true) {
      i += 1;

      entry = activeFormattingElements[i];

      final cloneToken = StartTagToken(entry!.localName,
          namespace: entry.namespaceUri,
          data: LinkedHashMap.from(entry.attributes))
        ..span = entry.sourceSpan;

      final element = insertElement(cloneToken);

      activeFormattingElements[i] = element;

      if (element == activeFormattingElements.last) {
        break;
      }
    }
  }

  void clearActiveFormattingElements() {
    Element? entry = activeFormattingElements.removeLast();
    while (activeFormattingElements.isNotEmpty && entry != null) {
      entry = activeFormattingElements.removeLast();
    }
  }

  Element? elementInActiveFormattingElements(String? name) {
    for (Element? item in activeFormattingElements.reversed) {
      if (item == null) {
        break;
      } else if (item.localName == name) {
        return item;
      }
    }
    return null;
  }

  void insertRoot(StartTagToken token) {
    final element = createElement(token);
    openElements.add(element);
    document.nodes.add(element);
  }

  void insertDoctype(DoctypeToken token) {
    final doctype = DocumentType(token.name, token.publicId, token.systemId)
      ..sourceSpan = token.span;
    document.nodes.add(doctype);
  }

  void insertComment(StringToken token, [Node? parent]) {
    parent ??= openElements.last;
    parent.nodes.add(Comment(token.data)..sourceSpan = token.span);
  }

  Element createElement(StartTagToken token) {
    final name = token.name;
    final namespace = token.namespace ?? defaultNamespace;
    final element = document.createElementNS(namespace, name)
      ..attributes = token.data
      ..sourceSpan = token.span;
    return element;
  }

  Element insertElement(StartTagToken token) {
    if (insertFromTable) return insertElementTable(token);
    return insertElementNormal(token);
  }

  Element insertElementNormal(StartTagToken token) {
    final name = token.name;
    final namespace = token.namespace ?? defaultNamespace;
    final element = document.createElementNS(namespace, name)
      ..attributes = token.data
      ..sourceSpan = token.span;
    openElements.last.nodes.add(element);
    openElements.add(element);
    return element;
  }

  Element insertElementTable(StartTagToken token) {
    final element = createElement(token);
    if (!tableInsertModeElements.contains(openElements.last.localName)) {
      return insertElementNormal(token);
    } else {
      final nodePos = getTableMisnestedNodePosition();
      if (nodePos[1] == null) {
        nodePos[0]!.nodes.add(element);
      } else {
        nodePos[0]!.insertBefore(element, nodePos[1]);
      }
      openElements.add(element);
    }
    return element;
  }

  void insertText(String data, FileSpan? span) {
    final parent = openElements.last;

    if (!insertFromTable ||
        insertFromTable &&
            !tableInsertModeElements.contains(openElements.last.localName)) {
      _insertText(parent, data, span);
    } else {
      final nodePos = getTableMisnestedNodePosition();
      _insertText(nodePos[0]!, data, span, nodePos[1] as Element?);
    }
  }

  static void _insertText(Node parent, String data, FileSpan? span,
      [Element? refNode]) {
    final nodes = parent.nodes;
    if (refNode == null) {
      if (nodes.isNotEmpty && nodes.last is Text) {
        final last = nodes.last as Text;
        last.appendData(data);

        if (span != null) {
          last.sourceSpan =
              span.file.span(last.sourceSpan!.start.offset, span.end.offset);
        }
      } else {
        nodes.add(Text(data)..sourceSpan = span);
      }
    } else {
      final index = nodes.indexOf(refNode);
      if (index > 0 && nodes[index - 1] is Text) {
        final last = nodes[index - 1] as Text;
        last.appendData(data);
      } else {
        nodes.insert(index, Text(data)..sourceSpan = span);
      }
    }
  }

  List<Node?> getTableMisnestedNodePosition() {
    Element? lastTable;
    Node? fosterParent;
    Node? insertBefore;
    for (Element elm in openElements.reversed) {
      if (elm.localName == 'table') {
        lastTable = elm;
        break;
      }
    }
    if (lastTable != null) {
      if (lastTable.parentNode != null) {
        fosterParent = lastTable.parentNode;
        insertBefore = lastTable;
      } else {
        fosterParent = openElements[openElements.indexOf(lastTable) - 1];
      }
    } else {
      fosterParent = openElements[0];
    }
    return [fosterParent, insertBefore];
  }

  void generateImpliedEndTags([String? exclude]) {
    final name = openElements.last.localName;

    if (name != exclude &&
        const ['dd', 'dt', 'li', 'option', 'optgroup', 'p', 'rp', 'rt']
            .contains(name)) {
      openElements.removeLast();

      generateImpliedEndTags(exclude);
    }
  }

  Document getDocument() => document;

  DocumentFragment getFragment() {
    final fragment = DocumentFragment();
    openElements[0].reparentChildren(fragment);
    return fragment;
  }
}
