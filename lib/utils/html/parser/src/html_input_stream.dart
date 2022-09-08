// 🎯 Dart imports:
import 'dart:collection';
import 'dart:convert' show ascii, utf8;

// 📦 Package imports:
import 'package:source_span/source_span.dart';

// 🌎 Project imports:
import 'src.dart';

class HtmlInputStream {
  static const int numBytesMeta = 512;

  static const String defaultEncoding = 'utf-8';

  String? charEncodingName;

  bool charEncodingCertain = true;

  final bool generateSpans;

  final String? sourceUrl;

  List<int>? _rawBytes;

  List<int>? _rawChars;

  Queue<String> errors = Queue<String>();

  SourceFile? fileInfo;

  List<int> _chars = <int>[];

  int _offset = 0;

  HtmlInputStream(source,
      [String? encoding,
      bool parseMeta = true,
      this.generateSpans = false,
      this.sourceUrl])
      : charEncodingName = codecName(encoding) {
    if (source is String) {
      _rawChars = source.codeUnits;
      charEncodingName = 'utf-8';
      charEncodingCertain = true;
    } else if (source is List<int>) {
      _rawBytes = source;
    } else {
      throw ArgumentError.value(
          source, 'source', 'Must be a String or List<int>.');
    }

    if (charEncodingName == null) {
      detectEncoding(parseMeta);
    }

    reset();
  }

  void reset() {
    errors = Queue<String>();

    _offset = 0;
    _chars = <int>[];

    final List<int> rawChars =
        _rawChars ??= _decodeBytes(charEncodingName!, _rawBytes!);

    bool skipNewline = false;
    bool wasSurrogatePair = false;
    for (int i = 0; i < rawChars.length; i++) {
      int c = rawChars[i];
      if (skipNewline) {
        skipNewline = false;
        if (c == newLine) continue;
      }

      final bool isSurrogatePair = _isSurrogatePair(rawChars, i);
      if (!isSurrogatePair && !wasSurrogatePair) {
        if (_invalidUnicode(c)) {
          errors.add('invalid-codepoint');

          if (0xD800 <= c && c <= 0xDFFF) {
            c = 0xFFFD;
          }
        }
      }
      wasSurrogatePair = isSurrogatePair;

      if (c == returnCode) {
        skipNewline = true;
        c = newLine;
      }

      _chars.add(c);
    }

    if (_rawBytes != null) _rawChars = null;

    fileInfo = SourceFile.decoded(_chars, url: sourceUrl);
  }

  void detectEncoding([bool parseMeta = true]) {
    charEncodingName = detectBOM();
    charEncodingCertain = true;

    if (charEncodingName == null && parseMeta) {
      charEncodingName = detectEncodingMeta();
      charEncodingCertain = false;
    }

    if (charEncodingName == null) {
      charEncodingCertain = false;
      charEncodingName = defaultEncoding;
    }

    if (charEncodingName!.toLowerCase() == 'iso-8859-1') {
      charEncodingName = 'windows-1252';
    }
  }

  void changeEncoding(String? newEncoding) {
    if (_rawBytes == null) {
      throw StateError('cannot change encoding when parsing a String.');
    }

    newEncoding = codecName(newEncoding);
    if (const ['utf-16', 'utf-16-be', 'utf-16-le'].contains(newEncoding)) {
      newEncoding = 'utf-8';
    }
    if (newEncoding == null) {
      return;
    } else if (newEncoding == charEncodingName) {
      charEncodingCertain = true;
    } else {
      charEncodingName = newEncoding;
      charEncodingCertain = true;
      _rawChars = null;
      reset();
      throw ReparseException(
          'Encoding changed from $charEncodingName to $newEncoding');
    }
  }

  String? detectBOM() {
    if (_hasUtf8Bom(_rawBytes!)) {
      return 'utf-8';
    }
    return null;
  }

  String? detectEncodingMeta() {
    final EncodingParser parser =
        EncodingParser(slice(_rawBytes!, 0, numBytesMeta));
    String? encoding = parser.getEncoding();

    if (const ['utf-16', 'utf-16-be', 'utf-16-le'].contains(encoding)) {
      encoding = 'utf-8';
    }

    return encoding;
  }

