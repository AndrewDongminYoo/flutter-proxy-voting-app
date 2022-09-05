// ignore_for_file: constant_identifier_names, prefer_collection_literals
// 🎯 Dart imports:
import 'dart:collection' show IterableBase, LinkedHashMap, ListMixin;

// 📦 Package imports:
import 'package:source_span/source_span.dart' show FileSpan;

// 🌎 Project imports:
import 'dom_parsing.dart';
import 'html.escape.dart';
import 'html.parser.dart' show htmlParse, parseFragment;
import 'src/constants.dart' show Namespaces;
import 'src/css_class_set.dart' show CssClassSet, ElementCssClassSet;
import 'src/list_proxy.dart' show ListProxy;
import 'src/query_selector.dart' as query;
import 'src/tokenizer.dart' show HtmlTokenizer;
import '../parser/src/token.dart';

class AttributeName implements Comparable<Object> {
  final String? prefix;
  final String name;
  final String namespace;
  const AttributeName(this.prefix, this.name, this.namespace);

  @override
  String toString() {
    return prefix != null ? '$prefix:$name' : name;
  }

  @override
  int get hashCode {
    int h = prefix.hashCode;
    h = 37 * (h & 0x1FFFFF) + name.hashCode;
    h = 37 * (h & 0x1FFFFF) + namespace.hashCode;
    return h & 0x3FFFFFFF;
  }

  @override
  int compareTo(Object other) {
    if (other is! AttributeName) return 1;
    int cmp = (prefix ?? '').compareTo((other.prefix ?? ''));
    if (cmp != 0) return cmp;
    cmp = name.compareTo(other.name);
    if (cmp != 0) return cmp;
    return namespace.compareTo(other.namespace);
  }

  @override
  bool operator ==(Object other) =>
      other is AttributeName &&
      prefix == other.prefix &&
      name == other.name &&
      namespace == other.namespace;
}

abstract class _ParentNode implements Node {
  Element? querySelector(String selector) =>
      query.querySelector(this, selector);

  List<Element> querySelectorAll(String selector) =>
      query.querySelectorAll(this, selector);
}

abstract class _NonElementParentNode implements _ParentNode {
  Element? getElementById(String id) => querySelector('#$id');
}

abstract class _ElementAndDocument implements _ParentNode {
  List<Element> getElementsByTagName(String localName) =>
      querySelectorAll(localName);

  List<Element> getElementsByClassName(String classNames) =>
      querySelectorAll(classNames.splitMapJoin(' ',
          onNonMatch: (m) => m.isNotEmpty ? '.$m' : m, onMatch: (m) => ''));
}

abstract class Node {
  static const int ATTRIBUTE_NODE = 2;
  static const int CDATA_SECTION_NODE = 4;
  static const int COMMENT_NODE = 8;
  static const int DOCUMENT_FRAGMENT_NODE = 11;
  static const int DOCUMENT_NODE = 9;
  static const int DOCUMENT_TYPE_NODE = 10;
  static const int ELEMENT_NODE = 1;
  static const int ENTITY_NODE = 6;
  static const int ENTITY_REFERENCE_NODE = 5;
  static const int NOTATION_NODE = 12;
  static const int PROCESSING_INSTRUCTION_NODE = 7;
  static const int TEXT_NODE = 3;

  Node? parentNode;

  Element? get parent {
    final parentNode = this.parentNode;
    return parentNode is Element ? parentNode : null;
  }

  LinkedHashMap<Object, String> attributes = LinkedHashMap();

  late final nodes = NodeList._(this);

  late final List<Element> children = FilteredElementList(this);

  FileSpan? sourceSpan;

  LinkedHashMap<Object, FileSpan>? _attributeSpans;
  LinkedHashMap<Object, FileSpan>? _attributeValueSpans;

  Node._();

  LinkedHashMap<Object, FileSpan>? get attributeSpans {
    _ensureAttributeSpans();
    return _attributeSpans;
  }

  LinkedHashMap<Object, FileSpan>? get attributeValueSpans {
    _ensureAttributeSpans();
    return _attributeValueSpans;
  }

  Node clone(bool deep);

  int get nodeType;

  String get _outerHtml {
    final str = StringBuffer();
    _addOuterHtml(str);
    return str.toString();
  }

  String get _innerHtml {
    final str = StringBuffer();
    _addInnerHtml(str);
    return str.toString();
  }

  String? get text => null;

  set text(String? value) {}

  void append(Node node) => nodes.add(node);

  Node? get firstChild => nodes.isNotEmpty ? nodes[0] : null;

