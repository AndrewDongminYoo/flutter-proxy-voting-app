// 📦 Package imports:
import 'package:source_span/source_span.dart';

// 🌎 Project imports:
import 'preprocessor_options.dart';

enum MessageLevel { info, warning, severe }

late Messages messages;

const _greenColor = '\u001b[32m';
const _redColor = '\u001b[31m';
const _magentaColor = '\u001b[35m';
const _noColor = '\u001b[0m';

const Map<MessageLevel, String> _errorColors = {
  MessageLevel.severe: _redColor,
  MessageLevel.warning: _magentaColor,
  MessageLevel.info: _greenColor,
};

const Map<MessageLevel, String> _errorLabel = {
  MessageLevel.severe: 'error',
  MessageLevel.warning: 'warning',
  MessageLevel.info: 'info',
};

class Message {
  final MessageLevel level;
  final String message;
  final SourceSpan? span;
  final bool useColors;

  Message(this.level, this.message, {this.span, this.useColors = false});

  @override
  String toString() {
    var output = StringBuffer();
    var colors = useColors && _errorColors.containsKey(level);
    var levelColor = colors ? _errorColors[level] : null;
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

class Messages {
  final void Function(Message obj) printHandler;

  final PreprocessorOptions options;

  final List<Message> messages = <Message>[];

  Messages({PreprocessorOptions? options, this.printHandler = print})
      : options = options ?? const PreprocessorOptions();

  void error(String message, SourceSpan? span) {
    var msg = Message(MessageLevel.severe, message,
        span: span, useColors: options.useColors);

    messages.add(msg);

    printHandler(msg);
  }

  void warning(String message, SourceSpan? span) {
    if (options.warningsAsErrors) {
      error(message, span);
    } else {
      var msg = Message(MessageLevel.warning, message,
          span: span, useColors: options.useColors);

      messages.add(msg);
    }
  }

  void info(String message, SourceSpan span) {
    var msg = Message(MessageLevel.info, message,
        span: span, useColors: options.useColors);

    messages.add(msg);

    if (options.verbose) printHandler(msg);
  }

  void mergeMessages(Messages newMessages) {
    messages.addAll(newMessages.messages);
    newMessages.messages
        .where((message) =>
            message.level == MessageLevel.severe || options.verbose)
        .forEach(printHandler);
  }
}
