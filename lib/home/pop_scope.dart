// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class CustomPopScope extends StatefulWidget {
  final Widget child;

  const CustomPopScope({Key? key, required this.child}) : super(key: key);

  @override
  State<CustomPopScope> createState() => _CustomPopScopeState();
}

class _CustomPopScopeState extends State<CustomPopScope> {
  DateTime? _backButtonPress;

  Future<bool> _onWillPop() {
    DateTime now = DateTime.now();
    if (_backButtonPress == null ||
        now.difference(_backButtonPress!) > const Duration(seconds: 2)) {
      _backButtonPress = now;
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) =>
      WillPopScope(onWillPop: _onWillPop, child: widget.child);
}