  void _addOuterHtml(StringBuffer str);

  void _addInnerHtml(StringBuffer str) {
    for (Node child in nodes) {
      child._addOuterHtml(str);
    }
  }

  Node remove() {
    parentNode?.nodes.remove(this);
    return this;
  }

  void insertBefore(Node node, Node? refNode) {
    if (refNode == null) {
      nodes.add(node);
    } else {
      nodes.insert(nodes.indexOf(refNode), node);
    }
  }

  Node replaceWith(Node otherNode) {
    if (parentNode == null) {
      throw UnsupportedError('Node must have a parent to replace it.');
    }
    parentNode!.nodes[parentNode!.nodes.indexOf(this)] = otherNode;
    return this;
  }

  bool hasContent() => nodes.isNotEmpty;

  void reparentChildren(Node newParent) {
    newParent.nodes.addAll(nodes);
    nodes.clear();
  }

  bool hasChildNodes() => nodes.isNotEmpty;

  bool contains(Node node) => nodes.contains(node);

  void _ensureAttributeSpans() {
    if (_attributeSpans != null) return;

    final attributeSpans = _attributeSpans = LinkedHashMap<Object, FileSpan>();
    final attributeValueSpans =
        _attributeValueSpans = LinkedHashMap<Object, FileSpan>();

    if (sourceSpan == null) return;

    final tokenizer = HtmlTokenizer(sourceSpan!.text,
        generateSpans: true, attributeSpans: true);

    tokenizer.moveNext();
    final token = tokenizer.current as StartTagToken;

    for (TagAttribute attr in token.attributeSpans!) {
      final offset = sourceSpan!.start.offset;
      final name = attr.name!;
      attributeSpans[name] =
          sourceSpan!.file.span(offset + attr.start, offset + attr.end);
      if (attr.startValue != null) {
        attributeValueSpans[name] = sourceSpan!.file
            .span(offset + attr.startValue!, offset + attr.endValue);
      }
    }
  }

  T _clone<T extends Node>(T shallowClone, bool deep) {
    if (deep) {
      for (Node child in nodes) {
        shallowClone.append(child.clone(true));
      }
    }
    return shallowClone;
  }
}

class Document extends Node
    with _ParentNode, _NonElementParentNode, _ElementAndDocument {
  Document() : super._();

  factory Document.html(String html) => htmlParse(html);

  @override
  int get nodeType => Node.DOCUMENT_NODE;

  Element? get documentElement => querySelector('html');

  Element? get head => documentElement?.querySelector('head');

  Element? get body => documentElement?.querySelector('body');

  String get outerHtml => _outerHtml;

  @override
  String toString() => '#document';

  @override
  void _addOuterHtml(StringBuffer str) => _addInnerHtml(str);

  @override
  Document clone(bool deep) => _clone(Document(), deep);

  Element createElement(String tag) => Element.tag(tag);

  Element createElementNS(String? namespaceUri, String? tag) {
    if (namespaceUri == '') namespaceUri = null;
    return Element._(tag, namespaceUri);
  }

  DocumentFragment createDocumentFragment() => DocumentFragment();
}

class DocumentFragment extends Node with _ParentNode, _NonElementParentNode {
  DocumentFragment() : super._();

  factory DocumentFragment.html(String html) => parseFragment(html);

  @override
  int get nodeType => Node.DOCUMENT_FRAGMENT_NODE;

  String get outerHtml => _outerHtml;

  @override
  String toString() => '#document-fragment';

  @override
  DocumentFragment clone(bool deep) => _clone(DocumentFragment(), deep);

  @override
  void _addOuterHtml(StringBuffer str) => _addInnerHtml(str);

  @override
  String? get text => _getText(this);

  @override
  set text(String? value) => _setText(this, value);
}

class DocumentType extends Node {
  final String? name;
  final String? publicId;
  final String? systemId;

  DocumentType(this.name, this.publicId, this.systemId) : super._();

  @override
  int get nodeType => Node.DOCUMENT_TYPE_NODE;

  @override
  String toString() {
    if (publicId != null || systemId != null) {
      final pid = publicId ?? '';
      final sid = systemId ?? '';
      return '<!DOCTYPE $name "$pid" "$sid">';
    } else {
      return '<!DOCTYPE $name>';
    }
  }

  @override
  void _addOuterHtml(StringBuffer str) {
    str.write(toString());
  }

  @override
  DocumentType clone(bool deep) => DocumentType(name, publicId, systemId);
}

class TextNode extends Node {
  Object _data;