  int get position => _offset;

  String? char() {
    if (_offset >= _chars.length) return eof;
    return _isSurrogatePair(_chars, _offset)
        ? String.fromCharCodes([_chars[_offset++], _chars[_offset++]])
        : String.fromCharCode(_chars[_offset++]);
  }

  String? peekChar() {
    if (_offset >= _chars.length) return eof;
    return _isSurrogatePair(_chars, _offset)
        ? String.fromCharCodes([_chars[_offset], _chars[_offset + 1]])
        : String.fromCharCode(_chars[_offset]);
  }

  bool _isSurrogatePair(List<int> chars, int i) {
    return i + 1 < chars.length &&
        _isLeadSurrogate(chars[i]) &&
        _isTrailSurrogate(chars[i + 1]);
  }

  bool _isLeadSurrogate(int code) => (code & 0xFC00) == 0xD800;

  bool _isTrailSurrogate(int code) => (code & 0xFC00) == 0xDC00;

  String charsUntil(String characters, [bool opposite = false]) {
    final int start = _offset;
    String? c;
    while ((c = peekChar()) != null && characters.contains(c!) == opposite) {
      _offset += c.codeUnits.length;
    }

    return String.fromCharCodes(_chars.sublist(start, _offset));
  }

  void unget(String? ch) {
    if (ch != null) {
      _offset -= ch.length;
      assert(peekChar() == ch);
    }
  }
}

bool _invalidUnicode(int c) {
  if (0x0001 <= c && c <= 0x0008) return true;
  if (0x000E <= c && c <= 0x001F) return true;
  if (0x007F <= c && c <= 0x009F) return true;
  if (0xD800 <= c && c <= 0xDFFF) return true;
  if (0xFDD0 <= c && c <= 0xFDEF) return true;
  switch (c) {
    case 0x000B:
    case 0xFFFE:
    case 0xFFFF:
    case 0x01FFFE:
    case 0x01FFFF:
    case 0x02FFFE:
    case 0x02FFFF:
    case 0x03FFFE:
    case 0x03FFFF:
    case 0x04FFFE:
    case 0x04FFFF:
    case 0x05FFFE:
    case 0x05FFFF:
    case 0x06FFFE:
    case 0x06FFFF:
    case 0x07FFFE:
    case 0x07FFFF:
    case 0x08FFFE:
    case 0x08FFFF:
    case 0x09FFFE:
    case 0x09FFFF:
    case 0x0AFFFE:
    case 0x0AFFFF:
    case 0x0BFFFE:
    case 0x0BFFFF:
    case 0x0CFFFE:
    case 0x0CFFFF:
    case 0x0DFFFE:
    case 0x0DFFFF:
    case 0x0EFFFE:
    case 0x0EFFFF:
    case 0x0FFFFE:
    case 0x0FFFFF:
    case 0x10FFFE:
    case 0x10FFFF:
      return true;
  }
  return false;
}

String? codecName(String? encoding) {
  final RegExp asciiPunctuation = RegExp(
      '[\u0009-\u000D\u0020-\u002F\u003A-\u0040\u005B-\u0060\u007B-\u007E]');

  if (encoding == null) return null;
  final String canonicalName =
      encoding.replaceAll(asciiPunctuation, '').toLowerCase();
  return encodings[canonicalName];
}

bool _hasUtf8Bom(List<int> bytes, [int offset = 0, int? length]) {
  final int end = length != null ? offset + length : bytes.length;
  return (offset + 3) <= end &&
      bytes[offset] == 0xEF &&
      bytes[offset + 1] == 0xBB &&
      bytes[offset + 2] == 0xBF;
}

List<int> _decodeBytes(String encoding, List<int> bytes) {
  switch (encoding) {
    case 'ascii':
      return ascii.decode(bytes).codeUnits;

    case 'utf-8':
      return utf8.decode(bytes).codeUnits;

    default:
      throw ArgumentError('Encoding $encoding not supported');
  }
}
