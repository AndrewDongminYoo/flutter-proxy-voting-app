// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../../shared/custom_nav.dart';

// ignore: must_be_immutable
class PasswordDialog extends StatefulWidget {
  PasswordDialog({
    super.key,
    required this.password,
    required this.title,
  });
  String password;
  String title;
  @override
  State<PasswordDialog> createState() => _PasswordDialogState();
}

class _PasswordDialogState extends State<PasswordDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.title),
          TextFormField(
            initialValue: widget.password,
            obscureText: true,
            onChanged: (String value) => widget.password = value,
            onEditingComplete: () => goBackWithVal(
              context,
              widget.password,
            ),
            onTapOutside: (PointerDownEvent e) => goBackWithVal(
              context,
              widget.password,
            ),
            onSaved: (String? newValue) => goBackWithVal(
              context,
              newValue,
            ),
          ),
        ],
      ),
    );
  }
}