  TextNode(String? data)
      : _data = data ?? '',
        super._();

  @override
  int get nodeType => Node.TEXT_NODE;

  String get data => _data = _data.toString();

  set data(String value) {
    _data = identical(value, null) ? '' : value;
  }

  @override
  String toString() => '"$data"';

  @override
  void _addOuterHtml(StringBuffer str) => writeTextNodeAsHtml(str, this);

  @override
  TextNode clone(bool deep) => TextNode(data);

  void appendData(String data) {
    if (_data is! StringBuffer) _data = StringBuffer(_data);
    final sb = _data as StringBuffer;
    sb.write(data);
  }

  @override
  String get text => data;

  @override
  set text(covariant String value) {
    data = value;
  }
}

class Element extends Node with _ParentNode, _ElementAndDocument {
  final String? namespaceUri;

  final String? localName;

  FileSpan? endSourceSpan;

  Element._(this.localName, [this.namespaceUri]) : super._();

  Element.tag(this.localName)
      : namespaceUri = Namespaces.html,
        super._();

  static final _startTagRegexp = RegExp('<(\\w+)');

  static final _customParentTagMap = {
    'body': 'html',
    'head': 'html',
    'caption': 'table',
    'td': 'tr',
    'colgroup': 'table',
    'col': 'colgroup',
    'tr': 'tbody',
    'tbody': 'table',
    'tfoot': 'table',
    'thead': 'table',
    'track': 'audio',
  };

  factory Element.html(String html) {
    String parentTag = 'div';
    String? tag;
    final match = _startTagRegexp.firstMatch(html);
    if (match != null) {
      tag = match.group(1)!.toLowerCase();
      if (_customParentTagMap.containsKey(tag)) {
        parentTag = _customParentTagMap[tag]!;
      }
    }

    final fragment = parseFragment(html, container: parentTag);
    Element element;
    if (fragment.children.length == 1) {
      element = fragment.children[0];
    } else if (parentTag == 'html' && fragment.children.length == 2) {
      element = fragment.children[tag == 'head' ? 0 : 1];
    } else {
      throw ArgumentError('HTML had ${fragment.children.length} '
          'top level elements but 1 expected');
    }
    element.remove();
    return element;
  }

  @override
  int get nodeType => Node.ELEMENT_NODE;

  Element? get previousElementSibling {
    if (parentNode == null) return null;
    final siblings = parentNode!.nodes;
    for (int i = siblings.indexOf(this) - 1; i >= 0; i--) {
      final s = siblings[i];
      if (s is Element) return s;
    }
    return null;
  }

  Element? get nextElementSibling {
    final parentNode = this.parentNode;
    if (parentNode == null) return null;
    final siblings = parentNode.nodes;
    for (int i = siblings.indexOf(this) + 1; i < siblings.length; i++) {
      final s = siblings[i];
      if (s is Element) return s;
    }
    return null;
  }

  @override
  String toString() {
    final prefix = Namespaces.getPrefix(namespaceUri);
    return "<${prefix == null ? '' : '$prefix '}$localName>";
  }

  @override
  String get text => _getText(this);

  @override
  set text(String? value) => _setText(this, value);

  String get outerHtml => _outerHtml;

  String get innerHtml => _innerHtml;

  set innerHtml(String value) {
    nodes.clear();
    nodes.addAll(parseFragment(value, container: localName!).nodes);
  }

  @override
  void _addOuterHtml(StringBuffer str) {
    str.write('<');
    str.write(_getSerializationPrefix(namespaceUri));
    str.write(localName);

    if (attributes.isNotEmpty) {
      attributes.forEach((key, v) {
        str.write(' ');
        str.write(key);
        str.write('="');
        str.write(htmlSerializeEscape(v, attributeMode: true));
        str.write('"');
      });
    }

    str.write('>');

    if (nodes.isNotEmpty) {
      if (localName == 'pre' ||
          localName == 'textarea' ||
          localName == 'listing') {
        final first = nodes[0];
        if (first is TextNode && first.data.startsWith('\n')) {
          str.write('\n');
        }
      }

      _addInnerHtml(str);
    }

    if (!isVoidElement(localName)) str.write('</$localName>');
  }

  static String _getSerializationPrefix(String? uri) {
    if (uri == null ||
        uri == Namespaces.html ||
        uri == Namespaces.mathml ||
        uri == Namespaces.svg) {
      return '';
    }
    final prefix = Namespaces.getPrefix(uri);
    return prefix == null ? '' : '$prefix:';
  }

