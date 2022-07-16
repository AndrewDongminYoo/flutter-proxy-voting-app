library dom_parsing;

// 🌎 Project imports:
import 'dom.dart';
import 'html.escape.dart' show htmlSerializeEscape;
import 'src/constants.dart' show rcdataElements;

export 'html.escape.dart';

class TreeVisitor {
  void visit(Node node) {
    switch (node.nodeType) {
      case Node.ELEMENT_NODE:
        return visitElement(node as Element);
      case Node.TEXT_NODE:
        return visitText(node as Text);
      case Node.COMMENT_NODE:
        return visitComment(node as Comment);
      case Node.DOCUMENT_FRAGMENT_NODE:
        return visitDocumentFragment(node as DocumentFragment);
      case Node.DOCUMENT_NODE:
        return visitDocument(node as Document);
      case Node.DOCUMENT_TYPE_NODE:
        return visitDocumentType(node as DocumentType);
      default:
        throw UnsupportedError('DOM node type ${node.nodeType}');
    }
  }

  void visitChildren(Node node) {
    for (var child in node.nodes.toList()) {
      visit(child);
    }
  }

  void visitNodeFallback(Node node) => visitChildren(node);

  void visitDocument(Document node) => visitNodeFallback(node);

  void visitDocumentType(DocumentType node) => visitNodeFallback(node);

  void visitText(Text node) => visitNodeFallback(node);

  void visitElement(Element node) => visitNodeFallback(node);

  void visitComment(Comment node) => visitNodeFallback(node);

  void visitDocumentFragment(DocumentFragment node) => visitNodeFallback(node);
}

String htmlToCodeMarkup(Node node) {
  return (CodeMarkupVisitor()..visit(node)).toString();
}

class CodeMarkupVisitor extends TreeVisitor {
  final StringBuffer _str;

  CodeMarkupVisitor() : _str = StringBuffer();

  @override
  String toString() => _str.toString();

  @override
  void visitDocument(Document node) {
    _str.write('<pre>');
    visitChildren(node);
    _str.write('</pre>');
  }

  @override
  void visitDocumentType(DocumentType node) {
    _str.write('<code class="markup doctype">&lt;!DOCTYPE ${node.name}>'
        '</code>');
  }

  @override
  void visitText(Text node) {
    writeTextNodeAsHtml(_str, node);
  }

  @override
  void visitElement(Element node) {
    final tag = node.localName;
    _str.write('&lt;<code class="markup element-name">$tag</code>');
    if (node.attributes.isNotEmpty) {
      node.attributes.forEach((key, v) {
        v = htmlSerializeEscape(v, attributeMode: true);
        _str.write(' <code class="markup attribute-name">$key</code>'
            '=<code class="markup attribute-value">"$v"</code>');
      });
    }
    if (node.nodes.isNotEmpty) {
      _str.write('>');
      visitChildren(node);
    } else if (isVoidElement(tag)) {
      _str.write('>');
      return;
    }
    _str.write('&lt;/<code class="markup element-name">$tag</code>>');
  }

  @override
  void visitComment(Comment node) {
    final data = htmlSerializeEscape(node.data!);
    _str.write('<code class="markup comment">&lt;!--$data--></code>');
  }
}

bool isVoidElement(String? tagName) {
  switch (tagName) {
    case 'area':
    case 'base':
    case 'br':
    case 'col':
    case 'command':
    case 'embed':
    case 'hr':
    case 'img':
    case 'input':
    case 'keygen':
    case 'link':
    case 'meta':
    case 'param':
    case 'source':
    case 'track':
    case 'wbr':
      return true;
  }
  return false;
}

void writeTextNodeAsHtml(StringBuffer str, Text node) {
  final parent = node.parentNode;
  if (parent is Element) {
    final tag = parent.localName;
    if (rcdataElements.contains(tag) || tag == 'plaintext') {
      str.write(node.data);
      return;
    }
  }
  str.write(htmlSerializeEscape(node.data));
}
