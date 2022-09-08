import 'package:flutter/material.dart';

import '../../shared/custom_nav.dart';

// ignore: must_be_immutable
class InputAlert extends StatefulWidget {
  InputAlert({super.key, required this.password, required this.title});
  String password;
  String title;
  @override
  State<InputAlert> createState() => _InputAlertState();
}

class _InputAlertState extends State<InputAlert> {
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
            onChanged: (value) => widget.password = value,
            onEditingComplete: () => goBackWithVal(
              context,
              widget.password,
            ),
            onTapOutside: (e) => goBackWithVal(
              context,
              widget.password,
            ),
            onSaved: (newValue) => goBackWithVal(
              context,
              newValue,
            ),
          ),
        ],
      ),
    );
  }
}
