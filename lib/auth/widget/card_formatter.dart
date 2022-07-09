// 🐦 Flutter imports:
import 'package:flutter/services.dart';

class CardFormatter extends TextInputFormatter {
  final String sample;
  final String separator;

  CardFormatter({
    required this.sample,
    required this.separator,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    final oldText = oldValue.text;

    if (newText.isEmpty || newText.length < oldText.length) {
      return newValue;
    }

    if (newText.length > oldText.length) {
      // max length
      if (newText.length > sample.length) return oldValue;
      // add seperator
      if (newText.length < sample.length &&
          sample[newText.length] == separator) {
        final text = '$newText$separator';
        return TextEditingValue(
            text: text,
            selection: TextSelection.collapsed(offset: text.length));
      }
    }
    return newValue;
  }
}
