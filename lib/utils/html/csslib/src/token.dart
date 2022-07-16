part of '../parser.dart';

class Token {
  final int kind;

  final FileSpan span;

  int get start => span.start.offset;

  int get end => span.end.offset;

  String get text => span.text;

  Token(this.kind, this.span);

  @override
  String toString() {
    var kindText = TokenKind.kindToString(kind);
    var actualText = text.trim();
    if (kindText != actualText) {
      if (actualText.length > 10) {
        actualText = '${actualText.substring(0, 8)}...';
      }
      return '$kindText($actualText)';
    } else {
      return kindText;
    }
  }
}

class LiteralToken extends Token {
  dynamic value;
  LiteralToken(int kind, FileSpan span, this.value) : super(kind, span);
}

class ErrorToken extends Token {
  String? message;
  ErrorToken(int kind, FileSpan span, this.message) : super(kind, span);
}

class IdentifierToken extends Token {
  @override
  final String text;

  IdentifierToken(this.text, int kind, FileSpan span) : super(kind, span);
}
