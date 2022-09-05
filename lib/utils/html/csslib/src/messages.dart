// 📦 Package imports:
import 'package:source_span/source_span.dart';

// 🌎 Project imports:
import 'preprocessor_options.dart';

enum CssMessageLevel { info, warning, severe }

late CssMessages messages;

const _greenColor = '\u001b[32m';
const _redColor = '\u001b[31m';
const _magentaColor = '\u001b[35m';
const _noColor = '\u001b[0m';

const Map<CssMessageLevel, String> _errorColors = {
  CssMessageLevel.severe: _redColor,
  CssMessageLevel.warning: _magentaColor,
  CssMessageLevel.info: _greenColor,
};

const Map<CssMessageLevel, String> _errorLabel = {
  CssMessageLevel.severe: 'error',
  CssMessageLevel.warning: 'warning',
  CssMessageLevel.info: 'info',
};

class CssMessage {
  final CssMessageLevel level;
  final String message;
  final SourceSpan? span;
  final bool useColors;

  CssMessage(this.level, this.message, {this.span, this.useColors = false});

  @override
  String toString() {
    StringBuffer output = StringBuffer();
    bool colors = useColors && _errorColors.containsKey(level);
    String? levelColor = colors ? _errorColors[level] : null;
    if (colors) output.write(levelColor);
    output
      ..write(_errorLabel[level])
      ..write(' ');
    if (colors) output.write(_noColor);

    if (span == null) {
      output.write(message);
    } else {
      output.write('on ');
      output.write(span!.message(message, color: levelColor));
    }

    return output.toString();
  }
}

class CssMessages {
  final void Function(CssMessage obj) printHandler;

  final CssPreprocessorOptions options;

  final List<CssMessage> messages = <CssMessage>[];

  CssMessages({CssPreprocessorOptions? options, this.printHandler = print})
      : options = options ?? const CssPreprocessorOptions();

  void error(String message, SourceSpan? span) {
    CssMessage msg = CssMessage(CssMessageLevel.severe, message,
        span: span, useColors: options.useColors);

    messages.add(msg);

    printHandler(msg);
  }

  void warning(String message, SourceSpan? span) {
    if (options.warningsAsErrors) {
      error(message, span);
    } else {
      CssMessage msg = CssMessage(CssMessageLevel.warning, message,
          span: span, useColors: options.useColors);

      messages.add(msg);
    }
  }

  void info(String message, SourceSpan span) {
    CssMessage msg = CssMessage(CssMessageLevel.info, message,
        span: span, useColors: options.useColors);

    messages.add(msg);

    if (options.verbose) printHandler(msg);
  }

  void mergeMessages(CssMessages newMessages) {
    messages.addAll(newMessages.messages);
    newMessages.messages
        .where((message) =>
            message.level == CssMessageLevel.severe || options.verbose)
        .forEach(printHandler);
  }
}
