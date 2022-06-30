class Mailto {
  Mailto({
    this.to,
    this.cc,
    this.bcc,
    this.subject,
    this.body,
  });

  static void validateParameters({
    List<String>? to,
    List<String>? cc,
    List<String>? bcc,
    String? subject,
    String? body,
  }) {
    bool isEmptyString(String e) => e.isEmpty;
    bool containsLineBreak(String e) => e.contains('\n');
    if (to?.any(isEmptyString) == true) {
      throw ArgumentError.value(
        to,
        'to',
        'elements in "to" list must not be empty',
      );
    }
    if (to?.any(containsLineBreak) == true) {
      throw ArgumentError.value(
        to,
        'to',
        'elements in "to" list must not contain line breaks',
      );
    }
    if (cc?.any(isEmptyString) == true) {
      throw ArgumentError.value(
        cc,
        'cc',
        'elements in "cc" list must not be empty. ',
      );
    }
    if (cc?.any(containsLineBreak) == true) {
      throw ArgumentError.value(
        cc,
        'cc',
        'elements in "cc" list must not contain line breaks',
      );
    }
    if (bcc?.any(isEmptyString) == true) {
      throw ArgumentError.value(
        bcc,
        'bcc',
        'elements in "bcc" list must not be empty. ',
      );
    }
    if (bcc?.any(containsLineBreak) == true) {
      throw ArgumentError.value(
        bcc,
        'bcc',
        'elements in "bcc" list must not contain line breaks',
      );
    }
    if (subject?.contains('\n') == true) {
      throw ArgumentError.value(
        subject,
        'subject',
        '"subject" must not contain line breaks',
      );
    }
  }

  final List<String>? to;

  final List<String>? cc;

  final List<String>? bcc;

  final String? subject;

  final String? body;

  static const String _comma = '%2C';

  String _encodeTo(String s) {
    final atSign = s.lastIndexOf('@');
    return Uri.encodeComponent(s.substring(0, atSign)) + s.substring(atSign);
  }

  @override
  String toString() {
    // Use a string buffer as input is of unknown length.
    final stringBuffer = StringBuffer('mailto:');
    if (to != null) stringBuffer.writeAll(to!.map(_encodeTo), _comma);
    // We need this flag to know whether we should use & or ? when creating
    // the string.
    var parameterAdded = false;
    final parameterMap = {
      'subject': subject,
      'body': body,
      'cc': cc?.join(','),
      'bcc': bcc?.join(','),
    };
    for (final parameter in parameterMap.entries) {
      // Do not add key-value pair where the value is missing or empty
      if (parameter.value == null || parameter.value!.isEmpty) continue;
      // We don't need to encode the keys because all keys are under the
      // package's control currently and all of those keys are simple keys
      // without any special characters.
      // The values need to be encoded.
      // The RFC also mentions that the body should use '%0D%0A' for
      // line-breaks, however,we didn't find any difference between
      // '%0A' and '%0D%0A', so we keep it at '%0A'.
      stringBuffer
        ..write(parameterAdded ? '&' : '?')
        ..write(parameter.key)
        ..write('=')
        ..write(Uri.encodeComponent(parameter.value!));
      parameterAdded = true;
    }
    return stringBuffer.toString();
  }
}