  @override
  Element clone(bool deep) {
    final result = Element._(localName, namespaceUri)
      ..attributes = LinkedHashMap.from(attributes);
    return _clone(result, deep);
  }

  String get id {
    final result = attributes['id'];
    return result ?? '';
  }

  set id(String value) {
    attributes['id'] = value;
  }

  String get className {
    final result = attributes['class'];
    return result ?? '';
  }

  set className(String value) {
    attributes['class'] = value;
  }

  CssClassSet get classes => ElementCssClassSet(this);
}

class Comment extends Node {
  String? data;

  Comment(this.data) : super._();

  @override
  int get nodeType => Node.COMMENT_NODE;

  @override
  String toString() => '<!-- $data -->';

  @override
  void _addOuterHtml(StringBuffer str) {
    str.write('<!--$data-->');
  }

  @override
  Comment clone(bool deep) => Comment(data);

  @override
  String? get text => data;

  @override
  set text(String? value) {
    data = value;
  }
}

class NodeList extends ListProxy<Node> {
  final Node _parent;

  NodeList._(this._parent);

  Node _setParent(Node node) {
    node.remove();
    node.parentNode = _parent;
    return node;
  }

  @override
  void add(Node element) {
    if (element is DocumentFragment) {
      addAll(element.nodes);
    } else {
      super.add(_setParent(element));
    }
  }

  void addLast(Node value) => add(value);

  @override
  void addAll(Iterable<Node> iterable) {
    final list = _flattenDocFragments(iterable);
    for (Node node in list.reversed) {
      _setParent(node);
    }
    super.addAll(list);
  }

  @override
  void insert(int index, Node element) {
    if (element is DocumentFragment) {
      insertAll(index, element.nodes);
    } else {
      super.insert(index, _setParent(element));
    }
  }

  @override
  Node removeLast() => super.removeLast()..parentNode = null;

  @override
  Node removeAt(int index) => super.removeAt(index)..parentNode = null;

  @override
  void clear() {
    for (Node node in this) {
      node.parentNode = null;
    }
    super.clear();
  }

  @override
  void operator []=(int index, Node value) {
    if (value is DocumentFragment) {
      removeAt(index);
      insertAll(index, value.nodes);
    } else {
      this[index].parentNode = null;
      super[index] = _setParent(value);
    }
  }

  @override
  void setRange(int start, int end, Iterable<Node> iterable,
      [int skipCount = 0]) {
    List<Node> fromVar = iterable as List<Node>;
    if (fromVar is NodeList) {
      fromVar = fromVar.sublist(skipCount, skipCount + end);
    }
    for (int i = end - 1; i >= 0; i--) {
      this[start + i] = fromVar[skipCount + i];
    }
  }

  @override
  void replaceRange(int start, int end, Iterable<Node> newContents) {
    removeRange(start, end);
    insertAll(start, newContents);
  }

  @override
  void removeRange(int start, int end) {
    for (int i = start; i < end; i++) {
      this[i].parentNode = null;
    }
    super.removeRange(start, end);
  }

  @override
  void removeWhere(bool Function(Node) test) {
    for (Node node in where(test)) {
      node.parentNode = null;
    }
    super.removeWhere(test);
  }

  @override
  void retainWhere(bool Function(Node) test) {
    for (Node node in where((n) => !test(n))) {
      node.parentNode = null;
    }
    super.retainWhere(test);
  }

  @override
  void insertAll(int index, Iterable<Node> iterable) {
    final list = _flattenDocFragments(iterable);
    for (Node node in list.reversed) {
      _setParent(node);
    }
    super.insertAll(index, list);
  }

  List<Node> _flattenDocFragments(Iterable<Node> collection) {
    final result = <Node>[];
    for (Node node in collection) {
      if (node is DocumentFragment) {
        result.addAll(node.nodes);
      } else {
        result.add(node);
      }
    }
    return result;
  }
}

