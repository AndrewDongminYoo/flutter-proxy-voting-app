import 'package:flutter/material.dart';

import 'base_painter.dart';

class PageIndicator extends StatefulWidget {
  final double size;
  final double space;
  final int count;
  final Color activeColor;
  final Color color;
  // final PageController controller;
  final double activeSize;
  const PageIndicator({
    Key? key,
    this.size = 20.0,
    this.space = 5.0,
    this.count = 3,
    this.activeSize = 20.0,
    this.color = Colors.orange,
    this.activeColor = Colors.yellow,
    // required this.controller
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PageIndicatorState();
  }
}

class _PageIndicatorState extends State<PageIndicator> {
  int index = 0;
  Paint _paint = new Paint();

  @override
  Widget build(BuildContext context) {
    Widget child = SizedBox(
      width: widget.count * widget.size + (widget.count - 1) * widget.space,
      height: widget.size,
      child: CustomPaint(
          painter: WarmPainter(
        widget,
        3,
        index,
        _paint,
      )),
    );

    return IgnorePointer(
      child: child,
    );
  }

  // void _onController() {
  //   double page = 3;
  //   index = page.floor();

  //   setState(() {});
  // }

  // @override
  // void initState() {
  //   widget.controller.addListener(_onController);
  //   super.initState();
  // }

  // @override
  // void didUpdateWidget(PageIndicator oldWidget) {
  //   if (widget.controller != oldWidget.controller) {
  //     oldWidget.controller.removeListener(_onController);
  //     widget.controller.addListener(_onController);
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  // @override
  // void dispose() {
  //   widget.controller.removeListener(_onController);
  //   super.dispose();
  // }
}
