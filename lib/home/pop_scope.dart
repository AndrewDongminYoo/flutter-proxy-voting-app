// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class CustomPopScope extends StatefulWidget {
  final Widget child;

  const CustomPopScope({Key? key, required this.child}) : super(key: key);

  @override
  State<CustomPopScope> createState() => _CustomPopScopeState();
}

class _CustomPopScopeState extends State<CustomPopScope> {
  DateTime? backButtonPress;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (backButtonPress == null ||
        now.difference(backButtonPress!) > const Duration(seconds: 2)) {
      backButtonPress = now;
      return Future.value(false);
    }
    return Future.value(true);
  }

  @override
  Widget build(BuildContext context) =>
      WillPopScope(onWillPop: onWillPop, child: widget.child);
}