class FilteredElementList extends IterableBase<Element>
    with ListMixin<Element>
    implements List<Element> {
  final List<Node> _childNodes;

  FilteredElementList(Node node) : _childNodes = node.nodes;

  List<Element> get _filtered => _childNodes.whereType<Element>().toList();

  @override
  void forEach(void Function(Element) action) {
    _filtered.forEach(action);
  }

  @override
  void operator []=(int index, Element value) {
    this[index].replaceWith(value);
  }

  @override
  set length(int newLength) {
    final len = length;
    if (newLength >= len) {
      return;
    } else if (newLength < 0) {
      throw ArgumentError('Invalid list length');
    }

    removeRange(newLength, len);
  }

  @override
  String join([String separator = '']) => _filtered.join(separator);

  @override
  void add(Element element) {
    _childNodes.add(element);
  }

  @override
  void addAll(Iterable<Element> iterable) {
    for (Element element in iterable) {
      add(element);
    }
  }

  @override
  bool contains(Object? element) {
    return element is Element && _childNodes.contains(element);
  }

  @override
  Iterable<Element> get reversed => _filtered.reversed;

  @override
  void sort([int Function(Element, Element)? compare]) {
    throw UnsupportedError('TODO(jacobr): should we impl?');
  }

  @override
  void setRange(int start, int end, Iterable<Element> iterable,
      [int skipCount = 0]) {
    throw UnimplementedError();
  }

  @override
  void fillRange(int start, int end, [Element? fill]) {
    throw UnimplementedError();
  }

  @override
  void replaceRange(int start, int end, Iterable<Element> newContents) {
    throw UnimplementedError();
  }

  @override
  void removeRange(int start, int end) {
    _filtered.sublist(start, end).forEach((el) => el.remove());
  }

  @override
  void clear() {
    _childNodes.clear();
  }

  @override
  Element removeLast() {
    return last..remove();
  }

  @override
  Iterable<T> map<T>(T Function(Element) f) => _filtered.map(f);

  @override
  Iterable<Element> where(bool Function(Element) test) => _filtered.where(test);

  @override
  Iterable<T> expand<T>(Iterable<T> Function(Element) f) => _filtered.expand(f);

  @override
  void insert(int index, Element element) {
    _childNodes.insert(index, element);
  }

  @override
  void insertAll(int index, Iterable<Element> iterable) {
    _childNodes.insertAll(index, iterable);
  }

  @override
  Element removeAt(int index) {
    final result = this[index];
    result.remove();
    return result;
  }

  @override
  bool remove(Object? element) {
    if (element is! Element) return false;
    for (int i = 0; i < length; i++) {
      final indexElement = this[i];
      if (identical(indexElement, element)) {
        indexElement.remove();
        return true;
      }
    }
    return false;
  }

  @override
  Element reduce(Element Function(Element, Element) combine) {
    return _filtered.reduce(combine);
  }

  @override
  T fold<T>(
      T initialValue, T Function(T previousValue, Element element) combine) {
    return _filtered.fold(initialValue, combine);
  }

  @override
  bool every(bool Function(Element) test) => _filtered.every(test);

  @override
  bool any(bool Function(Element) test) => _filtered.any(test);

  @override
  List<Element> toList({bool growable = true}) =>
      List<Element>.from(this, growable: growable);

  @override
  Set<Element> toSet() => Set<Element>.from(this);

  @override
  Element firstWhere(bool Function(Element) test,
      {Element Function()? orElse}) {
    return _filtered.firstWhere(test, orElse: orElse);
  }

  @override
  Element lastWhere(bool Function(Element) test, {Element Function()? orElse}) {
    return _filtered.lastWhere(test, orElse: orElse);
  }

  @override
  Element singleWhere(bool Function(Element) test,
      {Element Function()? orElse}) {
    if (orElse != null) throw UnimplementedError('orElse');
    return _filtered.singleWhere(test);
  }

  @override
  Element elementAt(int index) {
    return this[index];
  }

  @override
  bool get isEmpty => _filtered.isEmpty;

  @override
  int get length => _filtered.length;

  @override
  Element operator [](int index) => _filtered[index];

  @override
  Iterator<Element> get iterator => _filtered.iterator;

  @override
  List<Element> sublist(int start, [int? end]) => _filtered.sublist(start, end);

  @override
  Iterable<Element> getRange(int start, int end) =>
      _filtered.getRange(start, end);

  @override
  int indexOf(Object? element, [int start = 0]) =>
      _filtered.indexOf(element as Element, start);

  @override
  int lastIndexOf(Object? element, [int? start]) {
    start ??= length - 1;
    return _filtered.lastIndexOf(element as Element, start);
  }

  @override
  Element get first => _filtered.first;

  @override
  Element get last => _filtered.last;

  @override
  Element get single => _filtered.single;
}

String _getText(Node node) => (_ConcatTextVisitor()..visit(node)).toString();

void _setText(Node node, String? value) {
  node.nodes.clear();
  node.append(TextNode(value));
}

class _ConcatTextVisitor extends TreeVisitor {
  final _str = StringBuffer();

  @override
  String toString() => _str.toString();

  @override
  void visitText(TextNode node) {
    _str.write(node.data);
  }
}
