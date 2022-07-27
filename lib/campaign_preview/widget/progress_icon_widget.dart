// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class ProgressIconWidget extends StatelessWidget {
  const ProgressIconWidget({
    Key? key,
    required this.progressState,
  }) : super(key: key);

  final int progressState;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Icon(
          progressState >= 0 ? Icons.radio_button_on : Icons.radio_button_off,
          size: 10,
          color: const Color(0xFFDC721E),
        ),
        Icon(
          progressState >= 1 ? Icons.radio_button_on : Icons.radio_button_off,
          size: 10,
          color: const Color(0xFFDC721E),
        ),
        Icon(
          progressState >= 2 ? Icons.radio_button_on : Icons.radio_button_off,
          size: 10,
          color: const Color(0xFFDC721E),
        ),
        Icon(
          progressState >= 3 ? Icons.radio_button_on : Icons.radio_button_off,
          size: 10,
          color: const Color(0xFFDC721E),
        )
      ],
    );
  }
}
