// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import '../shared/custom_nav.dart';

class CustomPopScope extends StatefulWidget {
  final Widget child;

  const CustomPopScope({Key? key, required this.child}) : super(key: key);

  @override
  State<CustomPopScope> createState() => _CustomPopScopeState();
}

class _CustomPopScopeState extends State<CustomPopScope> {
  DateTime? _backButtonPress;

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    const duration = Duration(seconds: 2);
    if (_backButtonPress == null ||
        now.difference(_backButtonPress!) > duration) {
      _backButtonPress = now;
      return false;
    }
    return ((await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('뒤로가기를 두번 클릭하셨습니다.'),
            content: const Text('앱을 종료하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => popWithValue(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => popWithValue(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false) as bool;
  }

  @override
  Widget build(BuildContext context) =>
      WillPopScope(onWillPop: _onWillPop, child: widget.child);
}
